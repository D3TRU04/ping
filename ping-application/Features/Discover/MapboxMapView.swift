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
// Note: Mapbox SDK integration requires additional setup
// For now, using MapKit with custom styling to match Mapbox appearance
// To use Mapbox SDK: https://docs.mapbox.com/ios/maps/guides/install/

struct MapboxMapView: UIViewRepresentable {
    @Binding var coordinateRegion: MKCoordinateRegion
    let showsUserLocation: Bool
    let mapType: MKMapType
    let places: [Place]
    let onPlaceSelect: ((Place) -> Void)?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = coordinateRegion
        mapView.showsUserLocation = showsUserLocation
        mapView.mapType = mapType
        
        print("🗺️ Map created with \(places.count) places")
        
        // Add annotations for places
        context.coordinator.addAnnotations(for: places, on: mapView)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update map type
        if mapView.mapType != mapType {
            mapView.mapType = mapType
        }
        
        // Update region if changed
        // Use a threshold to avoid infinite loops due to floating point precision
        let center = mapView.region.center
        let span = mapView.region.span
        let newCenter = coordinateRegion.center
        let newSpan = coordinateRegion.span
        
        let centerChanged = abs(center.latitude - newCenter.latitude) > 0.0001 ||
                           abs(center.longitude - newCenter.longitude) > 0.0001
        
        let spanChanged = abs(span.latitudeDelta - newSpan.latitudeDelta) > 0.0001 ||
                         abs(span.longitudeDelta - newSpan.longitudeDelta) > 0.0001
        
        if centerChanged || spanChanged {
             mapView.setRegion(coordinateRegion, animated: true)
        }
        
        // Update annotations
        context.coordinator.updateAnnotations(for: places, on: mapView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(coordinateRegion: $coordinateRegion, onPlaceSelect: onPlaceSelect)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        @Binding var coordinateRegion: MKCoordinateRegion
        var annotations: [PlaceAnnotation] = []
        let onPlaceSelect: ((Place) -> Void)?
        
        init(coordinateRegion: Binding<MKCoordinateRegion>, onPlaceSelect: ((Place) -> Void)?) {
            self._coordinateRegion = coordinateRegion
            self.onPlaceSelect = onPlaceSelect
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.coordinateRegion = mapView.region
            }
        }
        
        func addAnnotations(for places: [Place], on mapView: MKMapView) {
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
            
            var addedCount = 0
            var skippedCount = 0
            
            for place in places {
                guard let coordinate = place.coordinate else {
                    skippedCount += 1
                    continue
                }
                
                let annotation = PlaceAnnotation(place: place, coordinate: coordinate)
                annotations.append(annotation)
                addedCount += 1
            }
            
            mapView.addAnnotations(annotations)
            print("🗺️ Added \(addedCount) annotations, skipped \(skippedCount) (no coordinates)")
        }
        
        func updateAnnotations(for places: [Place], on mapView: MKMapView) {
            addAnnotations(for: places, on: mapView)
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let placeAnnotation = view.annotation as? PlaceAnnotation else { return }
            onPlaceSelect?(placeAnnotation.place)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let placeAnnotation = annotation as? PlaceAnnotation else { return nil }
            
            let identifier = "PlaceAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            if let markerView = annotationView as? MKMarkerAnnotationView {
                markerView.markerTintColor = UIColor(AppColors.mint)
                markerView.glyphImage = UIImage(systemName: "mappin.circle.fill")
            }
            
            return annotationView
        }
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
