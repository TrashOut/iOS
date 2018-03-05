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
import Cache


class Article: JsonDecodable, Cachable {

	typealias CacheType = Article

    // MARK: - Properties

	var id: Int?
	var title: String?
	var published: Date?
	var content: String?
    var attributedContent: NSAttributedString?
    var plainAttributedContent: NSAttributedString?
	var url: String?
	var tags: [String] = []
	var photos: [Image] = []
	var videos: [Video] = [] // TODO: video model with thumbnails
    var author: User?
    var continent: String?
    var country: String?

    // MARK: - Lifecycle

	init() {

	}

	func parse(json: [String: AnyObject]) {

		self.id = json["id"] as? Int
		self.title = json["title"] as? String
		self.content = json["body"] as? String
        let htmlContent = "<style type=\"text/css\">body{font-family: '-apple-system','HelveticaNeue'; font-size:12;}</style>" + (self.content ?? "")
        if let htmlData = htmlContent.data(using: String.Encoding.unicode) {
            do {
                let attributedText = try NSAttributedString(data: htmlData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                mutableAttributedText.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 13.0)], range: NSMakeRange(0, mutableAttributedText.length))
                attributedContent = attributedText
                plainAttributedContent = mutableAttributedText.copy() as? NSAttributedString
            } catch let e as NSError {
                print("Couldn't translate \(htmlContent): \(e.localizedDescription) ")
            }
        }
		if let created = json["created"] as? String {
			self.published = DateFormatter.date(from: created)
		}
		self.url = json["url"] as? String
		if let tags = json["tags"] as? String {
			self.tags = tags.components(separatedBy: ", ")
		}

		if let images = json["images"] {
			self.photos <== images
		} else if let images = json["prContentImage"] as? [[String: AnyObject]] {
			for img in images {
				let imgJson = img["image"] as? [String: AnyObject] ?? img
				let photo = Image.create(from: imgJson, usingId: nil) as! Image
				self.photos.append(photo)
			}
		}
		if let videos = json["prContentVideo"] as? [[String: AnyObject]] {
			for v in videos {
				let video = Video.create(from: v, usingId: nil) as! Video
//				let video = Video.create(from: [
//					"url": "https://www.youtube.com/watch?v=wa0nLXVFZR0" as AnyObject!,
//					"thumbnail": "https://img.youtube.com/vi/wa0nLXVFZR0/default.jpg" as AnyObject!
//					], usingId: nil) as! Video
				self.videos.append(video)
			}
		}
        if let area = json["area"] as? [String: AnyObject] {
            self.continent <== area["continent"]
            self.country <== area["country"]
        }
        self.author <== json["user"]
	}

	static func create(from json: [String: AnyObject], usingId id: Int?) -> AnyObject {
		let article = Article()
		article.parse(json: json)
		return article
	}

	func dictionary() -> [String: AnyObject] {
		var dict: [String: AnyObject] = [:]

		dict["id"] = self.id as AnyObject?
		dict["title"] = self.title as AnyObject?
		dict["body"] = self.content as AnyObject?
		if let published = self.published {
			dict["created"] = DateFormatter.zulu.string(from: published) as AnyObject?
		}
		dict["url"] = self.url as AnyObject?

		return dict
	}

}
