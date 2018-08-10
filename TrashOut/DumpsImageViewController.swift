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

extension Trash {
    var allImages: [Image] {
        return self.updates.map { $0.images }.reduce([], +) + images
    }
    
    var allUser: [User?] {
        return self.updates.map { $0.user } + [user]
    }
    
    var allStatuses: [Trash.Status?] {
        return (updates.map { $0.status } + [status])
    }
    
    var allUpdateTimes: [Date?] {
        return (updates.map { $0.updateTime }) + [updateTime]
    }
}

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
        return trash?.allImages.count
    }

    @IBOutlet var cvAllScreenPhoto: UICollectionView!

    @IBOutlet var lblUser: UILabel!
    @IBOutlet var lblInfo: UILabel!
    
    // TODO: - Zle zobrazuje popisku pre lblInfo - dokoncit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        
        if let trash = self.trash {
            self.lblUser.text = trash.allUser.last??.displayName ?? "trash.anonymous".localized
            self.lblInfo.text = trash.allUpdateTimes.last == nil
                ? "trash.anonymous".localized
                : DateRounding.shared.localizedString(for: trash.allUpdateTimes.last!!).uppercaseFirst
        }
        
		guard let status = currentStatus, let interval = intervalOfUpdated else { return }
		lblInfo.text = status.lowercased() + " " + interval.lowercased()
        
        title = getTitle(forIndex: 1)
    }
    
    func getTitle(forIndex index: Int) -> String {
        return "\(index) of \(trash?.allImages.count ?? 1)"
    }

    // MARK: - Collection view

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosCount ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllScreenPhotoCell", for: indexPath) as? AllScreenPhotoCollectionViewCell else { fatalError("Could not dequeue cell with identifier: AllScreenPhotoCell") }

        guard let photos = trash?.allImages else { return cell }
        cell.ivPhoto.remoteImage(id: photos[indexPath.item].fullDownloadUrl!)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  cvAllScreenPhoto.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let trash = self.trash else { return }
        guard let indexPathOfVisibleCell = self.cvAllScreenPhoto.indexPathsForVisibleItems.first else { return }
        self.title = self.getTitle(forIndex: indexPathOfVisibleCell.item + 1)
        
        UIView.transition(with: lblUser, duration: 0.15, options: .transitionCrossDissolve, animations: {
            self.lblUser.text = trash.allUser[indexPathOfVisibleCell.item]?.displayName ?? "trash.anonymous".localized
            self.lblInfo.text = trash.allUpdateTimes[indexPathOfVisibleCell.item] == nil
                ? "trash.anonymous".localized
                : DateRounding.shared.localizedString(for: trash.allUpdateTimes.first!!).uppercaseFirst
        }, completion: nil)
    }
}

class AllScreenPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var ivPhoto: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        ivPhoto.cancelRemoteImageRequest()
    }

}
