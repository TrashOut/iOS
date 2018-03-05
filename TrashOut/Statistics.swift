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


class StatisticsManager {

	enum StatisticsType: String, EnumCollection {
		case reported
		case cleaned

		var image: UIImage {
			switch self {
			case .reported:
				return #imageLiteral(resourceName: "Reported")
			case .cleaned:
				return #imageLiteral(resourceName: "Cleaned")
			}
		}

		var localizedName: String {
			switch self {
			case .reported:
				return "profile.reported".localized
			case .cleaned:
				return "profile.cleaned".localized
			}
		}
		var color: UIColor {
			switch self {
			case .reported:
				return Theme.current.color.red
			case .cleaned:
				return Theme.current.color.green
			}
		}
	}

	init() { }

	var worldwide: [StatisticsType: Int] = [:]
	var stats: [Area: [StatisticsType: Int]] = [:]
	

	func loadWorld(completion: @escaping () -> (), failure: @escaping (Error) -> ()) {
		self.loadStatistics(for: nil, completion: completion, failure: failure)
	}

	func loadStatistics(for area: Area?, completion: @escaping () -> (), failure: @escaping (Error) -> ()) {
		if let area = area {
			self.stats[area] = [:]
		} else {
			self.worldwide = [:]
		}
		var downloadBlocks: [Async.Block] = []
		for type in StatisticsType.allValues {
			downloadBlocks.append({ [weak self] (completion: @escaping ()->(), failure: @escaping (Error)->()) in
				self?.loadStatistics(area: area, type: type, completion: completion, failure: failure)
				})
		}
		let cb = completion
		downloadBlocks.append({ (completion: @escaping ()->(), failure: @escaping (Error)->()) in
			cb()
			completion()
		})
		Async.waterfall(downloadBlocks) { (error) in
			failure(error)
		}
	}

	func loadStatistics(area: Area?, type: StatisticsType, completion: @escaping () -> (), failure: @escaping (Error) -> ()) {
		var status: [String] = []
		switch type {
		case .reported:
			status = ["stillHere", "more", "less"]
			break
		case .cleaned:
			status = ["cleaned"]
			break
		}
		Networking.instance.trashesCount(area: area, status: status) { [weak self] (count, error) in
			if let error = error {
				print(error.localizedDescription)
				failure(error)
				return
			}
			let cnt = count ?? 0
			if let area = area {
				var s = self?.stats[area] ?? [:]
				s[type] = cnt
				self?.stats[area] = s
			} else {
				self?.worldwide[type] = cnt
			}
			completion()
		}
	}

}
