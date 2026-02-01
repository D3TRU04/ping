//
//  MapboxMapView.swift
//  PingNative
//
//  Source: ping/apps/src/screens/discover/components/Map.tsx
//  Mapbox SDK integration for DiscoverView
//

import SwiftUI
import MapKit
import CoreLocation
import UIKit

struct MapboxMapView: UIViewRepresentable {
    @Binding var coordinateRegion: MKCoordinateRegion
    let showsUserLocation: Bool
    let mapType: MKMapType
    let places: [Place]
    let selectedPlace: Place?
    let onPlaceSelect: ((Place) -> Void)?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = coordinateRegion
        mapView.showsUserLocation = showsUserLocation
        mapView.mapType = mapType

        context.coordinator.lastPlaceIds = Set(places.map { $0.id })
        context.coordinator.addAnnotations(for: places, on: mapView)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if mapView.mapType != mapType {
            mapView.mapType = mapType
        }

        context.coordinator.onPlaceSelect = onPlaceSelect
        context.coordinator.coordinateRegionBinding = $coordinateRegion

        if !context.coordinator.isUpdatingRegion {
            let center = mapView.region.center
            let newCenter = coordinateRegion.center
            let span = mapView.region.span
            let newSpan = coordinateRegion.span

            let centerChanged = abs(center.latitude - newCenter.latitude) > 0.001 ||
                               abs(center.longitude - newCenter.longitude) > 0.001

            let spanChanged = abs(span.latitudeDelta - newSpan.latitudeDelta) > 0.001 ||
                             abs(span.longitudeDelta - newSpan.longitudeDelta) > 0.001

            if centerChanged || spanChanged {
                context.coordinator.isUpdatingRegion = true
                mapView.setRegion(coordinateRegion, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    context.coordinator.isUpdatingRegion = false
                }
            }
        }

        let currentPlaceIds = Set(places.map { $0.id })
        if currentPlaceIds != context.coordinator.lastPlaceIds {
            context.coordinator.lastPlaceIds = currentPlaceIds
            context.coordinator.addAnnotations(for: places, on: mapView)
        }

        if context.coordinator.selectedPlace?.id != selectedPlace?.id {
            context.coordinator.selectedPlace = selectedPlace
            context.coordinator.updateSelectionState(on: mapView)
        }
    }

    func makeCoordinator() -> MapboxMapCoordinator {
        MapboxMapCoordinator(coordinateRegion: $coordinateRegion, selectedPlace: selectedPlace, onPlaceSelect: onPlaceSelect)
    }
}

class PlaceAnnotation: NSObject, MKAnnotation {
    let place: Place
    let coordinate: CLLocationCoordinate2D
    var title: String? { place.name }
    var subtitle: String? { place.address }

    init(place: Place, coordinate: CLLocationCoordinate2D) {
        self.place = place
        self.coordinate = coordinate
        super.init()
    }
}
