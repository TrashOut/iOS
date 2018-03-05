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
import MapKit

public protocol ClusteringManagerDelegate: class {
	func cellSizeFactor(_ coordinator: ClusteringManager) -> CGFloat

	func createClusterAnnotation(coords: CLLocationCoordinate2D, annotations: [MKAnnotation]) -> AnnotationCluster

}

public protocol AnnotationCluster: MKAnnotation {

	var annotations: [MKAnnotation] {set get}
	var rect: MKMapRect? {set get}
	var zoom: MKZoomScale? {set get}
}

/**
Inspired by FBAnnotationClusteringSwift by Giuseppe Russo and Robert Chen

https://github.com/ribl/FBAnnotationClusteringSwift

*/
public class ClusteringManager: NSObject {

	public weak var delegate: ClusteringManagerDelegate? = nil

	var tree: QuadTree? = nil

	var lock: NSRecursiveLock = NSRecursiveLock()

	public var maxZoomLevel = 19

	public override init() {
		super.init()
	}

	public init(annotations: [MKAnnotation]) {
		super.init()
		addAnnotations(annotations)
	}

	public func setAnnotations(_ annotations: [MKAnnotation]) {
		lock.lock()
		tree = nil
		lock.unlock()
		addAnnotations(annotations)
	}

	public func addAnnotations(_ annotations: [MKAnnotation]) {
		lock.lock()
		if tree == nil {
			tree = QuadTree()
		}
		for annotation in annotations {
			//guard tree != nil else {break}
			tree?.insertAnnotation(annotation)
		}
		lock.unlock()
	}

	public func clusteredAnnotations(for rect: MKMapRect, withZoomScale zoomScale: Double) -> [MKAnnotation] {
		guard !zoomScale.isInfinite else { return [] }
		let zoomLevel = self.zoomLevel(forZoomScale: MKZoomScale(zoomScale))
		let cellSize = self.cellSize(forLevel: zoomLevel)
		let scaleFactor: Double = zoomScale / Double(cellSize)
		let minX: Int = Int(floor(MKMapRectGetMinX(rect) * scaleFactor))
		let maxX: Int = Int(floor(MKMapRectGetMaxX(rect) * scaleFactor))
		let minY: Int = Int(floor(MKMapRectGetMinY(rect) * scaleFactor))
		let maxY: Int = Int(floor(MKMapRectGetMaxY(rect) * scaleFactor))

		var clusteredAnnotations = [MKAnnotation]()
		lock.lock()
		for i in minX...maxX {
			for j in minY...maxY {
				let anns = self.clusteredAnnotations(inX: i, inY: j, scaleFactor: scaleFactor, zoomLevel: zoomLevel, zoomScale: MKZoomScale(zoomScale))
				clusteredAnnotations.append(contentsOf: anns)
			}
		}
		lock.unlock()
		return clusteredAnnotations
	}

	private func clusteredAnnotations(inX x: Int, inY y: Int, scaleFactor: Double, zoomLevel: Int, zoomScale: MKZoomScale) -> [MKAnnotation] {
		let mapPoint = MKMapPoint(x: Double(x)/scaleFactor, y: Double(y)/scaleFactor)
		let mapSize = MKMapSize(width: 1.0/scaleFactor, height: 1.0/scaleFactor)
		let mapRect = MKMapRect(origin: mapPoint, size: mapSize)
		let mapBox: BoundingBox = BoundingBox(mapRect: mapRect)

		var totalLatitude: Double = 0
		var totalLongitude: Double = 0
		var annotations = [MKAnnotation]()

		tree?.enumerateAnnotationsInBox(mapBox) { obj in
			totalLatitude += obj.coordinate.latitude
			totalLongitude += obj.coordinate.longitude
			annotations.append(obj)
		}

		let count = annotations.count
		if count == 1 || zoomLevel >= self.maxZoomLevel {
			return annotations
		} else if count > 1 {
			let coordinate = CLLocationCoordinate2D(
				latitude: CLLocationDegrees(totalLatitude)/CLLocationDegrees(count),
				longitude: CLLocationDegrees(totalLongitude)/CLLocationDegrees(count)
			)
			if let cluster = self.delegate?.createClusterAnnotation(coords: coordinate, annotations: annotations) {
				cluster.rect = mapRect
				cluster.zoom = zoomScale
				return [cluster]
			}
		}
		return []
	}

