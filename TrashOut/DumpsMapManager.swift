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
import CoreLocation
import MapKit
import Cache

/**
Load cells from api

Handle some clustering
*/
class DumpsMapManager: ClusteringManagerDelegate {

	static let debug: Bool = true
	static func log(_ m: String) {
		print(m)
	}

	/// Clustering handler
	let clusteringManager: ClusteringManager = ClusteringManager()

	init() {
		clusteringManager.delegate = self
	}

	// MARK: - Clustering delegate

	func cellSizeFactor(_ coordinator: ClusteringManager) -> CGFloat {
		return 2
	}

	func createClusterAnnotation(coords: CLLocationCoordinate2D, annotations: [MKAnnotation]) -> AnnotationCluster {
		let ann = ClusterMapAnnotation.init()
		ann.coordinate = coords
		ann.count = annotations.count
		ann.annotations = annotations
		return ann
	}

	// MARK: - Data remote loading


	/**
	Get geocells for give region
	
	Check cache and if not found load from remote
	*/
	func cells(withZoomLevel zoom: Int, region: MKCoordinateRegion, filter: TrashFilter, success: @escaping ([GeoCell])->(), failure: @escaping (Error?)->()) {
		DumpsMapManager.log("Loading cells for region \(region) with zoom \(zoom)")


		let nw = CLLocationCoordinate2DMake(
			region.center.latitude - region.span.latitudeDelta/2,
			region.center.longitude - region.span.longitudeDelta/2
		)
        
		let se = CLLocationCoordinate2DMake(
			region.center.latitude + region.span.latitudeDelta/2,
			region.center.longitude + region.span.longitudeDelta/2
		)
        
		let resolution = GeocellResolution.resolution(for: zoom)
		let geocells = self.geocells(between: nw, southeast: se, with: resolution.rawValue)
        let loadingClosure = { (f: ((_ geocells: [String], _ zoom: Int, _ filter: TrashFilter, _ success: @escaping ([GeoCell]) -> Void, _ failure: @escaping (Error?) -> Void) -> Void)) -> Void in
            f(geocells, zoom, filter, success, failure)
        }
        
        zoom <= 9
            ? loadingClosure(loadZoompoints)
            : loadingClosure(loadTrashes)
	}

	// MARK: Load from network

	func loadZoompoints(for cells: [String], zoom: Int, filter: TrashFilter,  success: @escaping ([GeoCell]) -> (), failure: @escaping (Error?)->()) {
		guard cells.count > 0 else {
			success([])
			return
		}
		Networking.instance.zoompoints(geocells: cells, zoom: zoom, filter: filter, callback: { (cells, error) in
			if let error = error {
				failure(error)
				if error.isNetworkConnectionError {
					success([])
				}
			} else if let cells = cells {
				success(cells)
			} else {
				success([])
			}
		})
	}

	func loadTrashes(for cells: [String], zoomLevel zoom: Int, filter: TrashFilter,  success: @escaping ([GeoCell]) -> (), failure: @escaping (Error?)->()) {
		guard cells.count > 0, let resolution = cells.first?.count else {
			success([])
			return
		}
        
        UserManager.instance.tokenHeader { tokenHeader in
        
		Networking.instance.trashes(for: cells, zoomLevel: zoom, filter: filter, callback: { (trashpoints,error) in
                if let error = error, !error.isNetworkConnectionError {
                    failure(error)
                } else if let trashpoints = trashpoints {
                    if let error = error {
                        failure(error)
                    }
                    var cells: [String: GeoCell] = [:]
                    for trash in trashpoints {
                        guard let coords = trash.coords else {continue}
                        let cellname = self.cell(for: coords, resolution: resolution)
                        if let cell = cells[cellname] {
                            if cell.trashes == nil {
                                cell.trashes = []
                            }
                            cell.trashes?.append(trash)
                        } else {
                            let cell = GeoCell()
                            cell.geocell = cellname
                            cells[cellname] = cell
                            cell.trashes = []
                            cell.trashes?.append(trash)
                        }
                    }
                    success(Array(cells.values))
                } else {
                    success([])
                }
            })
        }
	}

