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


class LoadingView: UIView {


	enum Style {
		/// White style for cover content nontransparent (white)
		case white
		/// Show over content to allow see throught (black, alpha 0.8)
		case transparent
	}

	weak static var activeView: LoadingView?


	var indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)


	override init(frame: CGRect) {
		super.init(frame: frame)
		prepare()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		prepare()
	}

	func prepare() {
		self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
		indicator.color = Theme.current.color.green
		indicator.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
		self.addSubview(indicator)
	}

	static func show(on view: UIView, style: Style = .white) {
		let loading = LoadingView(frame: view.bounds)
		guard view.viewWithTag(2432342) == nil else { return }
		loading.tag = 2432342
		view.addSubview(loading)
		loading.layer.zPosition = 1000
		loading.indicator.startAnimating()
		switch style {
		case .transparent:
			loading.backgroundColor = UIColor.black.withAlphaComponent(0.8)
			break
		case .white:
			loading.backgroundColor = UIColor.white
		}
		activeView = loading
	}

	static func hide(animated: Bool = true) {
		activeView?.hide(animated: animated)
	}

	func hide(animated: Bool = true) {
		indicator.stopAnimating()
		if animated {
			UIView.animate(withDuration: 0.35, animations: { 
				self.alpha = 0
				}, completion: { (_) in
				self.removeFromSuperview()
			})
		} else {
			self.removeFromSuperview()
		}
	}

}
