//
//  TrashTypeButton.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 25.01.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit

class TrashTypeButton: UIButton {

	override var bounds: CGRect {
		set {
			super.bounds = newValue

			self.layer.cornerRadius = 0.5 * self.bounds.height
			self.layer.borderWidth = 3/UIScreen.main.scale
			self.layer.borderColor = UIColor.lightGray.cgColor
			self.clipsToBounds = true
		}
		get {
			return super.bounds
		}
	}

	override var frame: CGRect {
		set {
			super.frame = newValue

			self.layer.cornerRadius = 0.5 * self.frame.height
			self.layer.borderWidth = 3/UIScreen.main.scale
			self.layer.borderColor = UIColor.lightGray.cgColor
			self.clipsToBounds = true
		}
		get {
			return super.frame
		}
	}

	var selectedColor: UIColor?
	

	override var isSelected: Bool {
		didSet {
			super.isSelected = isSelected
			if isSelected {
				self.backgroundColor = selectedColor
			} else {
				self.backgroundColor = UIColor.clear
			}
		}
	}
	
}
