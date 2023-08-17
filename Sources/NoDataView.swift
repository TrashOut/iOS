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


class NoDataView: UIView {

	static let noDataViewTag = 328572

	var label: UILabel?


	static func show(over view: UIView?, text: String? = nil) {
		guard let view = view else { return }
		guard view.viewWithTag(noDataViewTag) as? NoDataView == nil else { return }
		let ndv = NoDataView.init(frame: view.bounds)
		ndv.backgroundColor = UIColor.white
		ndv.tag = noDataViewTag

		view.addSubview(ndv)


		ndv.translatesAutoresizingMaskIntoConstraints = false
		ndv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		ndv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		ndv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		ndv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

		let label = UILabel.init(frame: ndv.bounds)
		label.font = Theme.current.font.text
		label.textColor = Theme.current.color.lightGray
		label.numberOfLines = 0
		label.textAlignment = .center
		label.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
		ndv.addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.leadingAnchor.constraint(equalTo: ndv.leadingAnchor, constant: 12).isActive = true
		label.trailingAnchor.constraint(equalTo: ndv.trailingAnchor, constant: -12).isActive = true
		label.topAnchor.constraint(equalTo: ndv.topAnchor, constant: 12).isActive = true
		label.bottomAnchor.constraint(equalTo: ndv.bottomAnchor, constant: -12).isActive = true

		ndv.label = label
		if let msg = text {
			label.text = msg
		} else {
			label.text = "Failed to load data".localized
		}
	}

	static func hide(from view: UIView?, animated: Bool = false) {
		guard let view = view else { return }
		guard let ndv = view.viewWithTag(noDataViewTag) as? NoDataView else { return }
		if animated {
			UIView.animate(withDuration: 0.35, animations: { 
				ndv.alpha = 0
				}, completion: { (_) in
				ndv.removeFromSuperview()
			})
		} else {
			ndv.removeFromSuperview()
		}
	}



	override func layoutSubviews() {
		super.layoutSubviews()
		guard let bounds = superview?.bounds else { return }
		self.frame = CGRect.init(x: 0, y: 0 , width: bounds.size.width, height: bounds.size.height)
		self.label?.frame = CGRect.init(x: 12, y: 12 , width: bounds.size.width - 24, height: bounds.size.height - 24)
	}


}
