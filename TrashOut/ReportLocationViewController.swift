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
    
    var currentLocation: CLLocationCoordinate2D!
    
    public var saveHandler: ((CLLocationCoordinate2D) -> Void)?
    
    // MARK: - Subviews
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup map view
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didSelectLocation(_:))))
        mapView.delegate = self
        loadInitRegion(for: currentLocation)
        addAnnotation(to: currentLocation)
        
        // Set title
        title = "event.create.setLocation".localized
        
        // Navigation item
        let saveButton = UIBarButtonItem(title: "global.done".localized, style: .plain, target: self, action: #selector(saveButtonWasClicked(_:)))
        navigationItem.setRightBarButton(saveButton, animated: true)
    }
    
    
    // MARK: - Actions
    
    @objc func didSelectLocation(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            currentLocation = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            addAnnotation(to: currentLocation)
        }
    }
    
    @objc func saveButtonWasClicked(_ sender: UIBarButtonItem) {
        self.saveHandler?(currentLocation)
    }
    
    
    // MARK: - Functions
    
    private func addAnnotation(to coordinate: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(Annotation(coordinate: coordinate))
    }
    
    /// Load init region for map view.
    private func loadInitRegion(for location: CLLocationCoordinate2D) {
        mapView.centerCoordinate = location
        
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
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
