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
import AVFoundation
import MobileCoreServices

class PhotoManager: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	var success: ((LocalImage) -> ())?
	var failure: ((Error) -> ())?

	var animated: Bool = true
	var store: LocalImage.StoreType = .temp

	func checkCameraPermissions (vc: UIViewController, callback: @escaping (Error?) -> ()) {
		let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
		switch cameraAuthorizationStatus {
		case .denied, .restricted:
			let error = NSError.init(domain: "cz.trashout.TrashOut", code: 300, userInfo: [
				NSLocalizedDescriptionKey: "Camera access not granted"
				])
			callback(error)
			break
		case .authorized:
			callback(nil)
			break
		case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
				if granted {
					callback(nil)
				} else {
					let error = NSError.init(domain: "cz.trashout.TrashOut", code: 300, userInfo: [
						NSLocalizedDescriptionKey: "Camera access not granted"
						])
					callback(error)
				}
			}
		}
	}

	func openImagePicker(vc: UIViewController, source: UIImagePickerController.SourceType, animated: Bool) {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(source) {
                picker.sourceType = source
                picker.mediaTypes = [kUTTypeImage as String]
                picker.allowsEditing = true
                picker.delegate = self
                vc.present(picker, animated: animated)
            } else {
                let ac = UIAlertController(title: "global.noCameraSupport".localized, message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "global.ok".localized, style: .cancel) { (_) in
                    vc.dismiss(animated: true)
                })
                vc.present(ac, animated: true, completion: nil)
            }
        }
	}


    func takePhoto(vc: UIViewController, animated: Bool = true, source: UIImagePickerController.SourceType, store: LocalImage.StoreType = .temp, success: @escaping (LocalImage) -> (), failure: @escaping (Error) -> ()) {
		self.success = success
		self.failure = failure
		self.animated = animated

		self.checkCameraPermissions(vc: vc) { [weak self] (error) in
			if error != nil {
				if let vc = vc as? ViewController {
                    vc.showWithSettings(message: "Allow access to camera in settings.".localized) {
                        vc.dismiss(animated: true)
                    }
				} else {
					let ac = UIAlertController(title: "Allow access to camera in settings.".localized, message: nil, preferredStyle: .alert)
					ac.addAction(UIAlertAction(title: "global.ok".localized, style: .cancel) { (_) in
                        vc.dismiss(animated: true)
					})
					vc.present(ac, animated: true, completion: nil)
				}
			} else {
				self?.openImagePicker(vc: vc, source: source , animated: animated)
			}
		}
	}


	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		let error = NSError.init(domain: "cz.trashout.TrashOut", code: 0, userInfo: [NSLocalizedDescriptionKey: "No photo taken".localized])
		picker.dismiss(animated: self.animated) {
			self.failure?(error)
		}
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let originalImage = info[.originalImage] as? UIImage,
            let cropRect = info[.cropRect] as? CGRect,
            let croppedImage = cropImage(originalImage, to: cropRect)
            else {
                picker.dismiss(animated: self.animated) {
                    let error = NSError(domain: "cz.trashout.TrashOut", code: 0, userInfo: [NSLocalizedDescriptionKey: "No photo taken".localized])
                    self.failure?(error)
                }
                return
        }
        
        let resizedImage = resizeImageToFormat(croppedImage)
		let localImage = LocalImage()
		localImage.store = .temp
		localImage.image = resizedImage
		localImage.uid = UUID().uuidString
		localImage.write()
		picker.dismiss(animated: self.animated) { 
			self.success?(localImage)
		}
	}
    
    func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        // remove black bands
        var cropRect = rect
        if cropRect.origin.x < 0 {
            cropRect.size.width += cropRect.origin.x
            cropRect.origin.x = 0
        }
        if cropRect.origin.y < 0 {
            cropRect.size.height += cropRect.origin.y
            cropRect.origin.y = 0
        }
        cropRect.origin.x = min(cropRect.origin.x, image.size.width - 1)
        cropRect.origin.y = min(cropRect.origin.y, image.size.height - 1)
        cropRect.size.width = min(cropRect.size.width, image.size.width - cropRect.origin.x)
        cropRect.size.height = min(cropRect.size.height, image.size.height - cropRect.origin.y)
        
        UIGraphicsBeginImageContextWithOptions(cropRect.size, false, 1)
        defer { UIGraphicsEndImageContext() }
        image.draw(at: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizeImageToFormat(_ image: UIImage) -> UIImage {
        var ratio = CGFloat(1.0)
        if (image.size.width > image.size.height) {
            ratio = CGFloat(800) / image.size.width
        } else {
            ratio = CGFloat(800) / image.size.height
        }
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        return image.resizeImage(targetSize: newSize)
    }
}
