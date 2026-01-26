//
//  DiscoverLocationManager.swift
//  PingNative
//
//  Location management for Discover screen
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

    private var hasInitializedLocation: Bool = false
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?
    private let locationManager = CLLocationManager()

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

// MARK: - CLLocationManagerDelegate
extension DiscoverLocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coord = location.coordinate

        guard abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 else { return }

        print("📍 Got location update: \(coord.latitude), \(coord.longitude)")

        Task { @MainActor in
            self.currentRegion.center = coord
            self.locationStatus = "Location updated"
            self.locationReady = true

            if let continuation = self.locationContinuation {
                self.locationContinuation = nil
                manager.stopUpdatingLocation()
                continuation.resume(returning: coord)
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("📍 Authorization changed: \(status.rawValue)")

        Task { @MainActor in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationStatus = "Authorized"
                if let location = manager.location {
                    let coord = location.coordinate
                    if abs(coord.latitude) > 0.1 || abs(coord.longitude) > 0.1 {
                        print("📍 Using location from authorization: \(coord.latitude), \(coord.longitude)")
                        self.currentRegion.center = coord
                        self.locationReady = true
                    }
                }
                manager.startUpdatingLocation()
            case .denied, .restricted:
                self.locationStatus = "Location denied"
                self.locationReady = true
                print("❌ Location access denied or restricted")
            case .notDetermined:
                self.locationStatus = "Waiting for permission"
            @unknown default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error)")

        Task { @MainActor in
            self.locationStatus = "Location error"

            if let continuation = self.locationContinuation {
                self.locationContinuation = nil
                continuation.resume(returning: nil)
            }
        }
    }
}
