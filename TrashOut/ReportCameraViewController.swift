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

import UIKit


/**
Wrapper for photo taking to adjust loading time for camera (display black waiting screen)

*/
class ReportCameraViewController: ViewController {

    var trash: Trash?
    var cleaned: Bool?

	var takenPhoto: LocalImage?

	var photoManager: PhotoManager = PhotoManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true

		LoadingView.show(on: self.view, style: .transparent)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
			LoadingView.hide()
			self.activateCamera()
		}

    }

    /**
    Activate camera if its available
    */
    fileprivate func activateCamera() {
        photoManager.takePhoto(vc: self, animated: false, source: .camera, success: { [weak self] (image) in
			self?.takenPhoto = image
			self?.goToReportViewController()
		}) { [weak self] (_) in
			self?.goToReportViewController()
		}

    }


    fileprivate func goToReportViewController() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ReportViewController") as? ReportViewController else { return }
		if let photo = takenPhoto {
        	vc.photos = [photo]
		}
        if trash != nil {
            vc.trash = trash
            vc.cleaned = cleaned
        }
        navigationController?.pushViewController(vc, animated: true)
    }

}