	// MARK: - Markers for geocell

	fileprivate var loadedCells: [GeoCell] = []

	/// Markers for given cells
	func markers(for cells: [GeoCell], mapRect rect: MKMapRect, zoomScale: Double, callback: @escaping ([MKAnnotation]) -> ()) {
        
		DispatchQueue.global(qos: .background).async {
			var markers: [MKAnnotation] = []
			for c in cells {
				let m = self.markers(for: c, mapRect: rect, zoomScale: zoomScale)
				markers.append(contentsOf: m)
			}
			DispatchQueue.main.async {
				callback(markers)
			}
		}
	}

	/// Markers for given cell
	fileprivate func markers(for cell: GeoCell, mapRect rect: MKMapRect, zoomScale: Double) -> [MKAnnotation] {
		// trashes
		if let trashes = cell.trashes, trashes.count > 0 {
			return clusteredTrashMarkers(cell: cell, mapRect: rect, zoomScale: zoomScale)
		}
		// server cluster
		guard let m = self.marker(for: cell) else { return [] }
		return [m]
	}

	/// Clustered marker from server
	fileprivate func marker(for cell: GeoCell) -> MKAnnotation? {
		guard let coords = cell.coords else { return nil }
		guard let ann = self.createClusterAnnotation(coords: coords, annotations: []) as? ClusterMapAnnotation else { return nil }
		ann.cell = cell.geocell

		ann.count = cell.count ?? 0
		ann.reported = cell.remains ?? 0
		ann.cleaned = cell.cleaned ?? 0
		ann.updateNeeded = cell.updateNeeded ?? 0
		return ann
	}

	/// Markers clustered at client
	fileprivate func clusteredTrashMarkers(cell: GeoCell, mapRect rect: MKMapRect, zoomScale: Double) -> [MKAnnotation] {
		guard let trashes = cell.trashes else { return [] }
		/// if cell data are loaded in clustering, just return markers
		if loadedCells.contains(where: { (c: GeoCell) -> Bool in
			return c.geocell == cell.geocell
		}) {
			return clusteringManager.clusteredAnnotations(for: rect, withZoomScale: zoomScale)
		}
		/// Create map annotations for trashes
		let annotations = self.annotations(for: trashes)

		/// If on same map level append, else clean up and set
		if let cellLevel = loadedCells.first?.geocell?.count, cellLevel == cell.geocell?.count {
			clusteringManager.addAnnotations(annotations)
			loadedCells.append(cell)
		} else {
			loadedCells = []
			clusteringManager.setAnnotations(annotations)
		}
		return clusteringManager.clusteredAnnotations(for: rect, withZoomScale: zoomScale)
	}

	/// Not clustered annotations for list of trashes
	fileprivate func annotations(for trashes: [TrashPoint]) -> [TrashMapAnnotation] {
		var annotations: [TrashMapAnnotation] = []
		for t in trashes {
			guard let coords = t.coords else {continue}
			let ann = TrashMapAnnotation()
			ann.status = Trash.DisplayStatus.getStatus(trash: t)
            ann.id = t.id
			ann.coordinate = coords
            annotations.append(ann)
		}
		return annotations
	}

	// MARK: - Geocell helpers

	enum GeocellResolution: Int {
		case zero
		case km5000
		case km2000
		case km500
		case km128
		case km32
		case km8
		case km2
		case m500
		case m126
		case m30
		case m7
		case cm
		case mm

		static func resolution(for zoomLevel: Int) -> GeocellResolution {
			let zoom = zoomLevel - 1
			switch (zoom) {
				case Int.min..<1: return .zero
				case 1..<5: return .km2000
				case 5,6: return .km500
				case 7,8: return .km128
				case 9,10: return .km32
				/*
				case 11,12: return .km8
				case 13,14: return .km2
				case 15,16: return .m500
				case 17,18: return .m126
				case 19..<22: return .km8
				*/
				default: return .km32 //.km500 // stuck with 32km as resolution for most detailed cell
			}
		}

	}


