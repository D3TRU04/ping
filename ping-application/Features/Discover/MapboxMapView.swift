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
    let places: [Place]
    let onPlaceSelect: ((Place) -> Void)?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = coordinateRegion
        mapView.showsUserLocation = showsUserLocation
        mapView.mapType = .standard
        
        // Add annotations for places
        context.coordinator.addAnnotations(for: places, on: mapView)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update region if changed
        if mapView.region.center.latitude != coordinateRegion.center.latitude ||
           mapView.region.center.longitude != coordinateRegion.center.longitude {
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        // Update annotations
        context.coordinator.updateAnnotations(for: places, on: mapView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPlaceSelect: onPlaceSelect)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var annotations: [PlaceAnnotation] = []
        let onPlaceSelect: ((Place) -> Void)?
        
        init(onPlaceSelect: ((Place) -> Void)?) {
            self.onPlaceSelect = onPlaceSelect
        }
        
        func addAnnotations(for places: [Place], on mapView: MKMapView) {
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
            
            for place in places {
                guard let coordinate = place.coordinate else { continue }
                
                let annotation = PlaceAnnotation(place: place, coordinate: coordinate)
                annotations.append(annotation)
            }
            
            mapView.addAnnotations(annotations)
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
