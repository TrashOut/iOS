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

import UIKit
import MapKit
import CoreLocation

class EventDumpsViewController: ViewController, MKMapViewDelegate {

    @IBOutlet var loadingView: UIView!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var map: MKMapView!

    var coords: CLLocationCoordinate2D!
    var numberOfSelectedDumps = 0
    var trashIds = [Int]()
    var count = 1
    var trashes: [Trash] = [] {
        didSet {
            loadingView.isHidden = true
            activityIndicator.stopAnimating()
            addAnnotationsToMap()
        }
    }

    var WriteNumberOfSelectedDumbsBackDelegate: WriteNumberOfSelectedDumpsBack? = nil
    
    private var locations = [["id": Int(), "latitude": Double(), "longitude": Double()]]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "event.nearbyDumps".localized
        navigationItem.hidesBackButton = true

        let sendButton = UIBarButtonItem(title: "global.done".localized, style: .plain, target: self, action: #selector(saveChoice))
        navigationItem.rightBarButtonItem = sendButton

        setStartingRegion(coords: coords)

        loadData(page: 1)

        let annotation = MeetingPoint(title: "event.meetingPoint".localized, coordinate: coords)
        map.addAnnotation(annotation)
    }

    // MARK: - Networking

    fileprivate func loadData(page: Int) {
        let trashStatus = ["stillHere", "less", "more"]

        Networking.instance.trashes(position: coords, status: trashStatus, size: nil, type: nil, timeTo: nil, timeFrom: nil, limit: 100, page: page) { [weak self] (trashes, error) in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                self?.show(message: "global.fetchError".localized)
                self?.loadingView.isHidden = true
                self?.activityIndicator.stopAnimating()
                return
            }
            guard let newTrashes = trashes else { return }
            self?.trashes += newTrashes
        }
    }

    // MARK: - Actions

    /**
    Go to previous controller
    */
    func saveChoice() {
        _ = navigationController?.popViewController(animated: true)
    }

    /**
    Set load region according saved meeting point
    */
    fileprivate func setStartingRegion(coords: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(coords, span)
        map.setRegion(region, animated: true)
    }

    /**
    Add annotations to map
    */
    fileprivate func addAnnotationsToMap() {
        for trash in trashes {
            locations.append(["id": trash.id, "latitude": trash.gps?.lat ?? 0.0, "longitude": trash.gps?.long ?? 0.0])
        }

        for location in locations {
            let annotation = MapAnnotation()
            annotation.id = location["id"] as! Int!
            annotation.coordinate = CLLocationCoordinate2D(latitude: location["latitude"] as! Double, longitude: location["longitude"] as! Double)
            map.addAnnotation(annotation)
        }
    }

    // MARK: - Map View

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Point"

        if annotation is MeetingPoint {
            var view: MKPinAnnotationView

            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) else {

                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true

                return view
            }
            annotationView.annotation = annotation
            view = annotationView as! MKPinAnnotationView

            return view
        }

        let identifier2 = "Trash"

        if annotation is MapAnnotation {

            var view: MKAnnotationView

            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier2) else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier2)

                annotationViewImage(view: view, image: "ReportedEmpty")

                if let annotation = view.annotation as? MapAnnotation {
                    guard let id = annotation.id else { return view }
                    
                    if !trashIds.isEmpty {
                        for i in 0...trashIds.count - 1 {
                            if trashIds[i] == id {
                                annotationViewImage(view: view, image: "ReportedSelected")
                            }
                        }
                    }
                }

                return view
            }
            annotationView.annotation = annotation
            view = annotationView

            return view
        }

        return nil
    }

    // MARK: - Map view Delegate

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MapAnnotation {
            guard let id = annotation.id else { return }

            let selectedAnnotation = view.annotation
            let emptyImage = #imageLiteral(resourceName: "ReportedEmpty")

            for annotation in mapView.annotations {
                if annotation.isEqual(selectedAnnotation) {
                    if view.image == emptyImage {
                        annotationViewImage(view: view, image: "ReportedSelected")
                        numberOfSelectedDumps += 1
                        trashIds.append(id)
                        map.deselectAnnotation(annotation, animated: false)
                    } else {
                        annotationViewImage(view: view, image: "ReportedEmpty")
                        numberOfSelectedDumps -= 1
                        trashIds = trashIds.filter{ $0 != id }
                        map.deselectAnnotation(annotation, animated: false)
                    }
                }
            }
        }

//        if numberOfSelectedDumps == 0 {
//            WriteNumberOfSelectedDumbsBackDelegate?.writeNumberOfSelectedDumpsBack(value: "event.create.youSelectedDumps_X".localized(numberOfSelectedDumps), selectedDumps: trashIds, numberOfSelectedDumps: numberOfSelectedDumps)
//        } else if numberOfSelectedDumps == 1 {
//            WriteNumberOfSelectedDumbsBackDelegate?.writeNumberOfSelectedDumpsBack(value: "event.create.youSelectedDumps_X".localized(numberOfSelectedDumps), selectedDumps: trashIds, numberOfSelectedDumps: numberOfSelectedDumps)
//        } else {
            WriteNumberOfSelectedDumbsBackDelegate?.writeNumberOfSelectedDumpsBack(value: "event.create.youSelectedDumps_X".localized(numberOfSelectedDumps), selectedDumps: trashIds, numberOfSelectedDumps: numberOfSelectedDumps)
//        }
    }

    /**
    Set empty or selected image for annotation view image
    */
    private func annotationViewImage(view: MKAnnotationView, image: String) {
        view.image = UIImage(named: image)
        view.frame.size = CGSize(width: 40.0, height: 40.0)
        view.layer.cornerRadius = 0.5 * (view.bounds.height)
        view.layer.masksToBounds = true
    }

}

class MeetingPoint: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
