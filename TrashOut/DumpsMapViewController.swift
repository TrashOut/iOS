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

protocol SendDataForMapFilter {
    func sendDataForMapFilter(status: [String], update: Bool, size: String, type: [String], timeTo: String, timeFrom: String)
}

class DumpsMapViewController: ViewController, MKMapViewDelegate, TrashFilterDelegate {

	// MARK: - Local data types

	/**
	Map to setup for restoring
	*/
	struct MapRestoration {
		var frame: CGRect!
		var region: MKCoordinateRegion!
		var annotations: [MKAnnotation]!


		static func store(map: MKMapView) -> MapRestoration {
			var r = MapRestoration()
			r.frame = map.frame
			r.region = map.region
			r.annotations = map.annotations
			return r
		}
	}

	// MARK: - UI

	@IBOutlet var map: MKMapView!
    @IBOutlet var btnLocationWrapper: UIView!
    @IBOutlet var btnLocation: UIButton!
    @IBOutlet var btnAddDumpWrapper: UIView!
    @IBOutlet var btnAddDump: UIButton!

	// MARK: - Locals

    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil

	var mapSpan: MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: 1, longitudeDelta: 1)

	var manager: DumpsMapManager = DumpsMapManager()

	/// Cells on map, adds markers on change
	var cells: [GeoCell] = [] {
		didSet {
			self.addMarkers(for: cells, zoomScale: map.zoomScale)
		}
	}

	/// Current loaded zoom level at map, reloads annotations for change
	var currentCellsZoomLevel: Int? {
		didSet {
			self.cells.removeAll()
			let current = map.annotations
			map.removeAnnotations(current)
		}
	}

	/// State for restoring map
	var mapRestoration: MapRestoration?

	/// Current map rect for which there are annotations on map
	var currentLoadedRect: MKMapRect?

	var filter: TrashFilter = TrashFilter.cachedFilter {
		didSet {
            // [weak self]
            self.manager = DumpsMapManager()
            self.reload()
		}
	}
//    fileprivate var trashStatus: [String]!
//    fileprivate var trashTypes: [String]!
//    fileprivate var trashSize: String!
//    fileprivate var updateNeeded = true
//    fileprivate var timeBoundaryTo: String!
//    fileprivate var timeBoundaryFrom: String!

	// MARK: - View controller lifecycle

	/**
	Fetch current location, setup buttons design
	*/
	override func viewDidLoad() {
		super.viewDidLoad()
		LocationManager.manager.refreshCurrentLocationIfNeeded { [weak self] (location) in
			guard LocationManager.manager.fetchedAnyLocation else {
				self?.showWithSettings(message: "global.geoTurnedOff".localized)
				return
			}
			guard let mapSpan = self?.mapSpan else { return }
			let region = MKCoordinateRegion.init(center: location.coordinate, span: mapSpan)
			self?.map.region = region
		}
        let filter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(goToFilter))
        parent?.navigationItem.rightBarButtonItem = filter
        setMapButton(image: "Location", button: btnLocation)
	}

    override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
        //btnLocationWrapper.shadow = true
        btnAddDumpWrapper.circleButtonShadow = true
        btnAddDump.layer.cornerRadius = 0.5 * btnAddDump.bounds.height
        btnAddDump.layer.masksToBounds = true
    }

	/**
	Drop map to free some memory
	*/
	override func viewWillDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
        
		//self.cleanUpMap()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setCurrentLocation(animated: false)
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		print("Trash map memory warning")
		//manager.purgeCache()
	}

	/**
	Setting for search button and user location button
	*/
	fileprivate func setMapButton(image: String, button: UIButton) {
		let origImage = UIImage(named: image)
		let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
		button.setImage(tintedImage, for: .normal)
		button.tintColor = .white
		button.backgroundColor = Theme.current.color.green
		button.layer.cornerRadius = 10
	}

	/**
	Re-setup map using data stored in restoration
	*/
	private func restoreMap() {
		guard let restoration = mapRestoration else {return}
		self.map = MKMapView.init(frame: restoration.frame)
		self.view.insertSubview(self.map, at: 0)
		self.map.translatesAutoresizingMaskIntoConstraints = false
		self.map.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
		self.map.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
		self.map.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
		self.map.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
		self.map.delegate = self
		self.map.setRegion(restoration.region, animated: false)
		self.map.addAnnotations(restoration.annotations)
	}



	/**
	Store map data in restoration and throw away map
	*/
	private func cleanUpMap() {
		self.mapRestoration = MapRestoration.store(map: self.map)

		switch self.map.mapType {
		case .hybrid:
			self.map.mapType = .standard
			break
		case .standard:
			self.map.mapType = .hybrid
			break
		default:
			break
		}
		self.map.showsUserLocation = false
		self.map.delegate = nil
		self.map.removeFromSuperview()
		self.map = nil
	}

	// MARK: - Actions

    /**
    Shows user current location
    */
    @IBAction func showLocation(_ sender: Any) {
        self.setCurrentLocation(animated: true)
    }

    /**
    Go to filter
    */
    @objc func goToFilter() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DumpsFilterViewController") as? DumpsFilterViewController else { fatalError("Could not dequeue storyboard with identifier: DumpsFilterViewController") }
		vc.delegate = self