	let alphabet = "0123456789abcdef"

	func cell(for coords: CLLocationCoordinate2D, resolution: Int) -> String {
		var north: Double = 90
		var south: Double = -90
		var east: Double = 180
		var west: Double = -180
		var cell = ""

		let gridSize: Double = 4
		while cell.count < resolution {
			let subcellLonSpan = (east - west) / gridSize
			let subcellLatSpan = (north - south) / gridSize
			let x = min((gridSize * (coords.longitude - west) / (east - west)), gridSize - 1)
			let y = min((gridSize * (coords.latitude - south) / (north - south)), gridSize - 1)
			let xi = Int(x)
			let yi = Int(y)
			let char = self.cellChar(xi, yi)
			//let rev = self.index(for: char)
			//print("\(xi), \(yi) -> \(char) -> \(rev.x) \(rev.y) ")
			//cell.append(self.cellChar(xi, yi))
			cell.append(char)
			south = south + subcellLatSpan * Double(yi);
			north = south + subcellLatSpan;
			west = west + subcellLonSpan * Double(xi);
			east = west + subcellLonSpan;

		}
		return cell
	}

	func cellSize(for coords: CLLocationCoordinate2D, resolution: Int) -> (latitudeDelta: Double, longitudeDelta: Double) {
		var north: Double = 90
		var south: Double = -90
		var east: Double = 180
		var west: Double = -180
		var cell = ""

		let gridSize: Double = 4
		while cell.count < resolution {
			let subcellLonSpan = (east - west) / gridSize
			let subcellLatSpan = (north - south) / gridSize
			let x = min((gridSize * (coords.longitude - west) / (east - west)), gridSize - 1)
			let y = min((gridSize * (coords.latitude - south) / (north - south)), gridSize - 1)
			let xi = Int(x)
			let yi = Int(y)
			let char = self.cellChar(xi, yi)
			//let rev = self.index(for: char)
			//print("\(xi), \(yi) -> \(char) -> \(rev.x) \(rev.y) ")
			cell.append(char)
			south = south + subcellLatSpan * Double(yi);
			north = south + subcellLatSpan;
			west = west + subcellLonSpan * Double(xi);
			east = west + subcellLonSpan;

		}
		return (latitudeDelta: abs(north-south), longitudeDelta: abs(east - west))
	}

	/**
	Test method for faster generation of cells
	*/
	func geocells(between northwest: String, southeast: String) -> [String] {
		let start = northwest.commonPrefix(with: southeast)
		print("same: \(start)")
		let differentCount = northwest.count - start.characters.count
		var cells: [String] = [start]

		for _ in 0..<differentCount {
			// append all letters
			var newcells: [String] = []
			for string in cells {
				for j in 0..<alphabet.count {
					newcells.append(string + "\(alphabet[alphabet.index(alphabet.startIndex, offsetBy: j)])")
				}
			}
			cells = newcells
		}

		//print(cells)
		return cells
	}

	func geocells(between northwest: CLLocationCoordinate2D, southeast: CLLocationCoordinate2D, with resolution: Int) -> [String] {
		let span = MKCoordinateSpan.init(latitudeDelta: southeast.latitude - northwest.latitude, longitudeDelta: southeast.longitude - northwest.longitude)

		let checkCoords = CLLocationCoordinate2DMake(northwest.latitude,northwest.longitude)
		let size = self.cellSize(for: checkCoords, resolution: resolution)



		var latCount = Int(ceil(abs(span.latitudeDelta) / size.latitudeDelta)) * 4
		var longCount = Int(ceil(abs(span.longitudeDelta) / size.longitudeDelta)) * 4
		if latCount == 0 {latCount = 1}
		if longCount == 0 {longCount = 1}

		var cells: [String] = []

		for i in 0..<latCount {
			for j in 0..<longCount {
				let coords = CLLocationCoordinate2DMake(
					northwest.latitude + Double(i) * (span.latitudeDelta / Double(latCount)),
					northwest.longitude + Double(j) * (span.longitudeDelta / Double(longCount))
				)
				let cell = self.cell(for: coords, resolution: resolution)
				cells.append(cell)
			}
		}
		cells = Array(Set(cells))
		return cells
	}

