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


class NewsPhotoGalleryViewController: ViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {


	@IBOutlet var collectionView: UICollectionView!

	var photos: [Image] = []
	var currentIndex: Int = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "\(self.currentIndex + 1) / \(self.photos.count)"

		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.contentInset = .zero
		collectionView.layoutMargins = .zero
        
        //let rect = self.collectionView.layoutAttributesForItem(at: IndexPath(row: currentIndex, section: 0))?.frame
        //self.collectionView.scrollRectToVisible(rect!, animated: false)
        self.collectionView.scrollToItem(at: IndexPath.init(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //let rect = self.collectionView.layoutAttributesForItem(at: IndexPath(row: currentIndex, section: 0))?.frame
        //self.collectionView.scrollRectToVisible(rect!, animated: false)
        //self.collectionView.scrollToItem(at: IndexPath.init(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.collectionView.collectionViewLayout.invalidateLayout()
	}


	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return photos.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! ArticleFullScreenPhotoCollectionViewCell
		let image = photos[indexPath.item]
		guard let url = image.fullDownloadUrl else {
			return cell
		}
		cell.ivPhoto.remoteImage(id: url, placeholder: #imageLiteral(resourceName: "No image wide"), animate: true, animationOptions: [.transitionCrossDissolve], success: nil)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {

		for ip in indexPaths {
			let image = photos[ip.item]
			guard let url = image.fullDownloadUrl else {
				continue
			}
			UIImage.prefetchImage(id: url)
		}
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return collectionView.frame.size
	}


	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.currentIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
		self.title = "\(self.currentIndex + 1) / \(self.photos.count)"
	}

}

class ArticleFullScreenPhotoCollectionViewCell: UICollectionViewCell {


	@IBOutlet var ivPhoto: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		ivPhoto.image = #imageLiteral(resourceName: "No image wide")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		ivPhoto.cancelRemoteImageRequest()
		ivPhoto.image = #imageLiteral(resourceName: "No image wide")
	}


}
