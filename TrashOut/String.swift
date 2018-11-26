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

extension String {

	/**
	Translate string to locale

	Tries localize using `self.remoteLocalized`

	- SeeAlso: `remoteLocalized`
	*/
	var localized: String {
		get {
//			if let remoteLocalization = self.remoteLocalized {
//				#if DEBUG
//				print("Localized from remote: \(self) -> \(remoteLocalization)")
//				#endif
//				return remoteLocalization
//			}
			#if DEBUG
				let debugValue = "XXX _ String not localized _ XXX"
				let str = NSLocalizedString(self, tableName: "Localizable", bundle: Bundle.main, value: debugValue, comment: "")
				if str == debugValue {
					print("Error: There is no localization for '\(self)'")
				}
			#endif
            let loc = NSLocalizedString(self, tableName: "Localizable", bundle: Bundle.main, value: self, comment: "")
            let replaced = loc.replacingOccurrences(of: "%s", with: "%@")
			return replaced
		}
	}

	func localized(_ count: Int) -> String {
		return NSString.localizedStringWithFormat(self.localized as NSString, count) as String
	}

    /**
    Uppercase only the first letter in string
    */
    var uppercaseFirst: String {
        return String(characters.prefix(1)).uppercased() + String(characters.dropFirst())
    }

}

extension UIFont {


	var monospacedDigitFont: UIFont {
		let oldFontDescriptor = self.fontDescriptor
		let newFontDescriptor = oldFontDescriptor.monospacedDigitFontDescriptor
		return UIFont(descriptor: newFontDescriptor, size: 0)
	}

}

private extension UIFontDescriptor {

	var monospacedDigitFontDescriptor: UIFontDescriptor {
		let fontDescriptorFeatureSettings = [[
			convertFromUIFontDescriptorFeatureKey(UIFontDescriptor.FeatureKey.featureIdentifier): kNumberSpacingType,
			convertFromUIFontDescriptorFeatureKey(UIFontDescriptor.FeatureKey.typeIdentifier): kMonospacedNumbersSelector]]
		let fontDescriptorAttributes = [convertFromUIFontDescriptorAttributeName(UIFontDescriptor.AttributeName.featureSettings): fontDescriptorFeatureSettings]
		let fontDescriptor = self.addingAttributes(convertToUIFontDescriptorAttributeNameDictionary(fontDescriptorAttributes))
		return fontDescriptor
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIFontDescriptorFeatureKey(_ input: UIFontDescriptor.FeatureKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIFontDescriptorAttributeName(_ input: UIFontDescriptor.AttributeName) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIFontDescriptorAttributeNameDictionary(_ input: [String: Any]) -> [UIFontDescriptor.AttributeName: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIFontDescriptor.AttributeName(rawValue: key), value)})
}
