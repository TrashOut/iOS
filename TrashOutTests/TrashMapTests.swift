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
import XCTest
@testable import TrashOut
import CoreLocation


class TrashMapTests: XCTestCase {

	var manager: DumpsMapManager!

	override func setUp() {
		super.setUp()
		manager = DumpsMapManager()
	}


	/**
	Test geocell length (resolution) for zoom level
	*/
	func testResolution () {
		for i in 10..<15 {
			XCTAssert(DumpsMapManager.GeocellResolution.resolution(for: i).rawValue == 5, "Resolution for zoom \(i) should be 5")
		}
		XCTAssert(DumpsMapManager.GeocellResolution.resolution(for: 9).rawValue == 4, "Resolution for zoom 9 should be 4")
		XCTAssert(DumpsMapManager.GeocellResolution.resolution(for: 8).rawValue == 4, "Resolution for zoom 8 should be 4")
		XCTAssert(DumpsMapManager.GeocellResolution.resolution(for: 7).rawValue == 3, "Resolution for zoom 7 should be 3")
		XCTAssert(DumpsMapManager.GeocellResolution.resolution(for: 6).rawValue == 3, "Resolution for zoom 6 should be 3")
		XCTAssert(DumpsMapManager.GeocellResolution.resolution(for: 5).rawValue == 2, "Resolution for zoom 5 should be 2")
		XCTAssert(DumpsMapManager.GeocellResolution.resolution(for: 4).rawValue == 2, "Resolution for zoom 4 should be 2")
		XCTAssert(DumpsMapManager.GeocellResolution.resolution(for: 3).rawValue == 2, "Resolution for zoom 3 should be 2")
	}

	/**
	Generating geocell strings
	*/
	func testGeocellStringGeneration() {
		var coords: CLLocationCoordinate2D
		coords = CLLocationCoordinate2DMake(0, 0) // lots of water there
		XCTAssert(manager.cell(for: coords, resolution: 5) == "c0000", "Geocell for \(coords) should be 'c0000'")

		coords = CLLocationCoordinate2DMake(50.083444, 14.427874) // somewhere in prague
		XCTAssert(manager.cell(for: coords, resolution: 2) == "e0", "Geocell for \(coords) should be 'e0'")
		XCTAssert(manager.cell(for: coords, resolution: 3) == "e06", "Geocell for \(coords) should be 'e06'")
		XCTAssert(manager.cell(for: coords, resolution: 4) == "e06e", "Geocell for \(coords) should be 'e06e'")
		XCTAssert(manager.cell(for: coords, resolution: 5) == "e06e1", "Geocell for \(coords) should be 'e06e1'")
	}

