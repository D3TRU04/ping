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
    let selectedPlace: Place?
    let onPlaceSelect: ((Place) -> Void)?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = coordinateRegion
        mapView.showsUserLocation = showsUserLocation
        mapView.mapType = mapType

        // Add annotations for places and track their IDs
        context.coordinator.lastPlaceIds = Set(places.map { $0.id })
        context.coordinator.addAnnotations(for: places, on: mapView)

        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update map type
        if mapView.mapType != mapType {
            mapView.mapType = mapType
        }

        // Update the onPlaceSelect callback to ensure it's current
        context.coordinator.onPlaceSelect = onPlaceSelect
        context.coordinator.coordinateRegionBinding = $coordinateRegion

        // Update region if changed (only if not currently being updated by user interaction)
        if !context.coordinator.isUpdatingRegion {
            let center = mapView.region.center
            let newCenter = coordinateRegion.center

            let centerChanged = abs(center.latitude - newCenter.latitude) > 0.001 ||
                               abs(center.longitude - newCenter.longitude) > 0.001

            if centerChanged {
                context.coordinator.isUpdatingRegion = true
                mapView.setRegion(coordinateRegion, animated: true)
                // Reset flag after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    context.coordinator.isUpdatingRegion = false
                }
            }
        }

        // Only update annotations if places have changed
        let currentPlaceIds = Set(places.map { $0.id })
        if currentPlaceIds != context.coordinator.lastPlaceIds {
            context.coordinator.lastPlaceIds = currentPlaceIds
            context.coordinator.addAnnotations(for: places, on: mapView)
        }

        // Update selection state in coordinator (without rebuilding annotations)
        if context.coordinator.selectedPlace?.id != selectedPlace?.id {
            context.coordinator.selectedPlace = selectedPlace
            // Just update the visual selection state of existing annotations
            context.coordinator.updateSelectionState(on: mapView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(coordinateRegion: $coordinateRegion, selectedPlace: selectedPlace, onPlaceSelect: onPlaceSelect)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var coordinateRegion: MKCoordinateRegion
        var coordinateRegionBinding: Binding<MKCoordinateRegion>?
        var annotations: [PlaceAnnotation] = []
        var selectedPlace: Place?
        var onPlaceSelect: ((Place) -> Void)?
        var lastPlaceIds: Set<String> = []
        var isUpdatingRegion: Bool = false

        init(coordinateRegion: Binding<MKCoordinateRegion>, selectedPlace: Place?, onPlaceSelect: ((Place) -> Void)?) {
            self.coordinateRegion = coordinateRegion.wrappedValue
            self.coordinateRegionBinding = coordinateRegion
            self.selectedPlace = selectedPlace
            self.onPlaceSelect = onPlaceSelect
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // Only update binding if this is a user-initiated change, not a programmatic one
            guard !isUpdatingRegion else { return }

            DispatchQueue.main.async { [weak self] in
                self?.coordinateRegionBinding?.wrappedValue = mapView.region
            }
        }

        func addAnnotations(for places: [Place], on mapView: MKMapView) {
            mapView.removeAnnotations(annotations)
            annotations.removeAll()

            for place in places {
                guard let coordinate = place.coordinate else {
                    continue
                }

                let annotation = PlaceAnnotation(place: place, coordinate: coordinate)
                annotations.append(annotation)
            }

            mapView.addAnnotations(annotations)
        }

        func updateSelectionState(on mapView: MKMapView) {
            // Update visual state of annotations based on current selection
            for annotation in annotations {
                if let view = mapView.view(for: annotation) {
                    let isSelected = annotation.place.id == selectedPlace?.id
                    updateAnnotationView(view, isSelected: isSelected, place: annotation.place)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let placeAnnotation = view.annotation as? PlaceAnnotation else { return }

            // Update view appearance for selection
            updateAnnotationView(view, isSelected: true, place: placeAnnotation.place)

            // Dispatch to avoid "Publishing changes from within view updates" error
            DispatchQueue.main.async { [weak self] in
                self?.onPlaceSelect?(placeAnnotation.place)
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            guard let placeAnnotation = view.annotation as? PlaceAnnotation else { return }
            // Reset appearance
            updateAnnotationView(view, isSelected: false, place: placeAnnotation.place)
        }
        
        private func updateAnnotationView(_ view: MKAnnotationView, isSelected: Bool, place: Place) {
            // Remove existing subviews and animations
            view.subviews.forEach { $0.removeFromSuperview() }
            view.layer.removeAllAnimations()

            // Color coding based on category
            let color: UIColor
            switch place.category?.lowercased() {
            case let c where c?.contains("food") == true || c?.contains("restaurant") == true:
                color = UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0) // Orange
            case let c where c?.contains("cafe") == true || c?.contains("coffee") == true:
                color = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0) // Brown
            case let c where c?.contains("shop") == true:
                color = UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0) // Blue
            case let c where c?.contains("park") == true || c?.contains("nature") == true:
                color = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0) // Green
            default:
                color = UIColor(AppColors.mint)
            }

            let containerSize: CGFloat = isSelected ? 56 : 20
            let dotSize: CGFloat = isSelected ? 28 : 16
            let container = UIView(frame: CGRect(x: 0, y: 0, width: containerSize, height: containerSize))

            if isSelected {
                // Outer glow ring (pulsing)
                let glowSize: CGFloat = 56
                let glowView = UIView(frame: CGRect(
                    x: (containerSize - glowSize) / 2,
                    y: (containerSize - glowSize) / 2,
                    width: glowSize,
                    height: glowSize
                ))
                glowView.backgroundColor = color.withAlphaComponent(0.25)
                glowView.layer.cornerRadius = glowSize / 2

                // Add pulsing animation to glow
                let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
                pulseAnimation.duration = 1.2
                pulseAnimation.fromValue = 0.85
                pulseAnimation.toValue = 1.15
                pulseAnimation.autoreverses = true
                pulseAnimation.repeatCount = .infinity
                pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                glowView.layer.add(pulseAnimation, forKey: "pulse")

                // Add opacity animation
                let opacityAnimation = CABasicAnimation(keyPath: "opacity")
                opacityAnimation.duration = 1.2
                opacityAnimation.fromValue = 0.6
                opacityAnimation.toValue = 0.25
                opacityAnimation.autoreverses = true
                opacityAnimation.repeatCount = .infinity
                opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                glowView.layer.add(opacityAnimation, forKey: "opacity")

                container.addSubview(glowView)

                // Middle glow ring
                let middleGlowSize: CGFloat = 42
                let middleGlow = UIView(frame: CGRect(
                    x: (containerSize - middleGlowSize) / 2,
                    y: (containerSize - middleGlowSize) / 2,
                    width: middleGlowSize,
                    height: middleGlowSize
                ))
                middleGlow.backgroundColor = color.withAlphaComponent(0.35)
                middleGlow.layer.cornerRadius = middleGlowSize / 2
                container.addSubview(middleGlow)
            }

            // Main dot
            let dot = UIView(frame: CGRect(
                x: (containerSize - dotSize) / 2,
                y: (containerSize - dotSize) / 2,
                width: dotSize,
                height: dotSize
            ))
            dot.backgroundColor = color
            dot.layer.cornerRadius = dotSize / 2
            dot.layer.borderWidth = isSelected ? 4 : 3
            dot.layer.borderColor = UIColor.white.cgColor

            // Enhanced shadow for selected state
            dot.layer.shadowColor = color.cgColor
            dot.layer.shadowOpacity = isSelected ? 0.6 : 0.3
            dot.layer.shadowOffset = CGSize(width: 0, height: isSelected ? 4 : 2)
            dot.layer.shadowRadius = isSelected ? 8 : 4

            container.addSubview(dot)
            view.addSubview(container)
            view.frame = container.frame
            view.centerOffset = CGPoint(x: 0, y: -containerSize / 2)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let placeAnnotation = annotation as? PlaceAnnotation else { return nil }
            
            let identifier = "PlaceAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }
            
            let isSelected = placeAnnotation.place.id == selectedPlace?.id
            updateAnnotationView(annotationView!, isSelected: isSelected, place: placeAnnotation.place)
            
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
