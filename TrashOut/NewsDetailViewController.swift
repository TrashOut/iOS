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
import AlamofireImage

class NewsDetailViewController: ViewController, UICollectionViewDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


	// MARK: - UI

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var ivImage: UIImageView!
	@IBOutlet var cnsImageHeight: NSLayoutConstraint!

	@IBOutlet var vTitle: UIView!
	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var lblDate: UILabel!

	@IBOutlet var vContent: UIView!
	@IBOutlet var tvContent: UITextView!
	@IBOutlet var cnsContentHeight: NSLayoutConstraint!

	@IBOutlet var vTags: UIView!
	@IBOutlet var lblTags: UILabel!
    @IBOutlet var lblAuthor: UILabel!
    @IBOutlet var lblOrigin: UILabel!

	@IBOutlet var vPhotos: UIView!
	@IBOutlet var lblPhotos: UILabel!
	@IBOutlet var cvPhotos: UICollectionView!

	@IBOutlet var vVideos: UIView!
	@IBOutlet var lblVideos: UILabel!
	@IBOutlet var cvVideos: UICollectionView!


	// MARK: - Locals

	var articleId: Int?

	var article: Article?


	// MARK: - View controller lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "tab.news".localized

		lblPhotos.text = "news.detail.attachedPhoto".localized
		lblVideos.text = "news.detail.attachedVideo".localized


		// remove ios default insets of content
		tvContent.contentInset = UIEdgeInsets.zero
		tvContent.layoutMargins = UIEdgeInsets.zero
		tvContent.textContainer.lineFragmentPadding = 0
		tvContent.textContainerInset = UIEdgeInsets.zero
        tvContent.delegate = self

		cvVideos.dataSource = self
		cvVideos.delegate = self
		cvPhotos.dataSource = self
		cvPhotos.delegate = self

