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

class ProfileViewController: ViewController,
	UICollectionViewDelegate, UICollectionViewDataSource,
	OrganizationPickerDelegate {

	@IBOutlet var scrollView: UIScrollView!

	@IBOutlet var ivImage: UIImageView!
    @IBOutlet var vName: UIView!
	@IBOutlet var lblName: UILabel!
	@IBOutlet var lblNotPickedOrganization: UILabel!
	@IBOutlet var lblOrganizations: UILabel!
	@IBOutlet var btnSelectOrganization: UIButton!
	@IBOutlet var cnsNameBtnBottom: NSLayoutConstraint!
	@IBOutlet var cnsNameOrgsBottom: NSLayoutConstraint!

	@IBOutlet var vActivities: UIView!
	@IBOutlet var lblActivities: UILabel!
	@IBOutlet var tvActivities: UITableView!
	@IBOutlet var btnActivitiesMore: UIButton!

	@IBOutlet var vBadges: UIView!
	@IBOutlet var lblBadges: UILabel!
	@IBOutlet var lblBadgesDescription: UILabel!
	@IBOutlet var cvBadges: UICollectionView!
	@IBOutlet var cnsBadgesHeight: NSLayoutConstraint!
	@IBOutlet var lblLevel: UILabel!
	@IBOutlet var vLevel: UIView!

	@IBOutlet var lblOther: UILabel!
	@IBOutlet var lblOrganizeEvents: UILabel!
	@IBOutlet var lblNotifyEvents: UILabel!
//	@IBOutlet var lblArea: UILabel!
	@IBOutlet var lblEmail: UILabel!
	@IBOutlet var lblPhone: UILabel!
    
	var activitiesDataSource: ActivitiesTableViewDataSource?
    var user: User?

    override func viewDidLoad() {
		super.viewDidLoad()

		title = "tab.profile".localized
        
        ivImage.clipsToBounds = true
		lblNotPickedOrganization.text = "profile.validation.emptyOrganization".localized
		lblActivities.text = "profile.yourActivities".localized
        lblActivities.textColor = Theme.current.color.green
		lblBadges.text = "profile.badges".localized
        lblBadges.textColor = Theme.current.color.green

		lblOther.text = "profile.other".localized
		lblOther.textColor = Theme.current.color.green

		vLevel.backgroundColor = UIColor(rgba: "#e5e5e5")
		lblLevel.textColor = UIColor.theme.lightGray
		lblLevel.font = UIFont.boldSystemFont(ofSize: 32)

		setupPoints(self.user?.points ?? 0)

		btnSelectOrganization.theme()

		activitiesDataSource = ActivitiesTableViewDataSource()
		activitiesDataSource?.controller = self
		tvActivities.dataSource = activitiesDataSource
		tvActivities.delegate = activitiesDataSource
		tvActivities.tableFooterView = UIView()
		btnActivitiesMore.theme()
		btnActivitiesMore.setTitle("home.more".localized.uppercased(with: Locale.current), for: .normal)
        btnSelectOrganization.setTitle("profile.selectOrganization".localized.uppercased(with: Locale.current), for: .normal)

        let logoutButton = UIBarButtonItem.init(title: "profile.logout".localized, style: .plain, target: self, action: #selector(logout))
        navigationItem.leftBarButtonItem = logoutButton
		let editButton = UIBarButtonItem.init(title: "global.edit".localized, style: .plain, target: self, action: #selector(editProfile))
		navigationItem.rightBarButtonItem = editButton
		self.addPullToRefresh(into: self.scrollView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		btnActivitiesMore.theme()
	}

	func addPullToRefresh(into scrollView: UIScrollView) {
        scrollView.addPullToRefreshHandler { [weak self] in
            self?.loadData(refreshing: true)
        }
	}

	var firebaseToken: String?
	fileprivate func loadData(refreshing: Bool = false) {
		if refreshing {
		} else {
			LoadingView.show(on: self.view, style: .white)
		}
		let finalize: () -> () = { [weak self] _ in
            DispatchQueue.main.async {
                if refreshing {
                    self?.scrollView.pullToRefreshView?.stopAnimating()
                } else {
                    LoadingView.hide()
                }
            }
		}
		Async.waterfall([
			// load user
		  	{ [weak self] (completion, failure) in
				Networking.instance.userMe { [weak self] (user, error) in
					if let error = error {
						failure(error)
						return
					}
					self?.user = user
					completion()
				}
			},
		  	// user by id
			/*{ [ weak self] (completion, failure) in
				guard let userId = self?.user?.id else {
					failure(NSError.init(domain: "cz.trashout.Trashout", code: 500, userInfo: [NSLocalizedDescriptionKey: "No user"]))
					return
				}
				Networking.instance.user(userId, callback: { (user, error) in
					if let error = error {
						failure(error)
						return
					}
					self?.user = user
					completion()
				})
			},*/
			{ [weak self] (completion, _) in
				guard let user = self?.user else {
					finalize()
					completion()
					return
				}
				self?.fillData(user: user)
				finalize()
				completion()
			}
		]) { [weak self] (error) in
				print(error.localizedDescription)
				self?.show(error: error) {
					finalize()
					NoDataView.show(over: self?.scrollView, text: "global.noData".localized)
				}
		}

    }
    
	fileprivate func fillData(user: User) {
		if let firstName = user.firstName,
			let lastName = user.lastName {
			self.lblName.text = "\(firstName) \(lastName)"
		} else if let name = user.firstName ?? user.lastName {
			self.lblName.text = "\(name)"
		} else {
			self.lblName.text = "trash.anonymous".localized
		}

		if let points = user.points {
			self.setupPoints(points)
		}

        if let image = user.image?.fullDownloadUrl {
            ivImage.remoteImage(id: image, placeholder: #imageLiteral(resourceName: "No image wide"), animate: true)
        } else {
            ivImage.image = #imageLiteral(resourceName: "No image wide")
        }

		if user.organizations.count > 0 {
			lblOrganizations.isHidden = false
			lblNotPickedOrganization.isHidden = true
			btnSelectOrganization.isHidden = true

			lblOrganizations.text = user.organizations.map({$0.name ?? ""}).joined(separator: ", ")
			cnsNameOrgsBottom.priority = 999
			cnsNameBtnBottom.priority = 1

		} else {
			lblOrganizations.isHidden = true
			lblNotPickedOrganization.isHidden = false
			btnSelectOrganization.isHidden = false
			cnsNameOrgsBottom.priority = 1
			cnsNameBtnBottom.priority = 999
		}

		lblEmail.text = user.email
		lblPhone.text = user.phone ?? "global.phoneNotSet".localized

		lblOrganizeEvents.text = user.eventOrganizer ?
			"event.organizeAction".localized :
			"event.dontWantOrganize".localized

        lblNotifyEvents.text = user.volunteerCleanup ?
            "user.volunteerCleanup.yes".localized :
            "user.volunteerCleanup.no".localized
        
        /*
		lblNotifyEvents.text = user.newsletter ?
			"event.actionNotification".localized :
			"event.dontWantReceiveNotification".localized
        */

//		if user.areas.count > 0 {
//			let areaString = user.areas.map { $0.typeValue }.joined(separator: ", ")
//			lblArea.text = String.init(format: "Geographic area: %@".localized, areaString)
//		} else {
//			lblArea.text = "Geographic area not set".localized
//		}

		activitiesDataSource?.cleaned = user.stats.cleaned
		activitiesDataSource?.reported = user.stats.reported
		activitiesDataSource?.updated = user.stats.updated
		tvActivities.reloadData()
		if user.stats.cleaned == 0,
			user.stats.reported == 0,
			user.stats.updated == 0 {
			btnActivitiesMore.theme()
			btnActivitiesMore.isHidden = true
			btnActivitiesMore.constraint(for: .top)?.priority = 1
			btnActivitiesMore.constraint(for: .bottom)?.priority = 1
		} else {
			btnActivitiesMore.isHidden = false
			btnActivitiesMore.constraint(for: .top)?.priority = 999
			btnActivitiesMore.constraint(for: .bottom)?.priority = 999
			btnActivitiesMore.theme()

		}

//		if user.badges.count == 0 {
			cnsBadgesHeight.constant = 0
//		} else {
//			cnsBadgesHeight.constant = 122
//		}

		if let points = user.points, points >= 10 {
			vLevel.constraint(for: .height)?.constant = 128
			let level = user.level
			lblLevel.text = "user.level".localized + String.init(format: " %d", level)
			lblLevel.textColor = UIColor.white
			let levelColors: [String] = [
				"#EFC94C",
				"#81C784",
				"#EF734C",
				"#AC8710",
				"#3FBC47",
				]
			let colorIndex = (level - 1) % levelColors.count
			let colorRGB = levelColors[colorIndex]
			vLevel.backgroundColor = UIColor.init(rgba: colorRGB)
		} else {
			vLevel.constraint(for: .height)?.constant = 0
        }
	}

	fileprivate func setupPoints(_ points: Int) {

		let str = "profile.earnedPoints_X".localized(points) /*(self.user?.badges.count ?? 0) > 0 ?
			"profile.earnedPoints_X".localized(points) :
			"You have earned %d points so far! Search for some more dumps to receive badges!".localized(points)*/

		let boldPoints = "profile.points_X".localized(points)

		let attrString = NSMutableAttributedString.init(string: str, attributes: [
			NSForegroundColorAttributeName: UIColor.lightGray,
			NSFontAttributeName: UIFont.systemFont(ofSize: 12)
			])

		let range = (str as NSString).range(of: boldPoints)
		attrString.addAttributes([
			NSForegroundColorAttributeName: UIColor.black,
			NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)
			], range: range)

		self.lblBadgesDescription.attributedText = attrString
	}

	func editProfile() {
		guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController else {return}
        vc.user = user
//        vc.image = user?.image?.fullDownloadUrl
//        vc.name = user?.firstName
//        vc.surname = user?.lastName
		navigationController?.pushViewController(vc, animated: true)
	}

    func logout() {
        UserManager.instance.logout {
            
            // Register notifications.
            NotificationsManager.unregisterUser { error in
                NotificationsManager.registerNotifications()
            }
        }
        

        
        guard let tabbarController = self.navigationController?.parent as? TabbarViewController else {return}

        UIView.transition(with: tabbarController.view, duration: 0.35, options: [.transitionCrossDissolve], animations: {
            tabbarController.showUnloggedTabbar()
            tabbarController.openDashboard(refresh: true)
        }, completion: nil)
    }

	@IBAction func selectOrganization() {
		guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrganizationPickerViewController") as? OrganizationPickerViewController else { return }
		vc.delegate = self
		vc.selectedOrganizations = self.user?.organizations ?? []
		self.navigationController?.pushViewController(vc, animated: true)
		
	}

	func organizationPicker(_ organizationPicker: OrganizationPickerViewController, didSelect organizations: [Organization]) {
		guard let user = self.user else { return }

//		let oldOrganizations = self.user?.organizations ?? []
//		let addOrganizations = organizations.filter { (org) -> Bool in
//			return oldOrganizations.contains(where: { (o) -> Bool in
//				return o.id == org.id
//			}) == false
//		}
//		let removeOrganizations = oldOrganizations.filter { (org) -> Bool in
//			return organizations.contains(where: { (o) -> Bool in
//				return o.id == org.id
//			}) == false
//		}

		// TODO: role id ??
		let orgs = organizations.map { (o) -> (id: Int, role: Int) in
			return (id: o.id, role: 1)
		}

		Networking.instance.setUserOrganizations(user: user, organizations: orgs) { [weak self] (error) in
			self?.loadData()
		}

	}

    /**
    Get URL of directory where photos are stored
    */
    fileprivate func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    // MARK: - Collection view
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgesCell", for: indexPath) as? BadgesCollectionViewCell else { fatalError("global.generalError".localized) }

        return cell
    }

	class ActivitiesTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

		weak var controller: ProfileViewController?

		var reported: Int = 0
		var updated: Int = 0
		var cleaned: Int = 0

		func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return 3
		}

		func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as? ActivityTableViewCell else {return UITableViewCell()}

			var type: ActivityTableViewCell.ActivityCell!
			switch indexPath.row {
			case 0:
				type = .reported(value: self.reported)
				break
			case 1:
				type = .updated(value: self.updated)
				break
			case 2:
				type = .cleaned(value: self.cleaned)
				break
			default:
				return cell
			}

			cell.setup(type)

			if indexPath.row == 2 { // last cell
				cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0) // remove separator
			} else {
				cell.separatorInset = UIEdgeInsetsMake(0, 5, 0, 5) // add separator
			}

			cell.lblValue.text = "global.numberOfTimes_X".localized(type.value)
			cell.lblValue.font = cell.lblValue.font.monospacedDigitFont

			return cell
		}

		func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
			controller?.openActivityList()
		}
	}



	@IBAction func openActivityList() {
		guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ActivityListViewController") as? ActivityListViewController else { return }
		vc.user = user
		self.navigationController?.pushViewController(vc, animated: true)
	}

}

