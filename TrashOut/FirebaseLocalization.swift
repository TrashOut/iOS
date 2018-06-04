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
import Firebase
import FirebaseStorage
//import SSZipArchive

extension String {

	/**
	String localization using Crowdin downloaded files
	*/
	var remoteLocalized: String? {
		guard let bundle = FirebaseLocalization.bundle else { return nil }

		let debugValue = "XXX _ String not localized _ XXX"
		let str = NSLocalizedString(self, tableName: "Localizable", bundle: bundle, value: debugValue, comment: "")
		if str == debugValue { // No localization found
			#if DEBUG
				print("Error: There is no localization for '\(self)'")
			#endif
			return nil
		}
		return str // NSLocalizedString(self, tableName: "Localizable", bundle: bundle, value: self, comment: "")
	}
}

class FirebaseLocalization {

	static var bundle: Bundle? = {
		return FirebaseLocalization.getBundle()
	} ()

	static var downloadedBundleUrl: URL = {
		let directoryURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("TrashOut", isDirectory: true)
		return directoryURL.appendingPathComponent("translations.bundle")
	} ()

	static func getBundle() -> Bundle? {
		return Bundle.init(url: downloadedBundleUrl)
	}

	let remoteZipFilePath = "translation/ios/translations.bundle.zip"
	let timestampDefaultsKey = "FirebaseLocalizationTimestamp"

	func update() {
        let ref = Storage.storage().reference(withPath: remoteZipFilePath)
		ref.getMetadata { (metadata, error) in // retain self
			guard error == nil else {
				print(error!.localizedDescription)
				return
			}
			guard let metadata = metadata else {
				print("Error: metadata not returned from firebase")
				return
			}
			self.update(ref, with: metadata)
		}
	}

    func update(_ ref: StorageReference, with metadata: StorageMetadata) {
		// timestamp for remote file
		guard let timestamp = metadata.updated ?? metadata.timeCreated else { return }
		// timestamp of current downloaded file
		if let localTimestamp = UserDefaults.standard.object(forKey: timestampDefaultsKey) as? Date,
			timestamp <= localTimestamp { // no idea when local will be newer than remote..
			return
		} else {
			downloadBundle(at: ref, callback: { (success) in // retain self
				if success {
					UserDefaults.standard.set(timestamp, forKey: self.timestampDefaultsKey)
				}
			})
		}
	}

    func downloadBundle(at ref: StorageReference, callback: @escaping (Bool) -> ()) {
//		let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("translations.bundle.zip")
		let tempURL = URL.init(fileURLWithPath: NSTemporaryDirectory())
		let localURL = tempURL.appendingPathComponent("translations.bundle.zip")
		let _ = ref.write(toFile: localURL) { (url, error) in
			guard error == nil else {
				print(error?.localizedDescription as Any)
				callback(false)
				return
			}
			guard let url = url else {
                callback(false)
                return
            }
			DispatchQueue.global(qos: .background).async {
				self.unzip(file: url, callback: callback)
			}
		}
	}

	/**
	Unzip downloaded file

	Assumming zip contains translations.bundle folder

	- Warning: Run me using background queue
	*/
	func unzip(file url: URL, callback: @escaping (Bool) -> ()) {
//		SSZipArchive.unzipFile(atPath: url.path, toDestination: FirebaseLocalization.downloadedBundleUrl.appendingPathComponent("..", isDirectory: true).path, overwrite: true, password: nil, progressHandler: { (_, _, _, _) in
//		}) { (path, success, error: Error?) in
//			do{
//				try FileManager.default.removeItem(at: url) /// drop zip file
//			} catch { }
//			guard error == nil else {
//				print("Error: Failed to unzip localizable archive")
//				callback(false)
//				return
//			}
//			FirebaseLocalization.bundle = FirebaseLocalization.getBundle()
//			print("Localizations downloaded")
//			callback(true)
//		}
	}

}
