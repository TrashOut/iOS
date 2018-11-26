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
import Firebase
import FirebaseStorage
import Cache
import Alamofire

extension UIImage {

	/// Download image into cache
	static func prefetchImage(id: String) {
		FirebaseImages.instance.loadImage(id) { (_, _) in }
	}

}

var kRemoteImageRequestKey: UInt8 = 0


extension UIImageView {

	var remoteImageRequestCanceled: Bool {
		get {
			return objc_getAssociatedObject(self, &kRemoteImageRequestKey) as? Bool ?? false
		}
		set {
			objc_setAssociatedObject(self, &kRemoteImageRequestKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
		}
	}

	/**
	Downloads image from firebase and sets into self

	Basic usage: `imageView.remoteImage("image_id")`
	*/
	func remoteImage(id: String,
					 placeholder: UIImage = UIImage(),
					 animate: Bool = true,
					 animationOptions: UIView.AnimationOptions = [.transitionCrossDissolve],
					 success: ((UIImage?) -> ())? = nil
		) {
		self.image = placeholder
		self.remoteImageRequestCanceled = false
        
		FirebaseImages.instance.loadImage(id) { [weak self] (image, error) in
			guard error == nil else {
				print(error!.localizedDescription)
				return
			}
			guard let image = image else { return }
			guard let ss = self else { return }
			guard ss.remoteImageRequestCanceled == false else { return }
			self?.setDownloadedImage(image, animated: animate, animationOptions: animationOptions)
			success?(image)
		}
	}

	func setDownloadedImage(_ image: UIImage, animated: Bool, animationOptions: UIView.AnimationOptions) {
		if animated {
			UIView.transition(with: self,
			                  duration: 0.35,
			                  options: animationOptions,
			                  animations: { self.image = image },
			                  completion: nil)
		} else {
			self.image = image
		}
	}

	/**
	Cancel loading image

	ex. for reusable views
	*/
	func cancelRemoteImageRequest() {
		self.remoteImageRequestCanceled = true
	}

}

class FirebaseImages {
    
	static let instance = FirebaseImages()
	let cache: Cache<UIImage>

	/**
	Init with new cache

	- Warning: Use `instance` singleton to access single cache
	*/
	init() {
		let expiryDays: Double = 28
		let size: UInt = 40000000
		let config = Config(frontKind: .memory,
                            backKind: .disk,
                            expiry: .seconds(60*60*24*expiryDays),
                            maxSize: size,
                            maxObjects: Int(size))

		cache = Cache<UIImage>(name: "ImageCache", config: config)
	}

	/**
	Load image from cache or call download
    */
    func loadImage(_ id: String, callback: @escaping (UIImage?, Error?) -> ()) {
        cache.object(id) { [weak self] (image: UIImage?) in
            DispatchQueue.main.async {
                if let image = image {
                    callback(image, nil)
                } else {
                    self?.downloadImage(id, callback: callback)
                }
            }
        }
    }

    /**
    Trigger download
    */
    func downloadImage(_ link: String, callback: @escaping (UIImage?, Error?) -> ()) {
        guard let url = URL(string: link) else {
            let image = UIImage(named: "Placeholder Square")
            callback(image, nil)
            return
        }
		UserManager.instance.tokenHeader { tokenHeader in
			Alamofire.request(url, headers: tokenHeader).responseData(queue: .main) { [weak self] (response) in
				guard response.result.isSuccess else {
					guard let error = response.result.error else { return }
					callback(nil, error)
					return
				}
				guard let data = response.result.value else { return }
				guard let image = UIImage.init(data: data) else { return }
				self?.cache.add(link, object: image)
				callback(image, nil)
			}
		}
    }

    /**
    Trigger upload
    */
    func uploadImage(_ name: String, data: Data, thumbnailData:Data,  callback: @escaping (String?, String?, String?, String?, Error?) -> ()) {
        
        var uploads: [Async.Block] = []
        var thumbnailDownloadURL: String?
        var thumbnailStorageLocation: String?
        var imageDownloadURL: String?
        var imageStorageLocation: String?
        
        uploads.append({ (completion, failure) in
            let thumbnailImageStore = Storage.storage().reference().child("images/thumbnail_\(name).jpg")
            let thumbnailMetadata = StorageMetadata()
            thumbnailMetadata.contentType = "image/jpg"
            thumbnailImageStore.putData(thumbnailData, metadata: thumbnailMetadata) { (metadata, error) in
                guard error == nil else {
                    failure(error!)
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                thumbnailImageStore.downloadURL { (url, error) in
                    guard error == nil else {
                        failure(error!)
                        return
                    }
                    
                    thumbnailDownloadURL = url?.absoluteString
                    thumbnailStorageLocation = "gs://trashoutngo-dev.appspot.com/images/thumbnail_\(name).jpg"
                    completion()
                }
            }
        })
        uploads.append({ (completion, failure) in
            let imageStore = Storage.storage().reference().child("images/\(name).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            let _ = imageStore.putData(data, metadata: metadata) { (metadata, error) in
                guard error == nil else {
                    failure(error!)
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                imageStore.downloadURL { (url, error) in
                    guard error == nil else {
                        failure(error!)
                        return
                    }
                    
                    imageDownloadURL = url?.absoluteString
                    imageStorageLocation = "gs://trashoutngo-dev.appspot.com/images/\(name).jpg"
                    completion()
                }
            }
        })
        uploads.append({ (completion, failure) in
            callback(thumbnailDownloadURL, thumbnailStorageLocation, imageDownloadURL, imageStorageLocation, nil)
        })
        Async.waterfall(uploads, failure: { (error) in
            callback(nil, nil, nil, nil, error)
        })
        
    }

	func uploadImage(_ localImage: LocalImage, callback: @escaping (String?, String?, String?, String?, Error?) -> ()) {
		guard let name = localImage.uid, let data = localImage.jpegData, let thumbnailData = localImage.thumbnailJpegData else {
			callback(nil, nil, nil, nil, NSError.unknown)
			return
		}
        self.uploadImage(name, data: data, thumbnailData: thumbnailData, callback: callback)
	}
}
