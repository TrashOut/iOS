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

/**
Separator line with exactly 1 pixel (non retina) height
*/
@IBDesignable
class HorizontalSeparator: UIView {


	override var frame: CGRect {
		set(newValue) {
			super.frame = CGRect(x: newValue.origin.x, y: newValue.origin.y, width: newValue.size.width, height: 1/UIScreen.main.scale)
		}
		get {
			return super.frame
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.backgroundColor = Theme.current.color.separatorLine
		self.frame.size.height = 1/UIScreen.main.scale
	}

}