	/** 
	Test generating cells in given coordinate rect
	
	- TODO: Add tests for crossing 180 and 90
	*/
	func testGeocellsInBounds() {
		var nw: CLLocationCoordinate2D!
		var se: CLLocationCoordinate2D!
		var cells: [String]!
		var neededCells: [String]!

		nw = CLLocationCoordinate2DMake(50.083444, 14.427874)
		se = CLLocationCoordinate2DMake(50.083444, 14.427874)
		cells = manager.geocells(between: nw, southeast: se, with: 5)
		print(cells)
		XCTAssert(cells.count == 1, "There should be one cell for point")
		XCTAssert(cells.first == "e06e1", "And has name 'e06e1'")



		//---------------------------------------------------------------


		var ne = CLLocationCoordinate2DMake(50.203928, 14.658337)
		var sw = CLLocationCoordinate2DMake(49.981129, 14.226460)


		nw = CLLocationCoordinate2D(latitude: ne.latitude,  longitude: sw.longitude)
		se = CLLocationCoordinate2D(latitude: sw.latitude,  longitude: ne.longitude)
		neededCells = ["e06e2", "e06e1", "e06e3", "e06e0"]


		//		neededCells = ["e06c3", "e06bd", "e0697", "e069c", "e069f", "e06e6", "e06c8", "e069d", "e0696", "e06b6", "e06ce", "e06cb", "e06ec", "e06ca", "e06cc", "e06c6", "e06b4", "e06b5", "e06e8", "e06c2", "e06e2", "e069e", "e06e1", "e06c9", "e06bc", "e06e9", "e06b7", "e06e3", "e06e4", "e06e0"]

		cells = manager.geocells(between: nw, southeast: se, with:5)
		print(cells)
		XCTAssert(cells.count == neededCells.count, "There should be \(neededCells.count) cells")
		for nc in neededCells {
			XCTAssert(cells.contains(nc), "There should be cell '\(nc)'")
		}
		//---------------------------------------------------------------



		//---------------------------------------------------------------
		nw = CLLocationCoordinate2D(latitude: 50.068428618925793 - 1/2,  longitude: 14.402045184351605 - 1.557933937641991/2)
		se = CLLocationCoordinate2D(latitude: 50.068428618925793 + 1/2,  longitude: 14.402045184351605 + 1.557933937641991/2)
		neededCells = ["e06e1", "e06c3", "e06bd", "e06be", "e0697", "e069c", "e069f", "e06e6", "e06c8", "e069d", "e0696", "e06b6", "e06eb", "e06ce", "e06cb", "e06ec", "e06bf", "e06ca", "e06cc", "e06c6", "e06b4", "e06b5", "e06ea", "e06e8", "e06ee", "e06c2", "e06e2", "e069e", "e06c9", "e06bc", "e06e9", "e06b7", "e06e3", "e06e4", "e06e0"]


//		neededCells = ["e06c3", "e06bd", "e0697", "e069c", "e069f", "e06e6", "e06c8", "e069d", "e0696", "e06b6", "e06ce", "e06cb", "e06ec", "e06ca", "e06cc", "e06c6", "e06b4", "e06b5", "e06e8", "e06c2", "e06e2", "e069e", "e06e1", "e06c9", "e06bc", "e06e9", "e06b7", "e06e3", "e06e4", "e06e0"]

		cells = manager.geocells(between: nw, southeast: se, with: 5)
		print(cells)
		XCTAssert(cells.count == neededCells.count, "There should be \(neededCells.count) cells")
		for nc in neededCells {
			XCTAssert(cells.contains(nc), "There should be cell '\(nc)'")
		}

		//---------------------------------------------------------------
		//---------------------------------------------------------------


		ne = CLLocationCoordinate2D(latitude: 50.068428618925793 + 1/2,  longitude: 14.402045184351605 + 1.557933937641991/2)
		sw = CLLocationCoordinate2D(latitude: 50.068428618925793 - 1/2,  longitude: 14.402045184351605 - 1.557933937641991/2)


		nw = CLLocationCoordinate2D(latitude: ne.latitude,  longitude: sw.longitude)
		se = CLLocationCoordinate2D(latitude: sw.latitude,  longitude: ne.longitude)

// by vlada
// for res 4 : ["e069", "e06c", "e06b", "e06e"]
//		neededCells = ["e0696", "e0697", "e06c2", "e06c3", "e06c6", "e06c7", "e069c", "e069d", "e06c8", "e06c9", "e06cc", "e06cd", "e069e", "e069f", "e06ca", "e06cb", "e06ce", "e06cf", "e06b4", "e06b5", "e06e0", "e06e1", "e06e4", "e06e5", "e06b6", "e06b7", "e06e2", "e06e3", "e06e6", "e06e7", "e06bc", "e06bd", "e06e8", "e06e9", "e06ec", "e06ed", "e06be", "e06bf", "e06ea", "e06eb", "e06ee", "e06ef"]

// my result
// for res 4: ["e06b", "e06e"]
		neededCells = ["e06bd", "e06be", "e069f", "e069c", "e06e6", "e06c8", "e069d", "e06b6", "e06eb", "e06ec", "e06cb", "e06bf", "e06ce", "e06ca", "e06cc", "e06b4", "e06ea", "e06b5", "e06e8", "e06ee", "e06e2", "e06e1", "e069e", "e06c9", "e06bc", "e06e9", "e06b7", "e06e4", "e06e3", "e06e0"]

		cells = manager.geocells(between: nw, southeast: se, with: 5)
		print(cells)
		XCTAssert(cells.count == neededCells.count, "There should be \(neededCells.count) cells")
		for nc in neededCells {
			XCTAssert(cells.contains(nc), "There should be cell '\(nc)'")
		}
		//---------------------------------------------------------------

	}

	


}
