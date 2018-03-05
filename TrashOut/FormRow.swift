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



class FormRow: UIView {

	@IBOutlet weak var view: UIView!

	@IBOutlet var textField: UITextField!
	@IBOutlet var lblError: UILabel!

	@IBOutlet var vError: UIView!
	@IBOutlet var ivError: UIImageView!

	@IBOutlet var cnsSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var errorViewHeight: NSLayoutConstraint!

	var showsSeparator: Bool = true

	func hideSeperator() {
		cnsSeparatorHeight.preciseConstant = 0
		showsSeparator = false
	}
	func showSeparator() {
		cnsSeparatorHeight.preciseConstant = 1
		showsSeparator = true
	}

	func showError(_ text: String) {
		UIView.animate(withDuration: 0.35, delay: 0, options: [.allowAnimatedContent, .allowUserInteraction, .beginFromCurrentState, .showHideTransitionViews], animations: {
			self.lblError.text = text
            self.lblError.numberOfLines = 0
            self.errorViewHeight.constant = CGFloat(self.lblError.numberOfVisibleLines) * 28
			self.vError.isHidden = false
			self.cnsSeparatorHeight.preciseConstant = 0
			}, completion: nil)
		UIView.transition(with: self.ivError, duration: 0.35, options: [.transitionCrossDissolve], animations: {
			self.ivError.isHidden = false
		}, completion: nil)
	}

	func hideError() {
		guard vError.isHidden == false else {return}
		UIView.animate(withDuration: 0.35, delay: 0, options: [.allowAnimatedContent, .allowUserInteraction, .beginFromCurrentState], animations: {
			self.lblError.text = ""
			self.vError.isHidden = true
			self.cnsSeparatorHeight.preciseConstant = self.showsSeparator ? 1 : 0
			}, completion: nil)
		UIView.transition(with: self.ivError, duration: 0.35, options: [.transitionCrossDissolve], animations: {
			self.ivError.isHidden = true
		}, completion: nil)
	}

//	convenience init() {
//		self.init(frame: CGRect.zero)
//	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.loadView()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.loadView()
	}

	func loadView() {
		let xib = UINib.init(nibName: "FormRow", bundle: Bundle.main)
		let view = xib.instantiate(withOwner: self, options: nil).first as! UIView
		self.view = view

		self.addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		view.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

		self.setupDefault()
	}

	func setupDefault() {
		lblError.text = ""
		self.vError.isHidden = true
		self.ivError.isHidden = true
		self.showSeparator()
	}

}
