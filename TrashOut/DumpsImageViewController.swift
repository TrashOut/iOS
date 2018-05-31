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

class DumpsImageViewController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    var trash: Trash?

    var currentStatus: String?
    var intervalOfUpdated: String?

    fileprivate var newTitle: String? {
        didSet {
            title = newTitle
        }
    }
    fileprivate var photosCount: Int? {
        didSet {
            guard let count = photosCount else { return }
            newTitle = "1 of \(count)".localized
        }
    }

    @IBOutlet var cvAllScreenPhoto: UICollectionView!

    @IBOutlet var lblUser: UILabel!
    @IBOutlet var lblInfo: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        
        if trash?.updates.first?.anonymous == false {
            lblUser.text = trash?.user?.displayName ?? "trash.anonymous".localized
        } else {
            lblUser.text = "trash.anonymous".localized
        }
        
		guard let status = currentStatus, let interval = intervalOfUpdated else { return }
		lblInfo.text = status.lowercased() + " " + interval.lowercased()
    }

    // MARK: - Collection view

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = trash?.images else { return 0 }
        photosCount = photos.count
        return photosCount!
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllScreenPhotoCell", for: indexPath) as? AllScreenPhotoCollectionViewCell else { fatalError("Could not dequeue cell with identifier: AllScreenPhotoCell") }

        guard let photos = trash?.images else { return cell }
        cell.ivPhoto.remoteImage(id: photos[indexPath.item].fullDownloadUrl!)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  cvAllScreenPhoto.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		// FIXME: calc index by scrollview content offset
        for cell in cvAllScreenPhoto.visibleCells {
            guard let path = cvAllScreenPhoto.indexPath(for: cell as UICollectionViewCell), let count = photosCount else { return }
			newTitle = "\(path[1] + 1) of \(count)".localized
        }
    }

}

class AllScreenPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var ivPhoto: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        ivPhoto.cancelRemoteImageRequest()
    }

}
