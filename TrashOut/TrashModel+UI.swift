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
import UIKit

extension Trash.DisplayStatus {

    var localizedName: String {
        switch self {
        case .cleaned:
            return "profile.cleaned".localized
        case .reported:
            return "profile.reported".localized
        case .updateNeeded:
            return "trash.updateNeeded".localized
        }
    }

    var image: UIImage {
        switch self {
        case .cleaned:
            return #imageLiteral(resourceName: "Cleaned")
        case .reported:
            return #imageLiteral(resourceName: "Reported")
        case .updateNeeded:
            return #imageLiteral(resourceName: "Unknown")
        }
    }

    static func getStatus(trash: Trash) -> Trash.DisplayStatus {
        if trash.status == .cleaned { return .cleaned }
        if trash.updateNeeded { return .updateNeeded }
        return .reported
    }

    static func getStatus(trash: TrashPoint) -> Trash.DisplayStatus {
        if trash.status == .cleaned { return .cleaned }
        if trash.updateNeeded { return .updateNeeded }
        return .reported
    }
}

extension Trash.HistoryStatus {

    var localizedName: String {
        switch self {
        case .cleaned: return "profile.cleaned".localized
        case .less: return "trash.status.less".localized
        case .more: return "trash.status.more".localized
        case .reported: return "profile.reported".localized
        case .updated: return "trash.updated".localized
        }
    }

    var color: UIColor {
        switch self {
        case .cleaned: return Theme.current.color.green
        case .less: return Theme.current.color.orange
        case .more: return Theme.current.color.orange
        case .reported: return Theme.current.color.red
        case .updated: return Theme.current.color.orange
        }
    }

    var image: UIImage {
        switch self {
        case .cleaned: return #imageLiteral(resourceName: "Cleaned")
        case .less: return #imageLiteral(resourceName: "Updated")
        case .more: return #imageLiteral(resourceName: "Updated")
        case .reported: return #imageLiteral(resourceName: "Reported")
        case .updated: return #imageLiteral(resourceName: "Updated")
        }
    }

    static func getStatus(update: TrashUpdate, in context: Trash) -> Trash.HistoryStatus {
        guard let change = update.status else {
            return .updated
        } // There should be always status set, so no use for this
        switch change {
        case .cleaned:
            return .cleaned
        case .less:
            return .less
        case .more:
            return .more
        case .stillHere:
            //if context.updates.last?.id == update.id { return .reported }
            //else { return .updated }
            if context.updates.last?.id == update.id { return .reported }
            else { return .updated }
        }
    }
}

extension Trash.DetailStatus {

    var image: UIImage {
        switch self {
        case .cleaned: return #imageLiteral(resourceName: "Cleaned")
        case .less, .more, .updated: return #imageLiteral(resourceName: "Updated")
        case .updateNeeded: return #imageLiteral(resourceName: "Unknown")
        case .reported: return #imageLiteral(resourceName: "Reported")
        }
    }

    var mapAnnotationImage: UIImage {
        switch self {
        case .cleaned: return #imageLiteral(resourceName: "MapAnnotationCleaned")
        case .less, .more, .updated: return #imageLiteral(resourceName: "MapAnnotationUpdated")
        case .updateNeeded: return #imageLiteral(resourceName: "MapAnnotationUnknown")
        case .reported: return #imageLiteral(resourceName: "MapAnnotationReported")
        }
    }
    
    var color: UIColor {
        switch self {
        case .cleaned: return Theme.current.color.green
        case .less, .more, .updated: return Theme.current.color.orange
        case .updateNeeded: return Theme.current.color.red
        case .reported: return Theme.current.color.red
        }
    }

    var localizedName: String {
        switch self {
        case .reported: return "profile.reported".localized
        case .less: return "trash.status.less".localized
        case .more: return "trash.status.more".localized
        case .updated: return "trash.updated".localized
        case .updateNeeded: return "trash.updateNeeded".localized
        case .cleaned: return "profile.cleaned".localized
        }
    }

    static func getStatus(in context: Trash) -> Trash.DetailStatus {
        if context.updateNeeded {
            return .updateNeeded
        }
        switch context.status {
        case .cleaned: return .cleaned
        case .less: return .less
        case .more: return .more
        case .stillHere:
            if context.updates.count == 1 { return .reported }
            else { return .updated }
        }
    }
    
    static func getStatus(in context: TrashUpdate) -> Trash.DetailStatus {
        if let status = context.status {
            switch status {
            case .cleaned: return .cleaned
            case .less: return .less
            case .more: return .more
            case .stillHere: return .reported
            }
        } else {
            return .reported
        }
    }
}

extension Trash.TrashType {

    static var allValues: [Trash.TrashType] {
        return [
            .domestic, .automotive, .construction,
            .plastic, .electronic, .organic,
            .metal, .liquid, .dangerous,
            .deadAnimals, .glass
        ]
    }

    var localizedName: String {
        switch self {
        case .domestic: return "trash.types.domestic".localized
        case .automotive: return "trash.types.automotive".localized
        case .construction: return "trash.types.construction".localized
        case .plastic: return "trash.types.plastic".localized
        case .electronic: return "trash.types.electronic".localized
        case .organic: return "trash.types.organic".localized
        case .metal: return "trash.types.metal".localized
        case .liquid: return "trash.types.liquid".localized
        case .dangerous: return "trash.types.dangerous".localized
        case .deadAnimals: return "trash.types.deadAnimals".localized
        case .glass: return "trash.types.glass".localized
        default:
            return self.rawValue
        }
    }

