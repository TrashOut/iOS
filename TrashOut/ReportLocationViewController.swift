//
//  ReportLocationViewController.swift
//  TrashOut
//
//  Created by Grünvaldský Dávid on 20/12/2018.
//  Copyright © 2018 TrashOut NGO. All rights reserved.
//

import UIKit
import MapKit

class ReportLocationViewController: UIViewController, MKMapViewDelegate {

    
    // MARK: - Properties
    
    var currentLocation: CLLocation!
    
    public var saveHandler: ((CLLocationCoordinate2D) -> Void)?
    
    // MARK: - Subviews
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup map view
        mapView.showsUserLocation = true
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didSelectLocation(_:))))
        mapView.delegate = self
        
        // Set title
        title = "event.create.setLocation".localized
        
        // Navigation item
        let saveButton = UIBarButtonItem(title: "global.done".localized, style: .plain, target: self, action: #selector(saveButtonWasClicked(_:)))
        navigationItem.setRightBarButton(saveButton, animated: true)
    }
    
    
    // MARK: - Actions
    
    @objc func didSelectLocation(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            
            addAnnotation(to: coordinate)
        }
    }
    
    @objc func saveButtonWasClicked(_ sender: UIBarButtonItem) {
        saveHandler?(currentLocation.coordinate)
    }
    
    // MARK: - Functions
    
    private func addAnnotation(to coordinate: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(Annotation(coordinate: coordinate))
    }
    
    
    // MARK: - Map view delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is Annotation {
            let reuseIdentifier = "annotation"
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView else {
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView.animatesDrop = true
                
                return annotationView
            }
            
            return annotationView
        }
        
        return nil
    }
    
    
    // MARK: - Custom annotation
    
    class Annotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        
        init(coordinate: CLLocationCoordinate2D) {
            self.coordinate = coordinate
        }
    }
}
