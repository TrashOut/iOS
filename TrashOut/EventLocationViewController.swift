//
// TrashOut
// Copyright 2017 TrashOut NGO. All rights reserved.
// License GNU GPLv3
//

/**
  * TrashOut is an environmental project that teaches people how to recycle
  * and showcases the worst way of handling waste - illegal dumping. All you need is a smart phone.
  *
  *
  * There are 10 types of programmers - those who are helping TrashOut and those who are not.
  * Clean up our code, so we can clean up our planet.
  * Get in touch with us: help@trashout.ngo
  *
  * Copyright 2017 TrashOut, n.f.
  *
  * This file is part of the TrashOut project.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * See the GNU General Public License for more details: <https://www.gnu.org/licenses/>.
 */

import Foundation
import UIKit
import MapKit

protocol HandleEventMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class EventLocationViewController: ViewController, MKMapViewDelegate {

    @IBOutlet var map: MKMapView!

    @IBOutlet var btnSearch: UIButton!

    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil

    weak var WriteCityAndStreetBackDelegate: WriteCityAndStreetBack? = nil
    weak var WriteLocatonBackDelegate: WriteLocationBack? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "event.create.setLocation".localized
        navigationItem.hidesBackButton = true

        let sendButton = UIBarButtonItem(title: "global.done".localized, style: .plain, target: self, action: #selector(savePlace))
        navigationItem.rightBarButtonItem = sendButton

        let origImage = #imageLiteral(resourceName: "Search")
        let tintedImage = origImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnSearch.setImage(tintedImage, for: .normal)
        btnSearch.tintColor = .white
        btnSearch.backgroundColor = Theme.current.color.green
        btnSearch.layer.cornerRadius = 10

        loadMapRegion()

        let customPinMap = UILongPressGestureRecognizer(target: self, action: #selector(setOwnPinToMap))
        customPinMap.minimumPressDuration = 0.2
        map.addGestureRecognizer(customPinMap)
    }

    // MARK: - Actions

    /**
    Go to previous controller
    */
    func savePlace() {
        _ = navigationController?.popViewController(animated: true)
    }

    /**
    Show initial map region
    */
    fileprivate func loadMapRegion() {
        let location = CLLocationCoordinate2D(latitude: LocationManager.manager.currentLocation.coordinate.latitude, longitude: LocationManager.manager.currentLocation.coordinate.longitude)
        map.centerCoordinate = location

        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        map.setRegion(region, animated: true)
    }

    @IBAction func activateSearch(_ sender: Any) {
		guard Reachability.isConnectedToNetwork() else {
			let ac = UIAlertController(title: "Error".localized, message: "global.noInternetConnection".localized, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "global.ok".localized, style: .cancel, handler: nil))
			present(ac, animated: true, completion: nil)
			return
		}
		guard let eventSearchTable = storyboard?.instantiateViewController(withIdentifier: "EventSearchTableController") as? EventSearchTableController else { fatalError("Could not dequeue storyboard with identifier: EventSearchTableController") }

		resultSearchController = UISearchController(searchResultsController: eventSearchTable)
		resultSearchController?.searchResultsUpdater = eventSearchTable

		let searchBar = resultSearchController!.searchBar
		searchBar.sizeToFit()
		searchBar.placeholder = "event.searchForLocation".localized
		map.addSubview(searchBar)

		resultSearchController?.hidesNavigationBarDuringPresentation = false
		resultSearchController?.dimsBackgroundDuringPresentation = true
		resultSearchController?.searchBar.becomeFirstResponder()
		definesPresentationContext = true

		eventSearchTable.map = map
		eventSearchTable.HandleEventMapSearchDelegate = self

    }