    var image: UIImage {
        switch self {
        case .automotive: return #imageLiteral(resourceName: "Automotive")
        case .construction: return #imageLiteral(resourceName: "Construction")
        case .dangerous: return #imageLiteral(resourceName: "Dangerous")
        case .deadAnimals: return #imageLiteral(resourceName: "Animals")
        case .metal: return #imageLiteral(resourceName: "Metal")
        case .domestic: return #imageLiteral(resourceName: "Domestic")
        case .electronic: return #imageLiteral(resourceName: "Electronic")
        case .liquid: return #imageLiteral(resourceName: "Liquid")
        case .organic: return #imageLiteral(resourceName: "Organic")
        case .plastic: return #imageLiteral(resourceName: "Plastic")
        case .glass: return #imageLiteral(resourceName: "Glass")
        case .undefined: return UIImage()
        }
    }

    var highlightImage: UIImage {
        switch self {
        case .automotive: return #imageLiteral(resourceName: "AutomotiveClear")
        case .construction: return #imageLiteral(resourceName: "ConstructionClear")
        case .dangerous: return #imageLiteral(resourceName: "DangerousClear")
        case .deadAnimals: return #imageLiteral(resourceName: "AnimalsClear")
        case .metal: return #imageLiteral(resourceName: "MetalClear")
        case .domestic: return #imageLiteral(resourceName: "DomesticClear")
        case .electronic: return #imageLiteral(resourceName: "ElectronicClear")
        case .liquid: return #imageLiteral(resourceName: "LiquidClear")
        case .organic: return #imageLiteral(resourceName: "OrganicClear")
        case .plastic: return #imageLiteral(resourceName: "PlasticClear")
        case .glass: return #imageLiteral(resourceName: "GlassClear")
        case .undefined: return UIImage()
        }
    }

    var highlightColor: UIColor {
        switch self {
        case .automotive: return Theme.current.color.automotive
        case .construction: return Theme.current.color.construction
        case .dangerous: return Theme.current.color.dangerous
        case .deadAnimals: return Theme.current.color.deadAnimals
        case .liquid: return Theme.current.color.liquid
        case .metal: return Theme.current.color.metal
        case .organic: return Theme.current.color.organic
        case .plastic: return Theme.current.color.plastic
        case .electronic: return Theme.current.color.electronic
        case .domestic: return Theme.current.color.domestic
        case .glass: return Theme.current.color.glass
        case .undefined: return UIColor.clear
        }
    }
}

extension Trash.Size {

    static var allValues: [Trash.Size] {
        return [.bag, .wheelbarrow, .car]
    }

    struct UI {
        var localizedName: String
        var image: UIImage
        var highlightColor: UIColor
    }

    static var ui: [Trash.Size: UI] {
        return [
            .bag: UI(
                localizedName: "trash.size.bag".localized,
                image: #imageLiteral(resourceName: "Bag"),
                highlightColor: Theme.current.color.green
            ),
            .wheelbarrow: UI(
                localizedName: "trash.size.wheelbarrow".localized,
                image: #imageLiteral(resourceName: "Wheelbarrow"),
                highlightColor: Theme.current.color.green
            ),
            .car: UI(
                localizedName: "trash.size.carNeeded".localized,
                image: #imageLiteral(resourceName: "Car"),
                highlightColor: Theme.current.color.green
            ),
        ]
    }

    var localizedName: String {
        return Trash.Size.ui[self]!.localizedName
    }

    var image: UIImage {
        return Trash.Size.ui[self]!.image
    }

    var highlightColor: UIColor {
        return Trash.Size.ui[self]!.highlightColor
    }
}

extension TrashFilter.LastUpdateFilter {

    static var allValues: [TrashFilter.LastUpdateFilter] {
        return [.noLimit, .lastYear, .lastMonth, .lastWeek, .today]
    }

    // ["trash.filter.lastUpdate.noLimit".localized, "trash.filter.lastUpdate.lastYear".localized, "trash.filter.lastUpdate.lastMonth".localized, "trash.filter.lastUpdate.lastWeek".localized, "trash.filter.lastUpdate.today".localized]
    var localizedName: String {
        switch self {
        case .noLimit:
            return "trash.filter.lastUpdate.noLimit".localized
        case .lastWeek:
            return "trash.filter.lastUpdate.lastWeek".localized
        case .lastYear:
            return "trash.filter.lastUpdate.lastYear".localized
        case .today:
            return "trash.filter.lastUpdate.today".localized
        case .lastMonth:
            return "trash.filter.lastUpdate.lastMonth".localized
        }
    }
}

extension Accessibility.AccessibilityType {

    var localizedName: String {
        switch self {
        case .byCar:
            return "trash.accessibility.byCar".localized
        case .inCave:
            return "trash.accessibility.inCave".localized
        case .underWater:
            return "trash.accessibility.underWater".localized
        case .notForGeneralCleanup:
            return "trash.accessibility.notForGeneralCleanup".localized
        }
    }
}
