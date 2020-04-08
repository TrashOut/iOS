//
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
import Alamofire
import Cache

/**
Test against mock api

Be aware of apiary request rate limit (120)
*/
class NetworkingTests: XCTestCase {

    let locationPoint = LocationManager.manager.currentLocation.coordinate

    /// These constants values must be real.
    let userUID = "Mdw7gpudQbWNKbbsxOJvNzgpv7q2"
    let userID = 35380
    let trashID = 31725
    let junkyardID = 19
    let eventID = 497

    /// These constants values are used to create and update trash
    let imageOfTrash = DumpsImages.init(thumbDownloadUrl: "TEST", thumbStorageLocation: "TEST", fullDownloadUrl: "TEST", storageLocation: "TEST")
    let gps = Coordinates.init(lat: 50.000000, long: 50.000000, accuracy: 20, source: "gps")
    let type = ["automotive"] // automotive, domestic, liquid, plastic, dangerous, metal, electronic, deadAnimals, organic, construction
    let size = "car" // bag, wheelbarrow, car
    let note = "running tests" // anything you want
    let anonymous = false
    let accessibility = DumpsAccessibility.init(byCar: true, inCave: false, underWater: false, notForGeneralCleanup: true)
    let status = "stillHere" // stillHere, less, more, cleaned
    let cleanedByMe = false

    /// These constants values are used to create event
    let eventName = "TEST"
    let eventDescription = "TEST"
    let start = "2016-12-24T16:35:26.000Z"
    let duration = 120
    let bring = "TEST"
    let have = "TEST"
    let contact = Contact.init(email: "test@test.com", phone: "123456789")
    let trashPointsId = [31725]
    let collectionPointIds = [0]

	override func setUp() {
		super.setUp()
		Networking.instance.apiBaseUrl = "https://api.trashout.ngo/v1"//"http://52.211.171.156/api"
	}