	public func allAnnotations() -> [MKAnnotation] {
		var annotations = [MKAnnotation]()
		lock.lock()
		tree?.enumerateAnnotationsUsingBlock { obj in
			annotations.append(obj)
		}
		lock.unlock()
		return annotations
	}

//	public func displayAnnotations(_ annotations: [MKAnnotation], onMapView mapView: MKMapView) {
//
//		DispatchQueue.main.async {
//
//			let before = NSMutableSet(array: mapView.annotations)
//			before.remove(mapView.userLocation)
//			let after = NSSet(array: annotations)
//			let toKeep = NSMutableSet(set: before)
//			toKeep.intersect(after as Set<NSObject>)
//			let toAdd = NSMutableSet(set: after)
//			toAdd.minus(toKeep as Set<NSObject>)
//			let toRemove = NSMutableSet(set: before)
//			toRemove.minus(after as Set<NSObject>)
//
//			guard let type = self.delegate?.clusterAnnotationType else {return}
//			let annotationsOnlyPredicate = NSPredicate(format: "SELF isKindOfClass:%@", argumentArray: [type])
//
//			toRemove.filter(using: annotationsOnlyPredicate)
//
//			if let toAddAnnotations = toAdd.allObjects as? [MKAnnotation] {
//				mapView.addAnnotations(toAddAnnotations)
//			}
//
//			if let removeAnnotations = toRemove.allObjects as? [MKAnnotation] {
//				mapView.removeAnnotations(removeAnnotations)
//			}
//		}
//	}

	public func zoomLevel(forZoomScale scale: MKZoomScale) -> Int {
		let totalTilesAtMaxZoom: Double = MKMapSizeWorld.width / 256.0
		let zoomLevelAtMaxZoom: Int = Int(log2(totalTilesAtMaxZoom))
		let floorLog2ScaleFloat = floor(log2f(Float(scale))) + 0.5
		guard !floorLog2ScaleFloat.isInfinite else { return floorLog2ScaleFloat.sign == .plus ? 0 : 19 }
		let sum: Int = zoomLevelAtMaxZoom + Int(floorLog2ScaleFloat)
		let zoomLevel: Int = max(0, sum)
		return zoomLevel
	}

	public func cellSize(forLevel zoomLevel: Int) -> CGFloat {
		let factor: CGFloat = self.delegate?.cellSizeFactor(self) ?? 1
		return 64 * factor
	}

	public func cellSize(forScale zoomScale: MKZoomScale) -> CGFloat {
		let zoomLevel = self.zoomLevel(forZoomScale: zoomScale)
		return self.cellSize(forLevel: zoomLevel)
	}

}

open class QuadTree: NSObject {

	var rootNode: QuadTreeNode? = nil

	let nodeCapacity = 8

	override init() {
		super.init()

		rootNode = QuadTreeNode(boundingBox: BoundingBox(mapRect: MKMapRectWorld))

	}

	@discardableResult
	func insertAnnotation(_ annotation: MKAnnotation) -> Bool {
		return insertAnnotation(annotation, toNode: rootNode!)
	}

	func insertAnnotation(_ annotation: MKAnnotation, toNode node: QuadTreeNode) -> Bool {
		guard let nodeBox = node.boundingBox else { return false }
		guard nodeBox.contains(coordinate: annotation.coordinate) else { return false }
		if node.count < nodeCapacity {
			node.annotations.append(annotation)
			node.count += 1
			return true
		}
		if node.isLeaf() {
			node.subdivide()
		}
		return processInsertAnnotationIntoTree(annotation, toNode: node)
	}

	func processInsertAnnotationIntoTree(_ annotation: MKAnnotation, toNode node: QuadTreeNode) -> Bool {
		return insertAnnotation(annotation, toNode: node.northEast!) ||
			insertAnnotation(annotation, toNode: node.northWest!) ||
			insertAnnotation(annotation, toNode: node.southEast!) ||
			insertAnnotation(annotation, toNode: node.southWest!)
	}

	func enumerateAnnotationsInBox(_ box: BoundingBox, callback: (MKAnnotation) -> Void) {
		enumerateAnnotationsInBox(box, withNode: rootNode!, callback: callback)
	}

	func enumerateAnnotationsUsingBlock(_ callback: (MKAnnotation) -> Void) {
		enumerateAnnotationsInBox(BoundingBox(mapRect: MKMapRectWorld), withNode: rootNode!, callback: callback)
	}

