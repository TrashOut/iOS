//
//  MapClusterTests.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 20.02.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import XCTest
@testable import TrashOut


class MapClusterTests: XCTestCase {



	/**
	Stav skládek v clusteru
	Tři zelené tečky (všechny skládky v clusteru mají status=cleaned)
	Tři červené tečky (všechny skládky v clusteru mají status=stillHere, more nebo less a zároveň updatedNeeded=false)
	Tři žluté tečky (všechny skládky v clusteru mají updatedNeeded=true)
	Dvě zelené a jedna červená tečka (v clusteru existuje alespoň jedna skládka v clusteru, která má status=stillHere nebo more nebo less a zároveň updateNeeded=false, ale je více nebo stejně skládek, které mají status=cleaned, neexistuje žádná skládka, která má updateNeeded=true)
	Jedna zelená a dvě červené tečky (v clusteru existuje alespoň jedna skládka v clusteru, která má status=cleaned, ale je více skládek, které mají status=stillHere, more nebo less, neexistuje žádná skládka, která má updateNeeded=true)
	Jedna zelená, jedna červená a jedna žlutá tečka (v clusteru existuje alespoň jedna skládka se status=cleaned, existuje alespoň jedna skládka se status=stillHere, more nebo less a zároveň updatedNeeded=false , a existuje alespoň jedna skládka s updatedNeeded=true)
	Dvě zelené a jedna žlutá tečka (v clusteru existuje alespoň jedna skládka s updatedNeeded=true, ale je více nebo stejně skládek, které mají status=cleaned)
	Jedna zelená a dvě žluté tečky (v clusteru existuje alespoň jedna skládka, která má status=cleaned, ale je více skládek, které mají updatedNeeded=true)
	Dvě červené a jedna žlutá tečka (v clusteru existuje alespoň jedna skládka s updatedNeeded=true, ale je více nebo stejně skládek, které mají status=stillHere, more nebo less a zároveň updatedNeeded=false)
	Jedna červená a dvě žluté tečky (v clusteru existuje alespoň jedna skládka, která má status=stillHere, more nebo less a zároveň updatedNeeded=false, ale je více skládek, které mají updatedNeeded=true)

	*/
	func testClusterDots() {
		var reported: Int = 0
		var cleaned: Int = 0
		var updateNeeded: Int = 0
		var variant: ClusterMapAnnotation.DotsVariant!

		cleaned = 10
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .allGreen, "Just all cleaned")

		reported = 10
		cleaned = 0
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .allRed, "Just all reported")

		reported = 0
		updateNeeded = 10
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .allYellow, "Just all needs update")


//		Dvě zelené a jedna červená tečka (v clusteru existuje alespoň jedna skládka v clusteru, která má status=stillHere nebo more nebo less a zároveň updateNeeded=false, ale je více nebo stejně skládek, které mají status=cleaned, neexistuje žádná skládka, která má updateNeeded=true)
		reported = 1
		cleaned = 1
		updateNeeded = 0
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .twoGreenOneRed, "same cleaned as reported, no update")
		reported = 1
		cleaned = 2
		updateNeeded = 0
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .twoGreenOneRed, "more cleaned than reported, no update")

//		Jedna zelená a dvě červené tečky (v clusteru existuje alespoň jedna skládka v clusteru, která má status=cleaned, ale je více skládek, které mají status=stillHere, more nebo less, neexistuje žádná skládka, která má updateNeeded=true)
		reported = 2
		cleaned = 1
		updateNeeded = 0
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .twoRedOneGreen, "more reported than cleaned, no update")

//		Jedna zelená, jedna červená a jedna žlutá tečka (v clusteru existuje alespoň jedna skládka se status=cleaned, existuje alespoň jedna skládka se status=stillHere, more nebo less a zároveň updatedNeeded=false , a existuje alespoň jedna skládka s updatedNeeded=true)
		reported = 1
		cleaned = 1
		updateNeeded = 1
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .oneAll, "from all exists atleas one")
		reported = 3
		cleaned = 2
		updateNeeded = 1
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .oneAll, "from all exists atleas one")
		reported = 1
		cleaned = 2
		updateNeeded = 3
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .oneAll, "from all exists atleas one")
		reported = 2
		cleaned = 1
		updateNeeded = 3
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .oneAll, "from all exists atleas one")
		reported = 3
		cleaned = 1
		updateNeeded = 2
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .oneAll, "from all exists atleas one")
		reported = 2
		cleaned = 3
		updateNeeded = 1
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .oneAll, "from all exists atleas one")
		reported = 1
		cleaned = 3
		updateNeeded = 2
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .oneAll, "from all exists atleas one")
		reported = 2
		cleaned = 1
		updateNeeded = 2
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .oneAll, "from all exists atleas one")
		reported = 1
		cleaned = 2
		updateNeeded = 2
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .oneAll, "from all exists atleas one")
		reported = 2
		cleaned = 2
		updateNeeded = 1
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .oneAll, "from all exists atleas one")

//		Dvě zelené a jedna žlutá tečka (v clusteru existuje alespoň jedna skládka s updatedNeeded=true, ale je více nebo stejně skládek, které mají status=cleaned)
		reported = 0
		updateNeeded = 1
		cleaned = 2
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .twoGreenOneYellow, "atleast one update needed, but more or same of cleaned")
		reported = 0
		updateNeeded = 1
		cleaned = 1
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .twoGreenOneYellow, "atleast one update needed, but more or same of cleaned")

//		Jedna zelená a dvě žluté tečky (v clusteru existuje alespoň jedna skládka, která má status=cleaned, ale je více skládek, které mají updatedNeeded=true)
		reported = 0
		cleaned = 1
		updateNeeded = 2
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .twoYellowOneGreen, "atleast one cleaned, but more of update needed")

//		Dvě červené a jedna žlutá tečka (v clusteru existuje alespoň jedna skládka s updatedNeeded=true, ale je více nebo stejně skládek, které mají status=stillHere, more nebo less a zároveň updatedNeeded=false)
		reported = 1
		updateNeeded = 1
		cleaned = 0
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .twoRedOneYellow, "atleast one update needed, but more or same of reported")
		reported = 2
		updateNeeded = 1
		cleaned = 0
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .twoRedOneYellow, "atleast one update needed, but more or same of reported")

//		Jedna červená a dvě žluté tečky (v clusteru existuje alespoň jedna skládka, která má status=stillHere, more nebo less a zároveň updatedNeeded=false, ale je více skládek, které mají updatedNeeded=true)
		reported = 1
		updateNeeded = 2
		cleaned = 0
		variant = .getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)
		XCTAssert(variant == .twoYellowOneRed, "atleast one reported, but more  of updateNeeded")

	}


}
