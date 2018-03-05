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

extension UIButton {

    func theme() {
		self.translatesAutoresizingMaskIntoConstraints = false
        self.contentEdgeInsets = UIEdgeInsetsMake(8, 15, 8, 15)
        self.sizeToFit()

		var heightConstraints: [NSLayoutConstraint] = self.constraints.filter({ $0.firstItem === self && $0.firstAttribute == .height && NSStringFromClass(type(of: $0)) != "NSContentSizeLayoutConstraint" })
        if heightConstraints.count == 0 {
            let cns = self.heightAnchor.constraint(equalToConstant: self.frame.size.height)
			cns.isActive = true
			heightConstraints.append(cns)
        }
		if heightConstraints.count != 1 {
			print("Warning: Invalid constraints setup for Button \(self), \(self.constraints)")

		}

		for cns in heightConstraints {
		    self.layer.cornerRadius = cns.constant / 2
			self.layer.masksToBounds = true
        }
        self.backgroundColor = UIColor.theme.button
        self.setTitleColor(UIColor.white, for: UIControlState())
    }
}

extension UIView {
    /**
     Shortcut for constraint getter
     */
    public func constraint(for attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        var att = self.constraints.first(where: { (c) -> Bool in
            return c.firstItem as! NSObject == self && c.firstAttribute == attribute
        })
        if att != nil {
			return att
		}
        att = self.superview?.constraints.first(where: { (c) -> Bool in
            return c.firstItem as! NSObject == self && c.firstAttribute == attribute
        })
        return att
    }
}
