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

class LocalImage {

	init () {}

	enum StoreType {
		case documents
		case temp

		var directory: URL {
			switch self {
			case .documents:
				return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
			case .temp:
				return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
			}
		}
	}

	var store: StoreType = .documents
	var uid: String?
	var localPath: String?
	var image: UIImage?

	func write() {
		guard let uid = self.uid else { return }
        guard let thumbnailJpegData = self.thumbnailJpegData else { return }
        guard let jpegData = self.jpegData else { return }
		let imagePath = store.directory.appendingPathComponent(uid)
		try? thumbnailJpegData.write(to: imagePath)
        try? jpegData.write(to: imagePath)
	}

	func read() {
		// TODO: read from file, search by uid
	}

	var jpegData: Data? {
		guard let image = image else { return nil }
		return UIImageJPEGRepresentation(image, 80)
	}
    
    var thumbnailJpegData: Data? {
        guard let image = image else { return nil }
        let cropedImage = image.resizeImage(targetSize: CGSize(width: 150, height: 150))
        return UIImageJPEGRepresentation(cropedImage, 80)
    }
}

class Image: JsonDecodable {

    // MARK: - Properties

    var fullDownloadUrl: String?
    var thumbDownloadUrl: String?
    var optimizedDownloadUrl: String? {
        get {
            return (thumbDownloadUrl != nil) ? thumbDownloadUrl : fullDownloadUrl
        }
    }
    var isMain: Bool? = false
    
    // MARK: - Lifecycle

    init() {}

    func parse(json: [String: AnyObject]) {
        fullDownloadUrl = json["fullDownloadUrl"] as? String
        thumbDownloadUrl = json["thumbDownloadUrl"] as? String
        isMain = json["isMain"] as? Bool
    }

    static func create(from json: [String: AnyObject], usingId id: Int?) -> AnyObject {
        // Create new obj
        let image = Image()
        image.parse(json: json)
        return image
    }

    func dictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]

        dict["fullDownloadUrl"] = fullDownloadUrl as AnyObject?
        dict["thumbDownloadUrl"] = thumbDownloadUrl as AnyObject?
        dict["isMain"] = isMain as AnyObject?
        return dict
    }

}

class Video: JsonDecodable {

	var url: String?
	var thumbnail: String?

	init() {}

	static func create(from json: [String: AnyObject], usingId id: Int?) -> AnyObject {
		// Create new obj
		let video = Video()
		video.url = json["url"] as? String
		video.thumbnail = json["thumbnail"] as? String
        if video.thumbnail == nil && video.url != nil {
            if let videoId = Video.getYoutubeId(youtubeUrl:video.url!) {
                video.thumbnail = "https://img.youtube.com/vi/\(videoId)/default.jpg"
            }
        }
		return video
	}

    static func getYoutubeId(youtubeUrl: String) -> String? {
        return URLComponents(string: youtubeUrl)?.queryItems?.first(where: { $0.name == "v" })?.value
    }
    
	func dictionary() -> [String: AnyObject] {
		var dict: [String: AnyObject] = [:]

		dict["url"] = url as AnyObject?
		dict["thumbnail"] = thumbnail as AnyObject?

		return dict
	}

}