class ActivityTableViewCell: UITableViewCell {

	enum ActivityCell {
		case reported(value: Int)
		case updated(value: Int)
		case cleaned(value: Int)

		var icon: UIImage? {
			get {
				switch self {
				case .reported:
					return UIImage(named: "Reported")
				case .updated:
					return UIImage(named: "Updated")
				case .cleaned:
					return UIImage(named: "Cleaned")
				}
			}
		}
		var title: String? {
			get {
				switch self {
				case .reported:
					return "profile.youReported".localized
				case .updated:
					return "profile.youUpdated".localized
				case .cleaned:
					return "profile.youCleaned".localized
				}
			}
		}
		var value: Int {
			switch self {
			case .reported(let val):
				return val
			case .updated(let val):
				return val
			case .cleaned(let val):
				return val
			}
		}
		var valueColor: UIColor {
			get {
				switch self {
				case .reported:
					return UIColor.theme.red
				case .updated:
					return UIColor.theme.orange
				case .cleaned:
					return UIColor.theme.green
				}
			}
		}

	}

	@IBOutlet var ivIcon: UIImageView!
	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var lblValue: UILabel!

	func setup(_ type: ActivityCell) {
		ivIcon.image = type.icon
		lblTitle.text = type.title
		lblValue.textColor = type.valueColor
	}

}

class BadgesCollectionViewCell: UICollectionViewCell {

    @IBOutlet var ivPhoto: UIImageView!

    @IBOutlet var lblLevel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        ivPhoto.cancelRemoteImageRequest()
    }
}