    /*
    Test if user has all essential data
    */
	func testUser() {
		let expectation = self.expectation(description: "User endpoint should return")
		Networking.instance.user(userID) { (user, error) in
			expectation.fulfill()
			/*
            XCTAssertNil(error, "User endpoint returns user")
			XCTAssertNotNil(user)
			guard let user = user else {
                print(error?.localizedDescription as Any)
                return
            }
			XCTAssert(user.firstName != nil, "First name is nil")
			XCTAssert(user.lastName != nil, "Last name is nil")
            XCTAssert(user.email != nil, "Email is nil")
            XCTAssert(user.image?.fullDownloadUrl != nil, "Image is nil")
			XCTAssertNotNil(user.registered)
			XCTAssert(DateFormatter.utc.string(from: user.registered!) != "", "No date of registration")*/
		}
		self.waitForExpectations(timeout: 30) { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}

    /*
     Test if user can be created
     */
    func testCreateUser() {
        let expectation = self.expectation(description: "User should create")
        Networking.instance.createUser(user: User(), uid: userUID) { (user, error) in
            expectation.fulfill()
            //XCTAssert(error == nil, "User was not created")
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    Test if user can be updated
    */
    func testUpdateUser() {
        let expectation = self.expectation(description: "User should update")
        Networking.instance.updateUser(user: User(), id: userID, uid: userUID, image: nil) { (user, error) in
            expectation.fulfill()
            //XCTAssert(error == nil, "User was not updated")
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    Test if single trash has all essential data
    */
	func testTrash() {
		let expectation = self.expectation(description: "Trash endpoint should return")
		Networking.instance.trash(trashID) { (trash, error) in
			expectation.fulfill()
			XCTAssert(error == nil, "Trash endpoint returns trash")
			XCTAssert(trash != nil, "Trash endpoint returns trash")
			guard let trash = trash else {
				print(error?.localizedDescription as Any)
				return
			}
			XCTAssert(trash.status.rawValue != "", "No status")
			XCTAssert(trash.size.rawValue != "", "No size")
            XCTAssert(!trash.types.isEmpty, "No types")
            XCTAssert(trash.images.count > 0 , "No photos")
			XCTAssert(trash.images.first!.fullDownloadUrl! != "", "No photos URL")
			XCTAssert(trash.gps != nil, "GPS is nil")
            XCTAssert(trash.url != nil, "URL is nil")
            //XCTAssert(trash.user?.firstName != nil, "First name is nil")
            //XCTAssert(trash.user?.lastName != nil, "Last name is nil")
            XCTAssert(trash.accessibility?.byCar != nil, "By car is nil")
            XCTAssert(trash.accessibility?.inCave != nil, "In cave is nil")
            XCTAssert(trash.accessibility?.underWater != nil, "Under water is nil")
            XCTAssert(trash.accessibility?.notForGeneralCleanup != nil, "Not for general cleanup is nil")
		}
		self.waitForExpectations(timeout: 30) { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}

    /*
    Test if trash list has all essential data
    */
	func testTrashes() {
		let expectation = self.expectation(description: "Trashes endpoint should return")

		//(position: CLLocationCoordinate2D, filter: TrashFilter, limit: Int, page: Int, callback: @escaping ([Trash]?, Error?) -> ())
		let filter = TrashFilter.init()
		Networking.instance.trashes(position: locationPoint, filter: filter, limit: 10, page: 1) { (trashes, error) in
			expectation.fulfill()
			XCTAssert(error == nil, "Trashes endpoint returns trashes")
			XCTAssert(trashes != nil, "Trashes endpoint returns trashes")
            guard let trashes = trashes else {
                print(error?.localizedDescription as Any)
                return
            }
			XCTAssert(trashes.count > 0, "Trashes endpoint returns \(trashes.count) trashes")
            XCTAssert(trashes[0].id != 0, "\(trashes[0].id)")
            XCTAssert(!trashes[0].types.isEmpty, "No types")
            XCTAssert(trashes[0].status.rawValue != "", "No status")
            XCTAssert(trashes[0].images.count > 0, "No photos")
            XCTAssert(trashes[0].images.first!.fullDownloadUrl! != "", "No photos URL")
            XCTAssert(trashes[0].created != nil, "Date is nil")
            XCTAssert(trashes[0].gps != nil, "GPS is nil")
		}
		self.waitForExpectations(timeout: 30) { (error) in
			if let error = error {
				print(error.localizedDescription)
			}
		}
    }

    /*
    Test if trash can be created
    */
    func testCreateTrash() {
        let expectation = self.expectation(description: "Trash should create")
        Networking.instance.createTrash([imageOfTrash], gps: gps, size: size, type: type, note: note, anonymous: anonymous, userId: userID, accessibility: accessibility) { (trash, error) in
            expectation.fulfill()
            XCTAssert(error == nil, "Trash was not created")
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    Test if trash can be updated
    */
    func testUpdateTrash() {
        let expectation = self.expectation(description: "Trash should update")
        Networking.instance.updateTrash(trashID, images:[imageOfTrash], gps: gps, size: size, type: type, note: note, anonymous: anonymous, userId: userID, accessibility: accessibility, status: status, cleanedByMe: cleanedByMe) { (trash, error) in
            expectation.fulfill()
            XCTAssert(error == nil, "Trash was not updated")
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    Test if trash spam can be reported
    */
    func testReportSpam() {
        let expectation = self.expectation(description: "Spam should report")
        Networking.instance.reportSpam(trashID, userId: userID) { (trash, error) in
            expectation.fulfill()
            //XCTAssert(error == nil, "Spam was not reported")
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    Test if single junkyard has all essential data
    */
    func testJunkyard() {
        let expectation = self.expectation(description: "Junkyard endpoint should return")
        Networking.instance.junkyard(junkyardID) { (junkyard, error) in
            expectation.fulfill()
            XCTAssert(error == nil, "Junkyard endpoint returns junkyard")
            XCTAssert(junkyard != nil, "Junkyard endpoint returns junkyard")
            guard let junkyard = junkyard else {
                print(error?.localizedDescription as Any)
                return
            }
            if junkyard.size == "scrapyard" {
                XCTAssert(junkyard.size != nil, "Size is nil")
                XCTAssert(!junkyard.types.isEmpty, "No types)")
                XCTAssert(junkyard.gps != nil, "GPS is nil")
                XCTAssert(junkyard.email != nil, "Email is nil")
                XCTAssert(junkyard.phone != nil, "Phone is nil")
                XCTAssert(!junkyard.openingHours.isEmpty, "No opening hours")
                XCTAssert(junkyard.note != nil, "Note is nil")
            } else {
                XCTAssert(junkyard.size != nil, "Size is nil")
                XCTAssert(junkyard.types.isEmpty, "No types)")
                XCTAssert(junkyard.gps != nil, "GPS is nil")
            }
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    Test if junkyard list has all essential data
    */
    func testJunkyards() {
        let expectation = self.expectation(description: "Junkyards endpoint should return")
        Networking.instance.junkyards(position: locationPoint, size: nil, type: nil, page: 1) { (junkyards, error) in
            expectation.fulfill()
            XCTAssert(error == nil, "Junkyards endpoint returns junkyards")
            XCTAssert(junkyards != nil, "Junkyards endpoint returns junkyards")
            guard let junkyards = junkyards else {
                print(error?.localizedDescription as Any)
                return
            }
            XCTAssert(junkyards.count > 0, "Junkyards endpoint returns \(junkyards.count) junkyards")
            XCTAssert(junkyards[0].id != 0, "\(junkyards[0].id)")
            XCTAssert(!junkyards[0].types.isEmpty, "No types")
            XCTAssert(junkyards[0].size != nil, "Size is nil")
            XCTAssert(junkyards[0].gps != nil, "GPS is nil")
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    Test if event has all essential data
    */
    func testEvent() {
        let expectation = self.expectation(description: "Event endpoint should return")
        Networking.instance.event(eventID) { (event, error) in
            expectation.fulfill()
            XCTAssert(error == nil, "Event endpoint should return")
            XCTAssert(event != nil, "Event endpoint returns event")
            guard let event = event else {
                print(error?.localizedDescription as Any)
                return
            }
            XCTAssert(event.id != 0, "\(event.id)")
            XCTAssert(event.name != nil, "Name is nill")
            XCTAssert(event.description != nil, "Description is nill")
            XCTAssert(event.duration != 0, "\(event.duration)")
            XCTAssert(event.bring != nil, "Bring is nill")
            XCTAssert(event.have != nil, "Have is nill")
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    Test if event can be created
    */
    func testCreateEvent() {
        let expectation = self.expectation(description: "Event should create")
        Networking.instance.createEvent(eventName, gps: gps, description: eventDescription, start: start, duration: duration, bring: bring, have: have, contact: contact, trashPointsId: trashPointsId, collectionPointIds: collectionPointIds) { (event, error) in
            expectation.fulfill()
            //XCTAssert(error == nil, "Event was not created")
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    Test if event can be joined (user can join event only once, for next testing is change in one of these parameters necessary)
    */
    func testJoinEvent() {
        let expectation = self.expectation(description: "Event should be join")
        Networking.instance.userJoinedEvent(eventID, userId: userID) { (event, error) in
            expectation.fulfill()
            //XCTAssert(error == nil, "Event was not joined")
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    /*
    Test if news have all essential data
    */
    func testNews() {
        let expectation = self.expectation(description: "News endpoint should return")
        Networking.instance.news(page: 1, limit: 20, language: "en_US") { (articles, error) in
            expectation.fulfill()
            XCTAssert(error == nil, "News endpoint should return")
            XCTAssert(articles != nil, "News endpoint returns news")
			XCTAssert(articles?.first != nil, "News endpoint returns news")
            guard let article = articles?.first else {
                print(error?.localizedDescription as Any)
                return
            }
            XCTAssert(article.id != nil, "Id is nil")
            XCTAssert(article.title != nil, "Title is nil")
            XCTAssert(article.published != nil, "Published is nil")
            XCTAssert(article.content != nil, "Content is nill=")
            XCTAssert(!article.tags.isEmpty, "No tags")
            /*
            XCTAssert(article.photos.count > 0, "No photos")
            XCTAssert(article.photos.first?.fullDownloadUrl != nil, "No photos URL")
            XCTAssert(article.videos.count > 0, "No videos")
            XCTAssert(article.videos.first?.url != nil, "No videos URL")
            XCTAssert(article.videos.first?.thumbnail != nil, "No videos thumbnail")
            */
        }
        self.waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

}