//		self.addShareButton()
        
		// fill data
		if let article = article {
 			self.fillData(article)
		}
        
		if let articleId = articleId {
			self.loadData(articleId: articleId)
		}
	}

	func addShareButton() {
		let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareArticle))
		navigationItem.rightBarButtonItem = share
	}

	@objc func shareArticle() {
		guard let url = article?.url else { return }
		guard let title = article?.title else { return }
		let message = "\(title)\n\(url)"
		let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
		vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(vc, animated: true, completion: nil)
	}

	func loadData(articleId: Int) {

		LoadingView.show(on: self.view)
		Networking.instance.article(id: articleId) { [weak self] (article, error) in
			if let error = error {
				print(error.localizedDescription)
				self?.show(error: error)
				LoadingView.hide()
                self?.fillData(nil)
				return
			}
            
			self?.article = article
			if let a = article {
				self?.fillData(a)
			}
            
			LoadingView.hide()
		}
	}

	func fillData(_ article: Article?) {
        guard let article = article else {
            self.scrollView.isHidden = true
            return
        }
        
		ivImage.image = UIImage(named: "No image wide")
		lblTitle.text = article.title
		if let date = article.published {
			let df = DateFormatter()
			df.timeStyle = .none
			df.dateStyle = .full
			lblDate.text = df.string(from: date)
		}
		tvContent.attributedText = article.attributedContent

		cvPhotos.reloadData()
		if article.photos.count == 0 {
			vPhotos.removeFromSuperview()
		} else {
            let photos = article.photos.filter { (photo) -> Bool in
                photo.isMain == true
            }
            if photos.count > 0 {
                if let url = photos.first?.fullDownloadUrl {
                    ivImage.remoteImage(id: url, placeholder: #imageLiteral(resourceName: "No image square"), animate: true, animationOptions: [.transitionCrossDissolve], success: nil)
                }
            } else {
                if let url = article.photos.first?.fullDownloadUrl {
                    ivImage.remoteImage(id: url, placeholder: #imageLiteral(resourceName: "No image square"), animate: true, animationOptions: [.transitionCrossDissolve], success: nil)
                }
            }
		}
		cvVideos.reloadData()
		if article.videos.count == 0 {
			vVideos.removeFromSuperview()
		}
		if article.tags.count > 0 {
            lblTags.attributedText = self.createInfoLabelLine(label: ("news.tags".localized + ": "), value:(String.init(article.tags.joined(separator: ", "))))
		} else {
			lblTags.text = ""
		}
        
        if let author = article.author {
            lblAuthor.attributedText = self.createInfoLabelLine(label: ("news.author".localized + ": "), value:((author.firstName ?? "") + " " + (author.lastName ?? "")))
        } else {
            lblAuthor.text = ""
        }
        
        if let continent = article.continent, let country = article.country {
            lblOrigin.attributedText = self.createInfoLabelLine(label: ("geo.name".localized + ": "), value:(continent + ", " + country))
        } else {
            lblOrigin.text = ""
        }

		self.resizeOnContent()
	}

    func createInfoLabelLine(label:String, value:String) -> NSAttributedString? {
        let attrs1 = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.theme.leadBlack]
        let attrs2 = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.theme.dimGray]
        
        let attributedString1 = NSMutableAttributedString(string: label, attributes:convertToOptionalNSAttributedStringKeyDictionary(attrs1))
        let attributedString2 = NSMutableAttributedString(string: value, attributes:convertToOptionalNSAttributedStringKeyDictionary(attrs2))
        
        attributedString1.append(attributedString2)
        return attributedString1.copy() as? NSAttributedString
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)


		// do some content base resizing magic
		// just guess some height
		let width = UIScreen.main.bounds.width - 24 // padding is 12 from each side, ignoring other margins
		let size = self.tvContent.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
		if self.cnsContentHeight.constant != size.height {
			self.cnsContentHeight.constant = size.height
			self.view.setNeedsLayout()
			self.view.layoutIfNeeded()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if article != nil {
			self.resizeOnContent()
		}
	}

	func resizeOnContent() {
		// do some content base resizing magic
		// and make it smooth to resize
		//UIView.transition(with: self.scrollView, duration: 0.35, options: [.beginFromCurrentState], animations: {
			let width = self.tvContent.frame.size.width
			let size = self.tvContent.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
			if self.cnsContentHeight.constant != size.height {
				self.cnsContentHeight.constant = size.height
				self.view.setNeedsLayout()
				self.view.layoutIfNeeded()
			}
		//	}, completion: nil)
	}


	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == cvPhotos {
			return self.article?.photos.count ?? 0
		}
		if collectionView == cvVideos {
			return self.article?.videos.count ?? 0
		}
		return 0
	}


	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == cvPhotos {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! ArticlePhotoCollectionViewCell
			guard let image = article?.photos[indexPath.item] else { return cell }
			guard let url = image.optimizedDownloadUrl else { return cell }
			cell.ivPhoto.remoteImage(id: url, placeholder: #imageLiteral(resourceName: "No image square"), animate: true, animationOptions: [.transitionCrossDissolve], success: nil)

			return cell
		}
		if collectionView == cvVideos {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! ArticleVideoCollectionViewCell
			guard let video = article?.videos[indexPath.item] else { return cell }
			guard let thumbnailUrl = URL(string: video.thumbnail ?? "") else { return cell }
			cell.ivThumb.af_setImage(withURL: thumbnailUrl)

			return cell
		}
		return UICollectionViewCell()
	}


	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize.init(width: collectionView.bounds.size.height, height: collectionView.bounds.size.height)
	}


	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == cvVideos {
			guard let video = self.article?.videos[indexPath.item] else { return }
			guard let urlString = video.url else {return}
			guard let url = URL(string: urlString) else {return}
			UIApplication.shared.openURL(url)
		}
		if collectionView == cvPhotos {
			guard let photos = article?.photos else { return }
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsPhotoGalleryViewController") as! NewsPhotoGalleryViewController
			vc.photos = photos
			vc.currentIndex = indexPath.item
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
    
    // MARK: TextView delegate

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
}

class ArticlePhotoCollectionViewCell: UICollectionViewCell {

	@IBOutlet var ivPhoto: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		ivPhoto.image = #imageLiteral(resourceName: "No image square")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		ivPhoto.cancelRemoteImageRequest()
		ivPhoto.image = #imageLiteral(resourceName: "No image square")
	}


}

class ArticleVideoCollectionViewCell: UICollectionViewCell {

	@IBOutlet var ivThumb: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		ivThumb.image = #imageLiteral(resourceName: "No image square")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		ivThumb.cancelRemoteImageRequest()
		ivThumb.image = #imageLiteral(resourceName: "No image square")
	}

    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
