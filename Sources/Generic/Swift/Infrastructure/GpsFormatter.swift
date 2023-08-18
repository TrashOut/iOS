//
//  TrashOut
//  Copyright 2017 TrashOut NGO. All rights reserved.
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

class GpsFormatter {

    static let gpsFormatterTypeKey = "GpsFormatterType"

    enum Format: String, EnumCollection {
        case decimal
        case degrees

        var instance: GpsFormatter {
            switch self {
            case .decimal:
                return DecimalGpsFormatter()
            case .degrees:
                return DegreesGpsFormatter()
            }
        }
    }

    static var instance: GpsFormatter {
        return defaultFormat.instance
    }

    init() {}

    static var defaultFormat: Format {
        get {
            if let typeString = UserDefaults.standard.string(forKey: GpsFormatter.gpsFormatterTypeKey),
                let type = Format(rawValue: typeString) {
                return type
            } else {
                return .decimal
            }
        }
        set(newValue) {
            UserDefaults.standard.set(newValue.rawValue, forKey: GpsFormatter.gpsFormatterTypeKey)
        }
    }

    func string(from gps: GPS) -> String {
        return self.string(fromLat: gps.lat, lng: gps.long)
    }

    func string(fromLat _: Double, lng _: Double) -> String {
        fatalError("Method should be implemented in subclass")
    }
}

class DecimalGpsFormatter: GpsFormatter {
    override func string(fromLat lat: Double, lng: Double) -> String {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 7
        nf.minimumIntegerDigits = 1
        nf.decimalSeparator = "."
        
        if let latitude = nf.string(from: NSNumber.init(value: lat)),
            let longitude = nf.string(from: NSNumber.init(value: lng)) {
            return "\(latitude), \(longitude)"
        } else {
            return ""
        }
    }
}

class DegreesGpsFormatter: GpsFormatter {

    override func string(fromLat lat: Double, lng: Double) -> String {
        let n = lat >= 0 ? "N" : "S"
        let w = lng >= 0 ? "E" : "W"
        let absLat = abs(lat)
        let absLng = abs(lng)
        let latDgr = Int(absLat)
        let lngDgr = Int(absLng)
        let latM = Int((absLat - Double(latDgr)) * 60)
        let lngM = Int((absLng - Double(lngDgr)) * 60)
        let d = "\u{00B0}"
        let m = "\u{2032}"
        let s = "\u{2033}"
        let latS = Int((absLat * 3600) - Double(latDgr) * 3600 - Double(latM) * 60)
        let lngS = Int((absLng * 3600) - Double(lngDgr) * 3600 - Double(lngM) * 60)
        return "\(latDgr)\(d) \(latM)\(m) \(latS)\(s) \(n), \(lngDgr)\(d) \(lngM)\(m) \(lngS)\(s) \(w)"
    }
}
