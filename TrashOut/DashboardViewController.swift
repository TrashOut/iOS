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
import CoreLocation

class DashboardViewController: ViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet var twoNearestDumpsView: UIView!
    @IBOutlet var dumpsImageView: UIView!
    @IBOutlet var dumpsImageView2: UIView!
    @IBOutlet var oneNearestDumpView: UIView! {
        didSet {
            oneNearestDumpView.isHidden = true
        }
    }
    @IBOutlet var dumpImageViewFull: UIView!

	@IBOutlet var vRecycling: UIView!
	@IBOutlet var vRecyclingCard: UIView!
	@IBOutlet var trashCanView: UIView!
    @IBOutlet var junkyardView: UIView!

	@IBOutlet var vArticleContainer: UIView!
	
	@IBOutlet var eventsView: UIView!
	@IBOutlet var vActivity: UIView!
	@IBOutlet var vNews: UIView!
	@IBOutlet var vStatistics: UIView!
	@IBOutlet var vEvents: UIView!

	@IBOutlet var scrollView: UIScrollView!

    @IBOutlet var lblNearestDumps: UILabel!
    @IBOutlet var lblNearesDumpsDetail: UILabel!
    @IBOutlet var lblDumpsImage: UILabel!
    @IBOutlet var lblDumpsImage2: UILabel!
    @IBOutlet var lblDumpFullImage: UILabel!
    @IBOutlet var lblDidYouKnow: UILabel!
    @IBOutlet var lblNews: UILabel!
    @IBOutlet var lblNewsDate: UILabel!
    @IBOutlet var lblNewsInfo: UILabel!
    @IBOutlet var lblNearestRecyclingPoints: UILabel!
    @IBOutlet var lblTrashCan: UILabel!
    @IBOutlet var lblTrashDistance: UILabel!
    @IBOutlet var lblJunkyard: UILabel!
    @IBOutlet var lblJunkyardDistance: UILabel!
    @IBOutlet var lblRecentActivity: UILabel!
    @IBOutlet var lblNoRecentActivity: UILabel!
    @IBOutlet var lblEvents: UILabel!
    @IBOutlet var lblEventsInfo: UILabel!
    @IBOutlet var lblStatistic: UILabel!
    @IBOutlet var lblStatisticInfo: UILabel!
    @IBOutlet var lblReported: UILabel!
    @IBOutlet var lblCleaned: UILabel!
    @IBOutlet var lblReportedNumber: UILabel!
    @IBOutlet var lblCleanedNumber: UILabel!

    @IBOutlet var btnMore: UIButton!

    @IBOutlet var ivDumpsImage: UIImageView!
    @IBOutlet var ivDumpsImage2: UIImageView!
    @IBOutlet var ivDumpsImageFull: UIImageView!
    @IBOutlet var ivNews: UIImageView!
    @IBOutlet var ivTrashCan: UIImageView!
    @IBOutlet var ivJunkyard: UIImageView!

    @IBOutlet var vDescSeparator: [UIView]!

    @IBOutlet var cnNearestDumpsImageCardHeight: NSLayoutConstraint!
    @IBOutlet var cnNearestRecyclingPointsSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var cnStatisticSeparatorHeight: NSLayoutConstraint!
    
    @IBOutlet var trashBinViewHeight: NSLayoutConstraint!
    @IBOutlet var junkyardViewHeight: NSLayoutConstraint!
    @IBOutlet var junkyardsStackViewHeight: NSLayoutConstraint!


    @IBOutlet var btnAddDumpWrapper: UIView!
    @IBOutlet var reportButtonWrapper: UIView!
    @IBOutlet var btnReportDump: UIButton!
	@IBOutlet var btnAddDump: UIButton!

	@IBOutlet var tblEvents: UITableView!

    var trashes: [Trash] = [] {
        didSet {
			guard trashes.count > 0 else {
				self.twoNearestDumpsView.isHidden = true
				if let sv = self.twoNearestDumpsView.superview {
					NoDataView.show(over: sv)
				}
				return
			}
			self.twoNearestDumpsView.isHidden = false

			if trashes.count == 1 {
				twoNearestDumpsView.isHidden = true
				updateNearestDumpsView(order: 0, label: lblDumpFullImage, image: ivDumpsImageFull)
				oneNearestDumpView.isHidden = false

			} else {
				updateNearestDumpsView(order: 0, label: lblDumpsImage, image: ivDumpsImage)
				updateNearestDumpsView(order: 1, label: lblDumpsImage2, image: ivDumpsImage2)
				if lblDumpsImage2.text == "> 10km away".localized { // FIXME: base on distance, not string
					twoNearestDumpsView.isHidden = true
					updateNearestDumpsView(order: 0, label: lblDumpFullImage, image: ivDumpsImageFull)
					oneNearestDumpView.isHidden = false

				} else {
					oneNearestDumpView.isHidden = true
					twoNearestDumpsView.isHidden = false

				}
			}

        }
    }

    var dataDidLoadHandler: (() -> Void)?
    
    var junkyards: [Junkyard] = [] {
        didSet {
            updateNearestRecyclingPointsView()
            /*
            if lblTrashDistance.text?.range(of: "km") == nil {
                trashCanView.isHidden = false // true
            } else {
                trashCanView.isHidden = false
            }*/
        }
    }

	var events: [Event] = [] {
		didSet {
			self.updateEvents()
		}
	}

	var activity: [Activity] = [] {
		didSet {
			activityVC?.activities = activity
			if activity.count == 0 {
				activityVC?.view.isHidden = true
				lblNoRecentActivity.isHidden = false
			} else {
				activityVC?.view.isHidden = false
				lblNoRecentActivity.isHidden = true
			}

		}
	}
	weak var activityVC: DashboardActivityViewController?

    private var dustbinData: Junkyard?
    private var junkyardData: Junkyard?

    deinit {
        unregisterFromNotifcations()
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
		title = "tab.home".localized

        let info = UIBarButtonItem(image: #imageLiteral(resourceName: "Info"), style: .plain, target: self, action: #selector(goToInfo))
        navigationItem.rightBarButtonItem = info

        cnStatisticSeparatorHeight.preciseConstant = 1
		cnNearestRecyclingPointsSeparatorHeight.preciseConstant = 1

        lblNearestDumps.text = "home.nearestDumps".localized
        lblNearestDumps.textColor = Theme.current.color.green
        lblNearesDumpsDetail.text = "home.goAndFindDumps".localized
        lblNearesDumpsDetail.textColor = Theme.current.color.lightGray
        lblDidYouKnow.text = "home.didYouKnow".localized
        lblDidYouKnow.textColor = Theme.current.color.green
        lblNewsDate.textColor = Theme.current.color.lightGray
        lblNearestRecyclingPoints.text = "home.nearestRecyclingPoints".localized
        lblNearestRecyclingPoints.textColor = Theme.current.color.green
        lblTrashCan.text = "collectionPoint.size.recyclingBin".localized
        lblTrashDistance.textColor = Theme.current.color.lightGray
        lblJunkyard.text = "collectionPoint.size.recyclingCenter".localized
        lblJunkyardDistance.textColor = Theme.current.color.lightGray
        lblRecentActivity.text = "home.recentActivity.header".localized
        lblRecentActivity.textColor = Theme.current.color.green
        lblNoRecentActivity.text = "home.recentActivity.noActivity".localized
        lblNoRecentActivity.textColor = Theme.current.color.lightGray
        lblEvents.text = "events.header".localized
        lblEvents.textColor = Theme.current.color.green
        lblEventsInfo.text = "home.events.text".localized
        lblEventsInfo.textColor = Theme.current.color.lightGray
        lblStatistic.text = "statistics.header".localized
        lblStatistic.textColor = Theme.current.color.green
        lblStatisticInfo.text = "home.numberDumpsWorldwide".localized
        lblStatisticInfo.textColor = Theme.current.color.lightGray
        lblReported.text = "profile.reported".localized
        lblReported.textColor = Theme.current.color.lightGray
        lblCleaned.text = "profile.cleaned".localized
        lblCleaned.textColor = Theme.current.color.lightGray
        lblReportedNumber.textColor = Theme.current.color.red
        lblCleaned.textColor = Theme.current.color.lightGray
        btnReportDump.setTitle("trash.create.homeReportButton".localized.uppercased(with: .current), for: .normal)
        btnReportDump.layer.cornerRadius = btnReportDump.frame.size.height / 2
        btnReportDump.layer.masksToBounds = true
        btnAddDumpWrapper.isHidden = true

        btnMore.setTitle("home.more".localized.uppercased(with: .current), for: .normal)
        btnMore.theme()

        ivTrashCan.backgroundColor = Theme.current.color.green

        for separator in vDescSeparator {
            separator.backgroundColor = UIColor.theme.separatorLine
        }

        // Making nearest recycling points touchable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDetailNearestDump(_:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(showDetailSecondNearestDump(_:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(showDetailFullNearestDump(_:)))
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(showDetailTrashCan(_:)))
        let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(showDetailJunkyard(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture2.numberOfTapsRequired = 1
        tapGesture3.numberOfTapsRequired = 1
        tapGesture4.numberOfTapsRequired = 1
        tapGesture5.numberOfTapsRequired = 1
        ivDumpsImage.isUserInteractionEnabled = true
        ivDumpsImage2.isUserInteractionEnabled = true
        ivDumpsImageFull.isUserInteractionEnabled = true
        ivDumpsImage.addGestureRecognizer(tapGesture)
        ivDumpsImage2.addGestureRecognizer(tapGesture2)
        ivDumpsImageFull.addGestureRecognizer(tapGesture3)
        trashCanView.addGestureRecognizer(tapGesture4)
        junkyardView.addGestureRecognizer(tapGesture5)
        
        self.registerForNotifcations()
        self.addPullToRefresh(into: scrollView)
        self.loadData { [weak self] in
            self?.dataDidLoadHandler?()
        }
	}
    
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		dumpsImageView.layer.cornerRadius = dumpsImageView.frame.size.height/2
		dumpsImageView.layer.borderColor = UIColor.darkGray.cgColor
		dumpsImageView.layer.borderWidth = 1 / UIScreen.main.scale
		dumpsImageView.layer.masksToBounds = true
		dumpsImageView2.layer.cornerRadius = dumpsImageView2.frame.size.height/2
		dumpsImageView2.layer.borderColor = UIColor.darkGray.cgColor
		dumpsImageView2.layer.borderWidth = 1 / UIScreen.main.scale
		dumpsImageView2.layer.masksToBounds = true
		dumpImageViewFull.layer.cornerRadius = dumpImageViewFull.frame.size.height/2
		dumpImageViewFull.layer.borderColor = UIColor.darkGray.cgColor
		dumpImageViewFull.layer.borderWidth = 1 / UIScreen.main.scale
		dumpImageViewFull.layer.masksToBounds = true
        btnAddDumpWrapper.circleButtonShadow = true
        btnReportDump.layer.cornerRadius = btnReportDump.frame.size.height / 2
		btnAddDump.layer.cornerRadius = 0.5 * btnAddDump.bounds.height
		btnAddDump.layer.masksToBounds = true
	}

	func addPullToRefresh(into scrollView: UIScrollView) {
        scrollView.addPullToRefreshHandler {
            self.articlesManager.removeAllData()
            //self.trashes.removeAll()
            self.activity.removeAll()
            self.events.removeAll()
            self.junkyards.removeAll()
            self.loadData(reload: true)
        }
	}
    
    /**
    Go to info about app
    */
    func goToInfo() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController else { fatalError("Could not dequeue storyboard with identifier: DumpsDetailViewController") }
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
    Show detail of the nearest dump
    */
    func showDetailNearestDump(_ sender: UITapGestureRecognizer) {
		guard trashes.count > 0 else {return}
        let trashId = trashes[0]

        let storyboard = UIStoryboard.init(name: "Dumps", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DumpsDetailViewController") as? DumpsDetailViewController else { fatalError("Could not dequeue storyboard with identifier: DumpsDetailViewController") }
        vc.id = trashId.id
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
    Show detail of the second nearest dump
    */
    func showDetailSecondNearestDump(_ sender: UITapGestureRecognizer) {
		guard trashes.count > 1 else {return}
        let trashId = trashes[1]

        let storyboard = UIStoryboard.init(name: "Dumps", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DumpsDetailViewController") as? DumpsDetailViewController else { fatalError("Could not dequeue storyboard with identifier: DumpsDetailViewController") }
        vc.id = trashId.id
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
    Show detail of the only presenting dump
    */
    func showDetailFullNearestDump(_ sender: UITapGestureRecognizer) {
        let trashId = trashes[0]

        let storyboard = UIStoryboard.init(name: "Dumps", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DumpsDetailViewController") as? DumpsDetailViewController else { fatalError("Could not dequeue storyboard with identifier: DumpsDetailViewController") }
        vc.id = trashId.id
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
    Show detail of the second nearest dump
    */
    func showDetailTrashCan(_ sender: UITapGestureRecognizer) {
        guard let dustbinData = dustbinData else { return }
        
        let storyboard = UIStoryboard.init(name: "Junkyards", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "JunkyardsDetailViewController") as? JunkyardsDetViewController else { fatalError("Could not dequeue storyboard with identifier: JunkyardsDetailViewController") }
        vc.junkyard = dustbinData
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
    Show detail of the second nearest dump
    */
    func showDetailJunkyard(_ sender: UITapGestureRecognizer) {
        guard let junkyardData = junkyardData else { return }
        
        let storyboard = UIStoryboard.init(name: "Junkyards", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "JunkyardsDetailViewController") as? JunkyardsDetViewController else { fatalError("Could not dequeue storyboard with identifier: JunkyardsDetailViewController") }
        vc.junkyard = junkyardData
        navigationController?.pushViewController(vc, animated: true)
    }


	var eventManager: EventManager = EventManager()
	

	/**
	Add new dump
	*/
	@IBAction func addNewDump(_ sender: Any) {
        guard Reachability.isConnectedToNetwork() else {
            self.show(error: NetworkingError.noInternetConnection)
            
            return
        }
        
		let storyboard = UIStoryboard.init(name: "Report", bundle: Bundle.main)
		let vc = storyboard.instantiateViewController(withIdentifier: "Report")
		present(vc, animated: true, completion: nil)
	}


	/**
	Navigate to nearest dumps list
	*/
	@IBAction func nearestDumps(_ sender: Any) {
		guard let tabs = self.navigationController?.parent as? TabbarViewController else { return }
		tabs.openDumps()
	}

	/** 
	Navigate to articles
	*/
	@IBAction func articles(_ sender: Any) {
		guard let tabs = self.navigationController?.parent as? TabbarViewController else { return }
		tabs.openArticles()
	}

	/**
	Navigate to junkyards
	*/
	@IBAction func junkyards(_ sender: Any) {
		guard let tabs = self.navigationController?.parent as? TabbarViewController else { return }
		tabs.openJunkyards()
	}

	@IBAction func openUserActivity(_ sender: Any) {
		guard UserManager.instance.isLoggedIn == true else { return }
		guard let tabs = self.navigationController?.parent as? TabbarViewController else { return }
		tabs.openProfile { (profileVC) in
			guard let profileVC = profileVC as? ProfileViewController else { return }
			profileVC.openActivityList()
		}
	}

    // MARK: - Networking

	/**
	Refresh dashboard

	1. refresh current location
	2. load trashes
	3. load junkyards
	4. load events
	*/
    func loadData(reload: Bool = false, completion: (() -> Void)? = nil) {
		if reload {
			//self.refreshControl.beginRefreshing()
		} else {
			LoadingView.show(on: self.view, style: .white)
		}
		Async.waterfall([
			{ (completion, failure) in
				LocationManager.manager.refreshCurrentLocation({ (_) in
					completion()
				})
			},
			loadTrashes,
			loadJunkyards,
			loadEvents,
			loadActivity,
			loadNews,
			loadStatistics,
			{ [weak self] (_, failure) in
                if reload {
                    DispatchQueue.main.async {
                        self?.scrollView.pullToRefreshView?.stopAnimating()
                    }
                } else {
                    LoadingView.hide()
                }
                
                DispatchQueue.main.async {
                    completion?()
                }
            }
			]) { [weak self] (error) in
                self?.show(error: error)
                if reload {
                    DispatchQueue.main.async {
                        self?.scrollView.pullToRefreshView?.stopAnimating()
                    }
                } else {
                    LoadingView.hide()
                }
                
        }
    }

	/**
	Load two nearest trashes
	*/
	func loadTrashes(completion: @escaping ()->(), failure: @escaping (Error)->()) {
		let locationPoint = LocationManager.manager.currentLocation.coordinate
		Networking.instance.trashes(position: locationPoint, status: nil, size: nil, type: nil, timeTo: nil, timeFrom: nil, limit: 2, page: 1) { [weak self] (trashes, error) in
			guard error == nil else {
				print(error?.localizedDescription as Any)
				// let e = NSError(domain: "cz.trashout.Trashout", code: 500, userInfo: [
				//	NSLocalizedDescriptionKey: "Can not load nearest dumps, please try it again later".localized
				//	])
				// failure(e)

				// ignore failure
				completion()
				return
			}
            
			guard let newTrashes = trashes else { completion(); return }
			self?.trashes = newTrashes
			completion()
		}
	}

	/**
	Load nearest junkyards
	
	- TODO: limit 2 junkyards
	*/
	func loadJunkyards(completion: @escaping ()->(), failure: @escaping (Error)->()) {
		let locationPoint = LocationManager.manager.currentLocation.coordinate
		Networking.instance.junkyards(position: locationPoint, size: nil, type: nil, page: 1) { [weak self] (junkyards, error) in
			guard error == nil else {
				print(error?.localizedDescription as Any)
//				let e = NSError(domain: "cz.trashout.Trashout", code: 500, userInfo: [
//					NSLocalizedDescriptionKey: "Can not load nearest junkyards, please try it again later".localized
//					])
//				failure(e)
				NoDataView.show(over: self?.vRecyclingCard, text: "global.loadingError".localized)
				completion()
				return
			}
			NoDataView.hide(from: self?.vRecyclingCard)
            
			guard let newJunkyards = junkyards else {
				completion()
				return
			}
            let breakpoint = { print("") }
            breakpoint()
            
			self?.junkyards = newJunkyards
			completion()
		}
	}

	
	/**
	Load activity
	*/
	func loadActivity(completion: @escaping ()->(), failure: @escaping (Error)->()) {
		guard let user = UserManager.instance.user else {
			completion() // ignore, but it shouldn't happen
			return
		}
		Networking.instance.recentActivity(user: user.id, page: 1, limit: 3) { [weak self] (activities, error) in
			if let error = error {
				print(error.localizedDescription)
//				let e = NSError(domain: "cz.trashout.Trashout", code: 500, userInfo: [
//					NSLocalizedDescriptionKey: "Can not load user activity, please try it again later".localized
//					])
//				failure(e)
				NoDataView.show(over: self?.vActivity, text: "global.loadingError".localized)
				completion()
                
				return
			}
			NoDataView.hide(from: self?.vActivity)
			if let activities = activities {
				self?.activity = Array(activities.prefix(3))
			}
            
			//self?.activity = activities ?? []
            
			completion()
		}
	}

	let articlesManager = ArticlesManager()
	/**
	Load article
	*/
	func loadNews(completion: @escaping () -> (), failure: @escaping (Error) -> ()) {
		articlesManager.limit = 1
		articlesManager.loadData(callback: {  [weak self] _ in
			NoDataView.hide(from: self?.vNews)
			self?.updateArticle()
			completion()
			}) { [weak self] (error) in
			NoDataView.show(over: self?.vNews, text: "global.loadingError".localized)
			completion()
//			print(error.localizedDescription)
//			let e = NSError(domain: "cz.trashout.Trashout", code: 500, userInfo: [
//				NSLocalizedDescriptionKey: "Cannot load news, please try it again later".localized
//				])
//			failure(e)
			return
		}

	}

	/**
	Load statistics
	*/
	var statistics = StatisticsManager()
	func loadStatistics(completion: @escaping ()->(), failure: @escaping (Error)->()) {
		statistics.loadWorld(completion: { [weak self] _ in
			NoDataView.hide(from: self?.vStatistics)
			self?.updateStatistics()
			completion()
			}) { [weak self] (error) in
				NoDataView.show(over: self?.vStatistics, text: "global.loadingError".localized)
				completion()
//			let e = NSError(domain: "cz.trashout.Trashout", code: 500, userInfo: [
//				NSLocalizedDescriptionKey: "Can not load statistics, please try it again later".localized
//				])
//			failure(e)
		}
	}


	// MARK: - Update UI

	func updateStatistics() {
		let cleaned = statistics.worldwide[.cleaned] ?? 0
		let reported = statistics.worldwide[.reported] ?? 0

		lblCleanedNumber.text = NumberFormatter.localizedString(from: NSNumber.init(value: cleaned), number: .decimal)
		lblReportedNumber.text = NumberFormatter.localizedString(from: NSNumber.init(value: reported), number: .decimal)

	}

	func updateArticle() {
		guard let article = articlesManager.news.first else {
			self.vArticleContainer.isHidden = true
			return
		}
		self.vArticleContainer.isHidden = false
		let df = DateFormatter()
		df.timeStyle = .none
		df.dateStyle = .long
		if let published = article.published {
			lblNewsDate.text = df.string(from: published)
		} else {
			lblNewsDate.text = "Unknown".localized
		}
		lblNews.text = article.title
        lblNewsInfo.attributedText = article.attributedContent
        let numberOfVisibleLines = lblNewsInfo.numberOfVisibleLines
        if (numberOfVisibleLines > 2) {
            lblNewsInfo.numberOfLines = 2
        }
        
		if let imageUrl = article.photos.first?.fullDownloadUrl {
			ivNews.remoteImage(id: imageUrl, placeholder: #imageLiteral(resourceName: "No image wide"), animate: true, animationOptions: [.transitionCrossDissolve], success: nil)
		} else {
			ivNews.image = #imageLiteral(resourceName: "No image wide")
		}
	}

    /**
    Update Nearest dumps part of UI
    */
    fileprivate func updateNearestDumpsView(order: Int, label: UILabel, image: UIImageView) {
		guard trashes.count > 0 else { return }
        let trash = trashes[order]

        // Dumps photo
        if let photo = trash.images.first?.optimizedDownloadUrl {
            image.remoteImage(id: photo, placeholder: #imageLiteral(resourceName: "No image square"), animate: true)
            //cnNearestDumpsImageCardHeight.constant = ivDumpsImage.bounds.width + 16
        }

        // Dumps distance from user
        setDistance(gps: trash.gps!, label: label)
        //label.adjustsFontSizeToFitWidth = true

    }

    /**
    Update Nearest junkyards part of UI
    */
    fileprivate func updateNearestRecyclingPointsView() {
//        guard junkyards.count > 0 else {
//            vRecycling.isHidden = true
//            return
//        }
//
//        vRecycling.isHidden = false

        let breakpoint = { print("") }
        breakpoint()
        
		let dustbin = junkyards.first { (junkyard) -> Bool in
			return junkyard.size == "dustbin"
		}
		let scarpyard = junkyards.first { (junkyard) -> Bool in
			return junkyard.size == "scrapyard"
		}

		if dustbin == nil {
			trashCanView.isHidden = true
            trashBinViewHeight.constant = 0
			cnNearestRecyclingPointsSeparatorHeight.constant = 0
            if scarpyard == nil {
                junkyardsStackViewHeight.constant = 0
            } else {
                junkyardsStackViewHeight.constant = 101
            }
		} else {
            trashCanView.isHidden = false
            trashBinViewHeight.constant = 84
			setDistance(gps: dustbin!.gps!, label: lblTrashDistance)
			dustbinData = dustbin
            if scarpyard == nil {
                junkyardsStackViewHeight.constant = 101
            } else {
                junkyardsStackViewHeight.constant = 202
            }
		}
		if scarpyard == nil {
			junkyardView.isHidden = true
            junkyardViewHeight.constant = 0
            junkyardsStackViewHeight.constant = 101
			cnNearestRecyclingPointsSeparatorHeight.constant = 0
            if dustbin == nil {
                junkyardsStackViewHeight.constant = 0
            } else {
                junkyardsStackViewHeight.constant = 101
            }
		} else {
            junkyardView.isHidden = false
            junkyardViewHeight.constant = 84
			setDistance(gps: scarpyard!.gps!, label: lblJunkyardDistance)
			junkyardData = scarpyard
            if dustbin == nil {
                junkyardsStackViewHeight.constant = 101
            } else {
                junkyardsStackViewHeight.constant = 202
            }
		}
	}

	func updateEvents() {
		guard let _ = events.first else {
			eventsView.isHidden = true
			return
		}
		eventsView.isHidden = false
		vEvents.constraint(for: .height)?.constant = CGFloat(100 * events.count)
		tblEvents.reloadData()
	}

	// MARK: - Actions

	@IBAction func openArticle() {
		guard let article = articlesManager.news.first else { return }
		let st = UIStoryboard(name: "News", bundle: Bundle.main)
		guard let vc = st.instantiateViewController(withIdentifier: "NewsDetailViewController") as? NewsDetailViewController else { return }
		vc.articleId = article.id
		self.navigationController?.pushViewController(vc, animated: true)
	}

	@IBAction func openStatistics() {

		guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "StatisticViewController") as? StatisticViewController else { return }
		vc.manager = self.statistics
		self.navigationController?.pushViewController(vc, animated: true)
		
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Activity" {
			guard let vc = segue.destination as? DashboardActivityViewController else { return }
			self.activityVC = vc
		}
	}

	// MARK: - Events

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView === tblEvents {
			return self.eventsTableView(tableView, numberOfRowsInSection: section)
		}
		return 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView === tblEvents {
			return self.eventsTableView(tableView, cellForRowAt: indexPath)
		}
		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView == tblEvents {
			self.eventsTableView(tableView, didSelectRowAt: indexPath)
		}
	}

    // MARK: - UIScrollView delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let frame: CGRect! = reportButtonWrapper.frame
        if frame.intersects(CGRect(origin: scrollView.contentOffset, size: scrollView.contentSize)) {
            if (btnAddDumpWrapper.isHidden == false) { btnAddDumpWrapper.isHidden = true }
        } else {
            if (btnAddDumpWrapper.isHidden == true) { btnAddDumpWrapper.isHidden = false }
        }
    }
    
    // MARK: Notifications handling
    
    func registerForNotifcations() {
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.catchNotification), name: .userJoindedEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.catchNotification), name: .userUpdatedTrash, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.catchNotification), name: .userCreatedTrash, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.catchNotification), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.catchNotification), name: .userLoggedOut, object: nil)
    }
    
    func catchNotification(notification:Notification) -> Void {
        self.loadData(reload: true)
    }
    
    func unregisterFromNotifcations() {
        NotificationCenter.default.removeObserver(self, name: .userJoindedEvent, object: nil)
        NotificationCenter.default.removeObserver(self, name: .userUpdatedTrash, object: nil)
        NotificationCenter.default.removeObserver(self, name: .userCreatedTrash, object: nil)
        NotificationCenter.default.removeObserver(self, name: .userLoggedIn, object: nil)
        NotificationCenter.default.removeObserver(self, name: .userLoggedOut, object: nil)
    }
}

extension DashboardViewController {
    @objc func showDetailViewControllerAfterReceiveUserNotificationHandler(sender: Notification) {
        
    }
}
