//
//  UpdateLocationViewController.swift
//  TrashOut
//
//  Created by Juraj Macák on 25/05/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import UIKit
import MapKit

protocol UpdateLocationViewControllerDelegate: AnyObject {

    func updateLocationDidSelect(_ controller: UpdateLocationViewController, coordinates: CLLocationCoordinate2D)

}

class UpdateLocationViewController: UIViewController {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var mkMapView: MKMapView!

    weak var delegate: UpdateLocationViewControllerDelegate?
    private var customCoordinates: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupMapView()
    }

}

// MARK: - IBActions

extension UpdateLocationViewController {

    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmButtonPressed(_ sender: Any) {
        if let coordinates = self.customCoordinates {
            delegate?.updateLocationDidSelect(self, coordinates: coordinates)
        }

        dismiss(animated: true, completion: nil)
    }

}

// MARK: - Private

extension UpdateLocationViewController {

    private func setupView() {
        confirmButton.backgroundColor = UIColor.theme.green
    }

    private func setupMapView() {
        mkMapView.delegate = self

        let coords = LocationManager.manager.currentLocation.coordinate
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion.init(center: coords, span: span)

        mkMapView.setRegion(region, animated: true)
    }

}

// MARK: - Map View Delegate

extension UpdateLocationViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        customCoordinates = mapView.centerCoordinate
    }

}
