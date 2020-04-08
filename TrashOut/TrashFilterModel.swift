//
//  TrashFilterModel.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 25.01.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import SwiftDate




class TrashFilter: JsonDecodable {


	/**
	Cleaned (status=cleaned a updateNeeded=false)
	Reported (status=stillHere,more,less a updateNeeded=false)
	UpdateNeeded (updateNeeded=true)
	*/
	var status: [Trash.DisplayStatus: Bool] = [
		.updateNeeded: true,
		.reported: true,
		.cleaned: true
	]
	var lastUpdate: LastUpdateFilter? = .noLimit
	var sizes: [Trash.Size] = []
	var types: [Trash.TrashType] = []
	var accessibility: Accessibility = Accessibility()

	enum LastUpdateFilter: String, EnumCollection {
		case noLimit
		case lastYear
		case lastMonth
		case lastWeek
		case today

		var date: Date {
			switch self {
			case .noLimit: return Date.init(timeIntervalSince1970: 0)
			case .lastMonth: return Date.init(timeIntervalSinceNow: -30*24*60*60)
			case .lastWeek: return Date.init(timeIntervalSinceNow: -7*24*60*60)
			case .lastYear: return Date.init(timeIntervalSinceNow: -365*24*60*60)
			case .today: return Date().dateAt(.startOfDay)
			}
		}
	}

	static var cachedFilter: TrashFilter {
		if let data = UserDefaults.standard.data(forKey: "TrashFilter") {
			if let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: AnyObject] {
				let filter = TrashFilter.create(from: json, usingId: nil) as? TrashFilter
				return filter ?? TrashFilter()
			}
		}
		return TrashFilter()
	}
    
    static func clearCachedFilter() {
        UserDefaults.standard.removeObject(forKey: "TrashFilter")
    }

	func cache() {
		let dict = self.dictionary()
		if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
			UserDefaults.standard.set(data, forKey: "TrashFilter")
		}
	}

	init() {
	}

	static func create(from json: [String : AnyObject], usingId id: Int?) -> AnyObject {
		let filter = TrashFilter()
		let sizes: [String] = json["sizes"] as? [String] ?? []
		filter.sizes = sizes.map({Trash.Size(rawValue: $0)!})
		let types: [String] = json["types"] as? [String] ?? []
		filter.types = types.map({Trash.TrashType(rawValue: $0)!})
		if let lu = json["lastUpdate"] as? String {
			filter.lastUpdate = LastUpdateFilter(rawValue: lu)
		}
		if let s = json["status"] as? [String: Bool] {
			for (st, v) in s {
				if let key = Trash.DisplayStatus(rawValue: st) {
					filter.status[key] = v
				}
			}
		}
		if let a = json["accessibility"] as? [String: AnyObject] {
			filter.accessibility = Accessibility.create(from: a) as! Accessibility
		}

		return filter
	}

	func dictionary() -> [String : AnyObject] {
		var dict: [String: AnyObject] = [:]

		var status: [String: Bool] = [:]
		for (s, v) in self.status {
			status[s.rawValue] = v
		}
		dict["status"] = status as AnyObject

		if let lu = self.lastUpdate {
			dict["lastUpdate"] = lu.rawValue as AnyObject
		}

		dict["sizes"] = self.sizes.map({$0.rawValue}) as AnyObject
		dict["types"] = self.types.map({$0.rawValue}) as AnyObject
		dict["accessibility"] = self.accessibility.dictionary() as AnyObject

		return dict
	}





	
}
