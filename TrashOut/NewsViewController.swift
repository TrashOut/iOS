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

class NewsViewController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	@IBOutlet var collectionView: UICollectionView!
	var manager = ArticlesManager()
    
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "tab.news".localized
        //let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        //collectionViewLayout?.estimatedItemSize = CGSize(width:1,height:1)
        //self.automaticallyAdjustsScrollViewInsets = true

		collectionView.dataSource = self
		collectionView.delegate = self

		self.loadData(reload: false)
        self.addPullToRefresh(into: collectionView)
	}

	func addPullToRefresh(into scrollView: UIScrollView) {
		scrollView.addPullToRefreshHandler { [weak self] in
            self?.loadData(reload: true)
        }
	}

	func loadData(reload: Bool) {
		if reload {
            self.manager.removeAllData()
            self.collectionView.reloadData()
		} else {
			LoadingView.show(on: self.view)
		}
		manager.reload (callback: { [weak self] _ in
            DispatchQueue.main.async {
                if reload {
                    self?.collectionView.pullToRefreshView?.stopAnimating()
                } else {
                    LoadingView.hide()
                }
                if self?.manager.news.count == 0 {
                    self?.showNoArticles()
                } else {
                    self?.hideNoArticles()
                }
                self?.collectionView.reloadData()
                }
            }
            , failure: { [weak self] (error) in
                DispatchQueue.main.async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { // wait to hide refresh control
                        self?.show(error: error)
                    }
                    if self?.manager.news.count == 0 {
                        self?.showFailedToFetchArticles(error: error)
                    } else {
                        self?.hideFailedToFetchArticles()
                    }
                    if reload {
                        self?.collectionView.pullToRefreshView?.stopAnimating()
                    } else {
                        LoadingView.hide()
                    }
                }
            })
    }
    
    override func show(error: Error, completion: (() -> ())? = nil) {
        if case NetworkingError.noInternetConnection = error {
            super.show(error: NetworkingError.noInternetConnection)
        } else {
            super.show(error: NetworkingError.custom("global.fetchError".localized))
        }
    }

	func loadNextPage() {
		manager.loadData(callback: { [weak self] _ in
			self?.collectionView.reloadData()
		}) { [weak self] (error) in
			self?.show(error: error)
		}
	}

	func showNoArticles() {
		NoDataView.show(over: self.collectionView, text: "news.noArticles".localized)
		self.collectionView.collectionViewLayout.invalidateLayout()
		self.collectionView.setNeedsLayout()
		self.collectionView.layoutIfNeeded()
	}
	func hideNoArticles() {
		NoDataView.hide(from: self.view)
	}

    func showFailedToFetchArticles(error: Error) {
        if case NetworkingError.noInternetConnection = error {
            NoDataView.show(over: self.collectionView, text: "global.internet.error.offline".localized)
        } else {
            NoDataView.show(over: self.collectionView, text: "global.fetchError".localized)
        }
		
		self.collectionView.collectionViewLayout.invalidateLayout()
		self.collectionView.setNeedsLayout()
		self.collectionView.layoutIfNeeded()

	}
	func hideFailedToFetchArticles() {
		NoDataView.hide(from: self.view)
	}

	func refresh() {
		self.loadData(reload: true)
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return  manager.news.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as? ArticleCollectionViewCell else {return UICollectionViewCell()}

		let article = manager.news[indexPath.item]
        
        let photos = article.photos.filter { (photo) -> Bool in
            photo.isMain == true
        }
        if photos.count > 0 {
            if let url = photos.first?.fullDownloadUrl {
                cell.ivImage.remoteImage(id: url, placeholder: #imageLiteral(resourceName: "No image wide"), animate: true, animationOptions: [.transitionCrossDissolve], success: nil)
            }
        } else {
            if let url = article.photos.first?.fullDownloadUrl {
                cell.ivImage.remoteImage(id: url, placeholder: #imageLiteral(resourceName: "No image wide"), animate: true, animationOptions: [.transitionCrossDissolve], success: nil)
            } else {
                cell.ivImage.image = #imageLiteral(resourceName: "No image wide")
            }
        }

		cell.lblTitle.text = article.title
        if let plainAttributedText = article.plainAttributedContent {
            cell.lblInfo.attributedText = plainAttributedText
        }
        /*
        let numberOfVisibleLines = cell.lblInfo.numberOfVisibleLines
        if (numberOfVisibleLines > 2) {
            cell.lblInfo.numberOfLines = 2
        }
        */
		let df = DateFormatter()
		df.timeStyle = .none
		df.dateStyle = .long

		if let date = article.published {
			cell.lblDate.text = df.string(from: date)
		}
		cell.asCard()

		if indexPath.item == manager.news.count - 1 && !manager.lastPageLoaded() {
			self.loadNextPage()
		}

		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let article = manager.news[indexPath.item]
		guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailViewController") as? NewsDetailViewController else {return}
		vc.articleId = article.id
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let article = manager.news[indexPath.item]
        return CGSize(width: collectionView.bounds.size.width - 10, height: (article.content == "" || article.content == nil) ? 220 : 270)
	}

}

class ArticleCollectionViewCell: UICollectionViewCell {

	@IBOutlet var ivImage: UIImageView!
	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var lblDate: UILabel!
    @IBOutlet var lblInfo: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        //let screenWidth = UIScreen.main.bounds.size.width
        //widthConstraint.constant = screenWidth - (2 * 12)
        lblDate.textColor = Theme.current.color.lightGray
    }

	override func prepareForReuse() {
		super.prepareForReuse()
        ivImage.image = #imageLiteral(resourceName: "No image wide")
		ivImage.cancelRemoteImageRequest()
		ivImage.image = nil
		lblDate.text = ""
        lblInfo.text = ""
	}
}