//        vc.ShowFilterDataDelegate = self
//        vc.SendDataForMapFilterDelegate = self
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }

	func filterDidSet(filter: TrashFilter) {
		self.filter = filter
	}

    /**
    Add new dump
    */
    @IBAction func addNewDump(_ sender: Any) {
        guard Reachability.isConnectedToNetwork() else {
            self.show(error: NetworkingError.noInternetConnection)
        
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Report", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "Report")
        present(vc, animated: true, completion: nil)
    }

	// MARK: - Map handling

	// MARK: Helpers

	/// Extended rect for map for quite stable scrolling map
	func extendedRect(for rect: MKMapRect) -> MKMapRect {
        let enchangeRect: Double = 2 // calc for rect + enchangeRect*rect surrounding
        return MKMapRect.init(
            origin: MKMapPoint.init(x: rect.origin.x - (rect.size.width*enchangeRect/2), y: rect.origin.y - (rect.size.height*enchangeRect/2)),
            size: MKMapSize.init(width: rect.size.width*(enchangeRect + 1), height: rect.size.height*(enchangeRect + 1))
        )
	}
    
    private func setCurrentLocation(animated: Bool) {
        let newLocation = CLLocationCoordinate2D(latitude: LocationManager.manager.currentLocation.coordinate.latitude, longitude: LocationManager.manager.currentLocation.coordinate.longitude)
        map.centerCoordinate = newLocation
        
        let region = MKCoordinateRegion(center: newLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        map.setRegion(region, animated: animated)
    }

	/**
	Add and remove markers on map

	Called at `cells didset`
	*/
	func addMarkers(for cells: [GeoCell], zoomScale zoom: Double) {
		let rect: MKMapRect = currentLoadedRect ?? self.extendedRect(for: map.visibleMapRect)
		/// Add and remove markers from map
		manager.markers(for: cells, mapRect: rect, zoomScale: zoom) { [weak self] (newmarkers) in
			guard let ss = self else { return }
			let current = ss.map.annotations
            /*
            let remove = current.filter { (m) -> Bool in
				guard let m = m as? ClusterMapAnnotation else {return true}
				return !cells.contains(where: { (cell) -> Bool in
					m.cell == cell.geocell
				})
			}*/
			ss.map.removeAnnotations(current)
			ss.map.addAnnotations(newmarkers)
			ss.map.setNeedsLayout()
			ss.map.layoutIfNeeded()
		}
	}


	func reload() {
		guard let mapView = self.map else {return}
		let zoom = mapView.zoomLevel
		self.currentLoadedRect = nil
		if zoom != self.currentCellsZoomLevel {
			self.currentCellsZoomLevel = zoom
		}
		let newrect = self.extendedRect(for: mapView.visibleMapRect)
		manager.cells(withZoomLevel: zoom, region: MKCoordinateRegion.init(newrect), filter: self.filter, success: { [weak self] (cells) in
			self?.cells = cells
			self?.currentLoadedRect = newrect
			}, failure: { [weak self] (error) in
			self?.showDataLoadError(error)
		})

	}

	func showDataLoadError(_ error: Error?) {

		let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 1))
		view.backgroundColor = Theme.current.color.red
		view.alpha = 0
		self.view.addSubview(view)
		UIView.transition(with: self.view, duration: 0.35, options: .transitionCrossDissolve, animations: {
			view.alpha = 1
			}, completion: nil)
		UIView.animate(withDuration: 0.35, delay: 5, options: [], animations: {
			view.alpha = 0
			}) { (_) in
				view.removeFromSuperview()
		}

	}
    
    
    // MARK: Map view delegate
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		let zoom = mapView.zoomLevel
		if zoom != self.currentCellsZoomLevel {
			self.currentCellsZoomLevel = zoom
		} else if let cr = currentLoadedRect, cr.contains(mapView.visibleMapRect) {
			return // no need to load anything
		}
        
		let newrect = self.extendedRect(for: mapView.visibleMapRect)
        
		manager.cells(withZoomLevel: zoom, region: MKCoordinateRegion.init(newrect), filter: self.filter, success: { [weak self] (cells) in
            self?.cells = cells
            self?.currentLoadedRect = newrect
            }, failure: { [weak self] error in
            self?.showDataLoadError(error)
        })
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if let ma = annotation as? MapAnnotation {
			return ma.getView(for: mapView)
		} else {
			return nil
		}
	}

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if let annotation = view.annotation as? MapAnnotation {
            guard let id = annotation.id else { return }

            let selectedAnnotation = view.annotation

            for annotation in mapView.annotations {
                if annotation.isEqual(selectedAnnotation) {
                    let storyboard = UIStoryboard.init(name: "Dumps", bundle: Bundle.main)
                    guard let vc = storyboard.instantiateViewController(withIdentifier: "DumpsDetailViewController") as? DumpsDetailViewController else { fatalError("Could not dequeue storyboard with identifier: DumpsDetailViewController") }
                    vc.id = id
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