	func enumerateAnnotationsInBox(_ box: BoundingBox, withNode node: QuadTreeNode, callback: (MKAnnotation) -> Void) {
		guard let nodeBox = node.boundingBox else {return}
		guard nodeBox.intersects(box) else {return}
		let tempArray = node.annotations
		for annotation in tempArray {
			if box.contains(coordinate: annotation.coordinate) {
				callback(annotation)
			}
		}
		guard node.isLeaf() == false else { return }
		enumerateAnnotationsInBox(box, withNode: node.northEast!, callback: callback)
		enumerateAnnotationsInBox(box, withNode: node.northWest!, callback: callback)
		enumerateAnnotationsInBox(box, withNode: node.southEast!, callback: callback)
		enumerateAnnotationsInBox(box, withNode: node.southWest!, callback: callback)
	}

}

open class QuadTreeNode: NSObject {

	var boundingBox: BoundingBox? = nil

	var northEast: QuadTreeNode? = nil
	var northWest: QuadTreeNode? = nil
	var southEast: QuadTreeNode? = nil
	var southWest: QuadTreeNode? = nil

	var count = 0

	var annotations: [MKAnnotation] = []

	// MARK: - Initializers

	override init() {
		super.init()
	}

	init(boundingBox box: BoundingBox) {
		super.init()
		boundingBox = box
	}

	// MARK: - Instance functions

	func isLeaf() -> Bool {
		return (northEast == nil) ? true : false
	}

	func subdivide() {
		northEast = QuadTreeNode()
		northWest = QuadTreeNode()
		southEast = QuadTreeNode()
		southWest = QuadTreeNode()

		let box = boundingBox!

		let xMid: CGFloat = (box.xf + box.x0) / 2.0
		let yMid: CGFloat = (box.yf + box.y0) / 2.0

		northEast!.boundingBox = BoundingBox(xMid, box.y0, box.xf, yMid)
		northWest!.boundingBox = BoundingBox(box.x0, box.y0, xMid, yMid)
		southEast!.boundingBox = BoundingBox(xMid, yMid, box.xf, box.yf)
		southWest!.boundingBox = BoundingBox(box.x0, yMid, xMid, box.yf)
	}

	// MARK: - Class functions

}

public struct BoundingBox {
	let x0, y0, xf, yf: CGFloat

	init(_ x0: CGFloat, _ y0: CGFloat, _ xf: CGFloat, _ yf: CGFloat) {
		self.x0 = x0
		self.y0 = y0
		self.xf = xf
		self.yf = yf
	}

	init(mapRect: MKMapRect) {
		let topLeft: CLLocationCoordinate2D = MKCoordinateForMapPoint(mapRect.origin)
		let botRight: CLLocationCoordinate2D = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)))
		let minLat: CLLocationDegrees = botRight.latitude
		let maxLat: CLLocationDegrees = topLeft.latitude

		let minLon: CLLocationDegrees = topLeft.longitude
		let maxLon: CLLocationDegrees = botRight.longitude
		self.init(CGFloat(minLat), CGFloat(minLon), CGFloat(maxLat), CGFloat(maxLon))
	}

	func contains(coordinate: CLLocationCoordinate2D) -> Bool {
		let containsX: Bool = (self.x0 <= CGFloat(coordinate.latitude)) && (CGFloat(coordinate.latitude) <= self.xf)
		let containsY: Bool = (self.y0 <= CGFloat(coordinate.longitude)) && (CGFloat(coordinate.longitude) <= self.yf)
		return (containsX && containsY)
	}

	func intersects(_ box: BoundingBox) -> Bool {
		return (self.x0 <= box.xf && self.xf >= box.x0 && self.y0 <= box.yf && self.yf >= box.y0)
	}

	var mapRect: MKMapRect {
		get {
			let topLeft: MKMapPoint  = MKMapPointForCoordinate(
				CLLocationCoordinate2DMake(
					CLLocationDegrees(self.x0),
					CLLocationDegrees(self.y0)))

			let botRight: MKMapPoint  = MKMapPointForCoordinate(
				CLLocationCoordinate2DMake(
					CLLocationDegrees(self.xf),
					CLLocationDegrees(self.yf)))

			return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y))
		}
	}

}
