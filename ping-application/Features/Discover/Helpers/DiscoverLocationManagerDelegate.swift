//
//  DiscoverLocationManager+Delegate.swift
//  PingNative
//
//  CLLocationManagerDelegate implementation
//

import Foundation
import CoreLocation
import MapKit

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