	/// Reverse rect generation from cell
	///
	/// - TODO: test me, seems it did not works
//	func rect(for cell: String) -> MKMapRect {
//		//let point = MKMapPointForCoordinate(coords)
//		let gridSize: Double = 4
//		var north: Double = 90
//		var south: Double = -90
//		var east: Double = 180
//		var west: Double = -180
//		for i in 0..<cell.characters.count {
//			let subcellLonSpan = (east - west) / gridSize
//			let subcellLatSpan = (north - south) / gridSize
//			let x = min((gridSize * (coords.longitude - west) / (east - west)), gridSize - 1)
//			let y = min((gridSize * (coords.latitude - south) / (north - south)), gridSize - 1)
//			let index = self.index(for: cell[cell.characters.index(cell.characters.startIndex, offsetBy: i)])
//			let xi = index.x
//			let yi = index.y
//			south = south + subcellLatSpan * Double(yi);
//			north = south + subcellLatSpan;
//			west = west + subcellLonSpan * Double(xi);
//			east = west + subcellLonSpan;
//		}
//		let width = east - west
//		let height = north - south
//
//		let coords = CLLocationCoordinate2DMake((west + east) / 2, (north + south)/2)
//		let span = MKCoordinateSpanMake(width, height)
//		let region = MKCoordinateRegionMake(coords, span)
//
//		return MKMapRectForCoordinateRegion(region: region)
//	}

	func MKMapRectForCoordinateRegion(region: MKCoordinateRegion) -> MKMapRect {
		let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
		let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))

		let a = MKMapPoint.init(topLeft)
		let b = MKMapPoint.init(bottomRight)

		return MKMapRect(origin: MKMapPoint(x: min(a.x, b.x), y: min(a.y, b.y)), size: MKMapSize(width: abs(a.x - b.x), height: abs(a.y - b.y)))
	}

	func cellChar(_ x: Int, _ y: Int) -> Character {
		let a: Int = (y & 2) << 2
		let b: Int = (x & 2) << 1
		let c: Int = (y & 1) << 1
		let d: Int = (x & 1) << 0
		let index: Int = a | b | c | d
		return alphabet[alphabet.index(alphabet.startIndex, offsetBy: index)]
	}

	func index(for char: Character) -> (x: Int, y: Int) {
		let index = alphabet.index(of: char)!
		let val = alphabet.distance(from: alphabet.startIndex, to: index)
		// (y & 2) << 2 // 10 << 2 // 1000
		// (y & 1) << 1 // 1 << 1 // 10
		let y = (val & 8) >> 2 | (val & 2) >> 1
		// (x & 2) << 1 // 10 << 1 // 100
		// (x & 1) << 0 // 1 << 0 // 1
		let x = (val & 4) >> 1 | (val & 1)
		return (x: x, y: y)
	}

}

extension MKMapView {

	fileprivate func longitudeToPixelSpace(_ longitude: Double) -> Double {
		let offset: Double = 268435456
		let radius: Double = 85445659.44705395
		return round(offset + radius * longitude * Double.pi / 180.0)
	}

	/// Get current zoom level of map
	var zoomLevel: Int {
		get {
			let r = region
			let centerX = self.longitudeToPixelSpace(r.center.longitude)
			let topLeftX = self.longitudeToPixelSpace(r.center.longitude - r.span.longitudeDelta/2)
			let scaledMapWidth = (centerX - topLeftX) * 2
			let mapsize = self.bounds.size
			let zoomScale = scaledMapWidth / Double(mapsize.width)
			let zoomExp = log(zoomScale) / log(2)
			let zoomLevel = 20 - zoomExp
			return Int(zoomLevel) + 2
		}
	}

	var zoomScale: Double {
		get {
			let mapBoundsWidth = Double(self.bounds.size.width)
			let mapRectWidth: Double = self.visibleMapRect.size.width
			let scale: Double = mapBoundsWidth / mapRectWidth
			return scale
		}
	}

}
