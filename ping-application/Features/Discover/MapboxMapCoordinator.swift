//
//  MapboxMapCoordinator.swift
//  PingNative
//
//  Coordinator for MapboxMapView handling MapKit delegate methods
//

import SwiftUI
import MapKit
import UIKit

class MapboxMapCoordinator: NSObject, MKMapViewDelegate {
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
        for annotation in annotations {
            if let view = mapView.view(for: annotation) {
                let isSelected = annotation.place.id == selectedPlace?.id
                updateAnnotationView(view, isSelected: isSelected, place: annotation.place)
            }
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let placeAnnotation = view.annotation as? PlaceAnnotation else { return }

        updateAnnotationView(view, isSelected: true, place: placeAnnotation.place)

        DispatchQueue.main.async { [weak self] in
            self?.onPlaceSelect?(placeAnnotation.place)
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let placeAnnotation = view.annotation as? PlaceAnnotation else { return }
        updateAnnotationView(view, isSelected: false, place: placeAnnotation.place)
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

    func updateAnnotationView(_ view: MKAnnotationView, isSelected: Bool, place: Place) {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.layer.removeAllAnimations()

        let color = colorForCategory(place.category)
        let containerSize: CGFloat = isSelected ? 56 : 20
        let dotSize: CGFloat = isSelected ? 28 : 16
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerSize, height: containerSize))

        if isSelected {
            addGlowEffects(to: container, containerSize: containerSize, color: color)
        }

        let dot = createDot(containerSize: containerSize, dotSize: dotSize, color: color, isSelected: isSelected)
        container.addSubview(dot)
        view.addSubview(container)
        view.frame = container.frame
        view.centerOffset = CGPoint(x: 0, y: -containerSize / 2)
    }

    private func colorForCategory(_ category: String?) -> UIColor {
        switch category?.lowercased() {
        case let c where c?.contains("food") == true || c?.contains("restaurant") == true:
            return UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
        case let c where c?.contains("cafe") == true || c?.contains("coffee") == true:
            return UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        case let c where c?.contains("shop") == true:
            return UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)
        case let c where c?.contains("park") == true || c?.contains("nature") == true:
            return UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        default:
            return UIColor(AppColors.mint)
        }
    }

    private func addGlowEffects(to container: UIView, containerSize: CGFloat, color: UIColor) {
        let glowSize: CGFloat = 56
        let glowView = UIView(frame: CGRect(
            x: (containerSize - glowSize) / 2,
            y: (containerSize - glowSize) / 2,
            width: glowSize,
            height: glowSize
        ))
        glowView.backgroundColor = color.withAlphaComponent(0.25)
        glowView.layer.cornerRadius = glowSize / 2

        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.2
        pulseAnimation.fromValue = 0.85
        pulseAnimation.toValue = 1.15
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowView.layer.add(pulseAnimation, forKey: "pulse")

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 1.2
        opacityAnimation.fromValue = 0.6
        opacityAnimation.toValue = 0.25
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowView.layer.add(opacityAnimation, forKey: "opacity")

        container.addSubview(glowView)

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

    private func createDot(containerSize: CGFloat, dotSize: CGFloat, color: UIColor, isSelected: Bool) -> UIView {
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
        dot.layer.shadowColor = color.cgColor
        dot.layer.shadowOpacity = isSelected ? 0.6 : 0.3
        dot.layer.shadowOffset = CGSize(width: 0, height: isSelected ? 4 : 2)
        dot.layer.shadowRadius = isSelected ? 8 : 4
        return dot
    }
}