    /**
    User adds own pin to map
    */
    func setOwnPinToMap(_ gestureRecognizer: UIGestureRecognizer) {


        if gestureRecognizer.state == .began {
			map.removeAnnotations(map.annotations)

            let touchPoint = gestureRecognizer.location(in: map)
            let coordinates = map.convert(touchPoint, toCoordinateFrom: map)
            let annotation = UserOwnPin(title: "", subtitle: "", coordinate: coordinates)
            annotation.coordinate = coordinates

			let locationDelegate: WriteLocationBack? = self.WriteLocatonBackDelegate
			let adressDelegate: WriteCityAndStreetBack? = self.WriteCityAndStreetBackDelegate


            LocationManager.manager.resolveName(for: CLLocation.init(latitude: coordinates.latitude, longitude: coordinates.longitude)) { [weak locationDelegate, weak adressDelegate] (mark) in // dont call delegate using self (may be closed, but we need to resolve adress for delegates), weak capture delegates directly

				guard let name = mark else {
					adressDelegate?.writeCityAndStreetBack(value: "event.noAddressFound".localized)
					annotation.subtitle = "event.noAddressFound".localized
					return
				}

				locationDelegate?.writeLocationBack(value: annotation.coordinate)


                if let zip = name.subThoroughfare, let street = name.thoroughfare {
					adressDelegate?.writeCityAndStreetBack(value: street + " " + zip)
                    annotation.subtitle = street + " " + zip
                } else if name.subThoroughfare == nil, let street = name.thoroughfare {
					adressDelegate?.writeCityAndStreetBack(value: street)
                    annotation.subtitle = street
                } else if let subLocality = name.subLocality {
					adressDelegate?.writeCityAndStreetBack(value: subLocality)
					annotation.subtitle = subLocality
                } else if let locality = name.locality {
					adressDelegate?.writeCityAndStreetBack(value: locality)
                    annotation.subtitle = locality
                } else if let country = name.country {
					adressDelegate?.writeCityAndStreetBack(value: country)
                    annotation.subtitle = country
                } else {
					adressDelegate?.writeCityAndStreetBack(value: "event.noAddressFound".localized)
                    annotation.subtitle = "event.noAddressFound".localized
                }
            }
            map.addAnnotation(annotation)
        }
    }

    // MARK: - Map view Data source

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "OwnPin"

        if annotation is UserOwnPin {
            var view: MKPinAnnotationView

            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.animatesDrop = true

                return view
            }
            annotationView.annotation = annotation
            view = annotationView

            return view
        }

        return nil
    }



}

extension EventLocationViewController: HandleEventMapSearch {

    /**
    Drop pin according given placemark
    */
    func dropPinZoomIn(placemark: MKPlacemark) {
        map.removeAnnotations(map.annotations)

        selectedPin = placemark

        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name

        WriteLocatonBackDelegate?.writeLocationBack(value: placemark.coordinate)

        if let zip = placemark.subThoroughfare, let street = placemark.thoroughfare {
            WriteCityAndStreetBackDelegate?.writeCityAndStreetBack(value: street + " " + zip)
            annotation.subtitle = street + " " + zip
        } else if placemark.subThoroughfare == nil, let street = placemark.thoroughfare {
            WriteCityAndStreetBackDelegate?.writeCityAndStreetBack(value: street)
            annotation.subtitle = street
        } else if let subLocality = placemark.subLocality {
            WriteCityAndStreetBackDelegate?.writeCityAndStreetBack(value: subLocality)
            annotation.subtitle = subLocality
        } else if let locality = placemark.locality {
            WriteCityAndStreetBackDelegate?.writeCityAndStreetBack(value: locality)
            annotation.subtitle = locality
        } else if let country = placemark.country {
            WriteCityAndStreetBackDelegate?.writeCityAndStreetBack(value: country)
            annotation.subtitle = country
        } else {
            WriteCityAndStreetBackDelegate?.writeCityAndStreetBack(value: "event.noAddressFound".localized)
            annotation.subtitle = "event.noAddressFound".localized
        }

        map.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        map.setRegion(region, animated: true)
    }

}

class UserOwnPin: NSObject, MKAnnotation {

    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D

    init(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
