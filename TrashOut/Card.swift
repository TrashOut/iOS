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

class Card: UIView {

	override var bounds: CGRect {
		set {
			super.bounds = newValue
			self.asCard()
		}
		get {
			return super.bounds
		}
	}

	override var frame: CGRect {
		set {
			super.frame = newValue
			self.asCard()
		}
		get {
			return super.frame
		}
	}
}

class CardButton: UIButton {
	override var bounds: CGRect {
		set {
			super.bounds = newValue
			self.asCard()
		}
		get {
			return super.bounds
		}
	}

	override var frame: CGRect {
		set {
			super.frame = newValue
			self.asCard()
		}
		get {
			return super.frame
		}
	}
}

extension UIView {
	/**
	Add shaddow to look like a card
	Inspired by https://github.com/NathanWalker/MaterialCard
	*/

    func asCard() {
		let cornerRadius: CGFloat = 4
		layer.cornerRadius = cornerRadius

		let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
		layer.masksToBounds = false
        layer.shadowRadius = 2
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 0)
		layer.shadowOpacity = 0.3
		layer.shadowPath = shadowPath.cgPath
	}

}
