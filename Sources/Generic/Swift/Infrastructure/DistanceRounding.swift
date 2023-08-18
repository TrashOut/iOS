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

class DistanceRounding {

	static let shared = DistanceRounding()


	// 5m, 10m, 20m, 50m, 100m, 200m, 500m, 1km, 2km, 5km, 10km, > 10km (away)
	func localizedDistance(meteres: Int) -> String {
		if Locale.current.usesMetricSystem {
			return self.metricDistance(meteres: meteres) + " " + "global.distanceAttribute.away".localized
		} else {
			return self.milesDistance(meteres: meteres) +  " " + "global.distanceAttribute.away".localized
		}
	}

	/// 5m, 10m, 20m, 50m, 100m, 200m, 500m, 1km, 2km, 5km, 10km, > 10km (away)
	internal func metricDistance(meteres: Int) -> String {
		switch meteres {
		case 0...5: return "5 m"
		case 6...10: return "10 m"
		case 11...20: return "20 m"
		case 21...50: return "50 m"
		case 51...100: return "100 m"
		case 101...200: return "200 m"
		case 201...500: return "500 m"
		case 501...1000: return "1 km"
		case 1001...2000: return "2 km"
		case 2001...5000: return "5 km"
		case 5001...10000: return "10 km"
		default: return "> 10 km"
		}
	}

	// TODO: rounding
	internal func milesDistance(meteres: Int) -> String {
		if #available(iOS 10.0, *) {
			return milesDistanceV2(meteres: meteres)
		}

		let miles: Double = Double(meteres) * 0.00062137
		let yards: Double = miles * 1760
		#if DEBUG
		print("\(meteres) m = \(miles)mi or \(yards)yd")
		#endif
		if miles < 1 {

			switch yards {
			case 0...100: return "100yd"
			case 101...1000: return "1000yd"
			default:
				return "1mi"
			}
		}
		switch miles {
		case 1...2:
			return "2mi"
		case 2...5:
			return "5mi"
		case 5...10:
			return "10mi"
		case 10...20:
			return "20mi"
		default:
			return "> 20mi"
		}
	}

	internal func milesDistanceV2(meteres: Int) -> String {

		let miles: Double = Double(meteres) * 0.00062137
		let yards: Double = miles * 1760
		#if DEBUG
			print("\(meteres) m = \(miles)mi or \(yards)yd")
		#endif
		let f = MeasurementFormatter()
		f.unitStyle = .short
		f.unitOptions = .providedUnit

		if miles < 1 {

			switch yards {
			case 0...100:
				return f.string(from: Measurement(value: 100, unit: UnitLength.yards))
			case 101...1000: return f.string(from: Measurement(value: 1000, unit: UnitLength.yards))
			default:
				return f.string(from: Measurement(value: 1, unit: UnitLength.miles))
			}
		}
		switch miles {
		case 0...1:
			return f.string(from: Measurement(value: 1, unit: UnitLength.miles))
		case 1...2:
			return f.string(from: Measurement(value: 2, unit: UnitLength.miles))
		case 2...5:
			return f.string(from: Measurement(value: 5, unit: UnitLength.miles))
		case 5...10:
			return f.string(from: Measurement(value: 10, unit: UnitLength.miles))
		case 10...20:
			return f.string(from: Measurement(value: 20, unit: UnitLength.miles))
		default:
			return "> \(f.string(from: Measurement(value: 20, unit: UnitLength.miles)))"
		}
	}



//	/**
//    Return rounded distance
//    */
//    static func roundDistance(distance: Int) -> Int {
//        if distance <= 5 {
//            return 5
//        } else if distance > 5 && distance <= 10 {
//            return 10
//        } else if distance > 10 && distance <= 50 {
//            return 50
//        } else if distance > 50 && distance <= 100 {
//            return 100
//        } else if distance > 100 && distance <= 200 {
//            return 200
//        } else if distance > 200 && distance <= 500 {
//            return 500
//        } else if distance > 500 && distance <= 1000 {
//            return 1
//        } else if distance > 1000 && distance <= 2000 {
//            return 2
//        } else if distance > 2000 && distance <= 5000 {
//            return 5
//        } else if distance > 5000 && distance <= 10000 {
//            return 10
//        } else {
//            return 10001
//        }
//    }

}
