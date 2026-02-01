//
//  DiscoverLocationManager.swift
//  PingNative
//
//  Location management for Discover screen
//
//  Related files:
//  - DiscoverLocationManager+Delegate.swift - CLLocationManagerDelegate implementation
//

import Foundation
import CoreLocation
import MapKit
import Combine

@MainActor
class DiscoverLocationManager: NSObject, ObservableObject {
    @Published var currentRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var locationStatus: String = "Initializing..."
    @Published var locationReady: Bool = false

    var hasInitializedLocation: Bool = false
    var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?
    let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        print("📍 Requesting location permission, current status: \(status.rawValue)")

        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func initializeIfNeeded() async {
        guard !hasInitializedLocation else {
            print("📍 Location already initialized")
            return
        }

        await initializeUserLocation()
        hasInitializedLocation = true
    }

    private func initializeUserLocation() async {
        print("📍 Initializing user location...")
        locationStatus = "Getting location..."

        let authStatus = locationManager.authorizationStatus
        print("📍 Authorization status: \(authStatus.rawValue)")

        switch authStatus {
        case .notDetermined:
            print("📍 Requesting authorization...")
            locationManager.requestWhenInUseAuthorization()
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        case .denied, .restricted:
            print("❌ Location access denied - using fallback location")
            locationStatus = "Location access denied"
            locationReady = true
            return
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location authorized")
        @unknown default:
            break
        }

        if let location = locationManager.location {
            let coord = location.coordinate
            if abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 {
                print("📍 Using cached location: \(coord.latitude), \(coord.longitude)")
                currentRegion.center = coord
                locationStatus = "Location found"
                locationReady = true
                return
            }
        }

        print("📍 Requesting fresh location...")
        locationManager.startUpdatingLocation()

        let location = await withCheckedContinuation { (continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>) in
            self.locationContinuation = continuation

            Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                if let cont = self.locationContinuation {
                    self.locationContinuation = nil
                    self.locationManager.stopUpdatingLocation()
                    print("⏱️ Location timeout")
                    cont.resume(returning: nil)
                }
            }
        }

        if let coord = location {
            print("📍 Got location: \(coord.latitude), \(coord.longitude)")
            currentRegion.center = coord
            locationStatus = "Location found"
            locationReady = true
        } else {
            if let lastLocation = locationManager.location {
                let coord = lastLocation.coordinate
                if abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 {
                    print("📍 Using last known location: \(coord.latitude), \(coord.longitude)")
                    currentRegion.center = coord
                    locationStatus = "Location found"
                    locationReady = true
                    return
                }
            }
            print("⚠️ Could not get location - map will center when location becomes available")
            locationStatus = "Waiting for location..."
            locationReady = true
        }
    }

    func centerOnUserLocation() {
        print("📍 Center on user location requested")

        if let location = locationManager.location {
            let coord = location.coordinate
            if abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 {
                print("📍 Centering on: \(coord.latitude), \(coord.longitude)")
                currentRegion.center = coord
                return
            }
        }

        print("⚠️ No valid cached location, requesting fresh location...")
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func calculateRadiusKm() -> Double {
        let latDelta = currentRegion.span.latitudeDelta
        let radiusKm = latDelta * 111 / 2
        return min(max(radiusKm, 1), 50)
    }
}
