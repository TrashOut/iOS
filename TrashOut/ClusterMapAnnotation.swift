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
import MapKit

class ClusterMapAnnotation: MapAnnotation, AnnotationCluster {

    var count: Int = 0
    var cleaned: Int = 0
    var updateNeeded: Int = 0
    var reported: Int = 0

    var annotations: [MKAnnotation] = [] {
        didSet {
            count = annotations.count
        }
    }

    var rect: MKMapRect?
    var zoom: MKZoomScale?
    var cell: String?

    override func getView(for map: MKMapView) -> MKAnnotationView? {
		let av: ClusterMapAnnotationView = map.dequeueReusableAnnotationView(withIdentifier: "ClusterView") as? ClusterMapAnnotationView ?? ClusterMapAnnotationView(annotation: self, reuseIdentifier: "ClusterView")

        if annotations.count > 0 { // clustered at phone
			let cleanedCount = self.cleanedCount
			let updateNeededCount = self.updateNeededCount
            let reported: Int = annotations.count - updateNeededCount - cleanedCount
            self.setupRedDots(reported: reported, cleaned: cleanedCount, updateNeeded: updateNeededCount, at: av)
        } else { // cluster at server
            setupRedDots(reported: self.reported - self.updateNeeded, cleaned: self.cleaned, updateNeeded: self.updateNeeded, at: av)
        }
        self.setupLabel(at: av)
        return av
    }

	internal var cleanedCount: Int {
		guard annotations.count > 0 else { return self.cleaned }
		let cleaned = annotations.filter { (a) -> Bool in
			if let ta = a as? TrashMapAnnotation,
				let status = ta.status {
				return status == .cleaned
			}
			return false
		}
		return cleaned.count
	}

	internal var updateNeededCount: Int {
		guard annotations.count > 0 else { return self.updateNeeded }
		let updateNeeded = annotations.filter { (a) -> Bool in
			if let ta = a as? TrashMapAnnotation, let status = ta.status {
				return status == .updateNeeded
			} else {
				return false
			}
		}
		return updateNeeded.count
	}


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

	enum DotsVariant {
		case allGreen
		case allRed
		case allYellow
		case twoGreenOneRed
		case twoGreenOneYellow
		case twoRedOneGreen
		case twoRedOneYellow
		case twoYellowOneRed
		case twoYellowOneGreen
		case oneAll

		var green: Int {
			switch self {
			case .allGreen:
				return 3
			case .twoGreenOneRed, .twoGreenOneYellow:
				return 2
			case .twoRedOneGreen, .twoYellowOneGreen, .oneAll:
				return 1
			default:
				return 0
			}
		}

		var red: Int {
			switch self {
			case .allRed:
				return 3
			case .twoRedOneGreen, .twoRedOneYellow:
				return 2
			case .twoGreenOneRed, .twoYellowOneRed, .oneAll:
				return 1
			default:
				return 0
			}
		}

		var yellow: Int {
			switch self {
			case .allYellow:
				return 3
			case .twoYellowOneRed, .twoYellowOneGreen:
				return 2
			case .twoRedOneYellow, .twoGreenOneYellow, .oneAll:
				return 1
			default:
				return 0
			}
		}


		/**
		Select display case for given counts
		*/
		static func getVariant(reported: Int, cleaned: Int, updateNeeded: Int) -> DotsVariant { // tailor:disable
			switch (reported, cleaned, updateNeeded) {
			case (_, 0, 0):
				return .allRed
			case (0, _, 0):
				return .allGreen
			case (0, 0, _):
				return .allYellow
			case (1..<Int.max, _, 0) where reported <= cleaned:
				return .twoGreenOneRed
			case (_, 1..<Int.max, 0) where reported > cleaned:
				return .twoRedOneGreen
			case (1..<Int.max, 1..<Int.max, 1..<Int.max):
				return .oneAll
			case (_, _, 1..<Int.max) where cleaned >= updateNeeded:
				return .twoGreenOneYellow
			case (_, 1..<Int.max, _) where cleaned < updateNeeded:
				return .twoYellowOneGreen
			case (_, _, 1..<Int.max) where reported >= updateNeeded:
				return .twoRedOneYellow
			case (1..<Int.max, _, _) where updateNeeded > reported:
				return .twoYellowOneRed
			default:
				print("There is some error in dots thing")
				return .allYellow
			}
		}
	}



	func setupRedDots(reported: Int, cleaned: Int, updateNeeded: Int, at view: ClusterMapAnnotationView) {
		let variant: DotsVariant = DotsVariant.getVariant(reported: reported, cleaned: cleaned, updateNeeded: updateNeeded)

		view.green = variant.green
		view.red = variant.red
		view.yellow = variant.yellow
        view.updateColors()
    }

    func setupLabel(at view: ClusterMapAnnotationView) {
        view.label?.text = ClusterRounding.shared.round(count: count)
    }

    override var debugDescription: String {
        return "\(coordinate.latitude), \(coordinate.longitude) => \(count)"
    }
}

class ClusterMapAnnotationView: MKAnnotationView {

    var label: UILabel?
    var dots: [UIView] = []

    var green: Int = 0
    var yellow: Int = 0
    var red: Int = 0

    func updateColors() {
        for i in 0 ..< dots.count {
            if i < red {
                dots[i].backgroundColor = UIColor.theme.red
            } else if i < red + yellow {
                dots[i].backgroundColor = UIColor.theme.red
            } else {
                dots[i].backgroundColor = UIColor.theme.green
            }
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

	func setupDots(on view: UIView, basicSize size: CGFloat) {
		let dotSize: CGFloat = 9
		let baseX: CGFloat = (size - dotSize) / 2
		let spacing: CGFloat = 2
		let y: CGFloat = size / 2 + 7
		for i in -1 ... 1 { // ordered from center
			let x = baseX + (dotSize + spacing) * CGFloat(i)
			let dot = UIView(frame: CGRect.init(origin: CGPoint.init(x: x, y: y), size: CGSize.init(width: dotSize, height: dotSize)))
			dot.layer.cornerRadius = dotSize / 2
			dot.backgroundColor = UIColor.red
			view.addSubview(dot)
			dots.append(dot)
		}
	}

    func setup() {
        let size: CGFloat = 60
        let view = UIView(frame: CGRect.init(origin: CGPoint.init(x: -size / 2, y: -size / 2), size: CGSize.init(width: size, height: size)))
        self.addSubview(view)
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = size / 2
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        view.layer.borderWidth = 3
		self.setupDots(on: view, basicSize: size)
        label = UILabel.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: size, height: size - 10)))
        label?.text = ""
        label?.textAlignment = .center
        view.addSubview(label!)
    }

    override func prepareForReuse() {
        label?.text = ""
    }
}
