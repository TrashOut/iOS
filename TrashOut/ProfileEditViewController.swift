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

class ProfileEditViewController: ViewController,
	UITextFieldDelegate,
	UITableViewDelegate, UITableViewDataSource,
	OrganizationPickerDelegate /* ,
	AreaPickerDelegate */ {

	@IBOutlet var scrollView: UIScrollView!

    @IBOutlet var ivPhoto: UIImageView!
    @IBOutlet var btnPhoto: UIButton!

	@IBOutlet var vProfile: UIView!
	@IBOutlet var lblProfile: UILabel!
	@IBOutlet var tfName: UITextField!
	@IBOutlet var tfSurname: UITextField!

	@IBOutlet var vContact: UIView!
	@IBOutlet var lblContact: UILabel!
	@IBOutlet var tfEmail: UITextField!
	@IBOutlet var tfPhone: UITextField!

	@IBOutlet var vOrganization: UIView!
	@IBOutlet var lblOrganization: UILabel!
	@IBOutlet var lblOrganizationSelect: UILabel!
	@IBOutlet var vOrganizationSelect: UIView!

//	@IBOutlet var vArea: UIView!
//	@IBOutlet var lblArea: UILabel!
//	@IBOutlet var lblAreaSelect: UILabel!
//	@IBOutlet var vAreaSelect: UIView!

	@IBOutlet var lblCoordinates: UILabel!
	@IBOutlet var tvCoordinates: UITableView!

	@IBOutlet var lblOther: UILabel!
	@IBOutlet var tvOther: UITableView!

	var user: User? {
		didSet {
			guard let user = user else { return }
			self.organizations = user.organizations
			self.areas = user.areas
		}
	}
//    var image: String?
//    var name: String?
//    var surname: String?

//    fileprivate var userImage = String() {
//        didSet {
//            let path = getDocumentsDirectory().appendingPathComponent(userImage)
//            ivPhoto.image = UIImage(contentsOfFile: path.path)
//        }
//    }
//    fileprivate var uploadData: Data!
	var userImage: LocalImage?
    fileprivate var photoName: String!
    fileprivate var profileImage: ProfileImage!
    fileprivate var photoURL: String!
    fileprivate var photosStorage: String!
	fileprivate var organizations: [Organization] = []
	fileprivate var areas: [Area] = []
	fileprivate var organizeEvents: Bool = false
	fileprivate var receiveNotifications: Bool = false
    fileprivate var volunteerCleanup: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()
		//guard let user = user else {return}

        self.title = "profile.header.editProfile.header".localized
        navigationItem.hidesBackButton = true

		tfName.delegate = self
		tfSurname.delegate = self

        lblProfile.text = "profile.yourProfile".localized
        lblProfile.textColor = Theme.current.color.green
		lblOrganization.text = "global.organization".localized
        lblOrganization.textColor = Theme.current.color.green
		lblOrganizationSelect.text = "profile.selectOrganization".localized
		lblCoordinates.text = "profile.gpsCoordinatesFormat".localized
		lblCoordinates.textColor = Theme.current.color.green
//		lblArea.text = "Area".localized
//		lblArea.textColor = Theme.current.color.green
//		lblAreaSelect.text = "Select your Area".localized
		lblContact.text = "event.contact".localized
		lblContact.textColor = Theme.current.color.green
		lblOther.text = "profile.other".localized
		lblOther.textColor = Theme.current.color.green

		tfSurname.placeholder = "user.lastName".localized
		tfName.placeholder = "user.firstName".localized
		tfEmail.placeholder = "global.email".localized
		tfPhone.placeholder = "global.phone".localized

		tfPhone.keyboardType = .phonePad
		tfEmail.keyboardType = .emailAddress
		tfName.keyboardType = .alphabet
		tfSurname.keyboardType = .alphabet

		tvOther.estimatedRowHeight = 44
		tvOther.rowHeight = UITableViewAutomaticDimension

        ivPhoto.layer.cornerRadius = 137/2
		ivPhoto.layer.masksToBounds = true

		btnPhoto.setImage(#imageLiteral(resourceName: "CameraClear"), for: .normal)
		btnPhoto.backgroundColor = UIColor.theme.button
		btnPhoto.layer.cornerRadius = 39/2
		btnPhoto.layer.masksToBounds = true

        let backButton = UIBarButtonItem.init(title: "global.cancel".localized, style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
		let doneButton = UIBarButtonItem.init(title: "global.done".localized, style: .plain, target: self, action: #selector(done))
		navigationItem.rightBarButtonItems = [doneButton]

		if let user = user {
			self.fillData(user: user)
		}
		
        if UserManager.instance.firAuth.isUserLogedViaFacebook() {
            tfEmail.isUserInteractionEnabled = false
        } else {
            tfEmail.isUserInteractionEnabled = true
        }
	}

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
    }

	func fillData(user: User) {
		self.receiveNotifications = user.newsletter
		self.organizeEvents = user.eventOrganizer
        self.volunteerCleanup = user.volunteerCleanup
		tvOther.reloadData()
		tfName.text = user.firstName
		tfSurname.text = user.lastName
		tfPhone.text = user.phone
		tfEmail.text = user.email
        self.setOrganizationString()
        
        if let image = user.image?.fullDownloadUrl {
            ivPhoto.remoteImage(id: image, placeholder: #imageLiteral(resourceName: "No image square"), animate: true)
        } else {
            ivPhoto.image = #imageLiteral(resourceName: "No image square")
        }
	}

    // MARK: - Actions
    
    func close() {
		_ = navigationController?.popViewController(animated: true)
    }

    /**
    Send data to server, (image first)
    */
	func done() {
		LoadingView.show(on: self.view, style: .transparent)
        if let image = userImage {
            FirebaseImages.instance.uploadImage(image) { [weak self] (thumbnailUrl, thumbnailStorage, imageUrl, imageStorage, error) in
                guard error == nil else {
                    print(error?.localizedDescription as Any)
                    self?.show(message: "profile.uploadFotoError".localized)
					LoadingView.hide()
                    return
                }
				guard imageUrl != nil else { LoadingView.hide(); return }
                self?.photoURL = imageUrl!

				guard imageStorage != nil else { LoadingView.hide(); return }
                self?.photosStorage = imageStorage!

                self?.updateUser()
            }
        } else {
            updateUser()
        }
    }
    
    /**
    Update user
    */
    fileprivate func updateUser() {

        let user = self.user ?? User()
        if tfName.text != "" {
            user.firstName = tfName.text
        }
        if tfSurname.text != "" {
            user.lastName = tfSurname.text
        }
		if tfPhone.text != "" {
			user.phone = tfPhone.text
		}
        
        let updateEmailId = (tfEmail.text != user.email) ? true : false
        
		if tfEmail.text != "" {
			user.email = tfEmail.text
		}
		user.eventOrganizer = organizeEvents
		user.newsletter = receiveNotifications
        user.volunteerCleanup = volunteerCleanup

        guard let uid = UserManager.instance.firAuth.uid() else {
            print("Fatal error: Unknown user UID")
            return
        }
        guard let userId = UserManager.instance.user?.id else {
            print("Fatal error: Unknown user ID")
			return
        }

        if photoURL != nil {
            let image = ProfileImage.init(fullDownloadUrl: photoURL, storageLocation: photosStorage)
            profileImage = image
        }
        
        if (updateEmailId == true) {
            UserManager.instance.firAuth.updateUserEmail(email: user.email ?? "") { [unowned self] (error) in
                guard error == nil else {
                    self.show(message: "profile.edit.error".localized)
                    return
                }
                Networking.instance.updateUser(user: user, id: userId, uid: uid, organizations: self.organizations, areas: self.areas, image: self.profileImage) { [weak self] (id, error) in
                    LoadingView.hide()
                    guard error == nil else {
                        self?.show(message: "global.register.identityError".localized)
                        return
                    }
                    self?.show(message: "profile.edit.success".localized) { [weak self] (alertAction) in
                        self?.logout()
                    }
                }
            }
        } else {
            Networking.instance.updateUser(user: user, id: userId, uid: uid, organizations: organizations, areas: areas, image: profileImage) { [weak self] (id, error) in
                LoadingView.hide()
                guard error == nil else {
                    self?.show(message: "profile.edit.error".localized)
                    return
                }
                self?.show(message: "profile.edit.success".localized) { [weak self] (alertAction) in
                    self?.close()
                }
            }
        }
    }

    func logout() {
        UserManager.instance.logout()
        guard let tabbarController = self.navigationController?.parent as? TabbarViewController else {return}
        
        UIView.transition(with: tabbarController.view, duration: 0.35, options: [.transitionCrossDissolve], animations: {
            
            tabbarController.showUnloggedTabbar()
            tabbarController.selectedIndex = 0
        }, completion: nil)
    }
    
    /**
    Hides keyboard when user touches Done button
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


	func textFieldDidBeginEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.35, animations: {
			let offset = textField.superview!.convert(textField.frame.origin, to: self.scrollView).y
			self.scrollView.contentOffset = CGPoint.init(x: 0, y: offset - 100)
		})
	}

	// MARK: - Organization picker

	@IBAction func selectOrganization() {
		guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrganizationPickerViewController") as? OrganizationPickerViewController else { return }
		vc.delegate = self
		vc.selectedOrganizations = self.organizations
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func organizationPicker(_ organizationPicker: OrganizationPickerViewController, didSelect organizations: [Organization]) {
		self.organizations = organizations
		self.setOrganizationString()
	}


	func setOrganizationString() {
		if self.organizations.count > 0 {
			lblOrganizationSelect.text = self.organizations
				.filter({$0.name != nil})
				.map({$0.name ?? ""})
				.joined(separator: ", ")
			lblOrganizationSelect.textColor = UIColor.black
		} else {
			lblOrganizationSelect.text = "profile.selectOrganization".localized
			lblOrganizationSelect.textColor = Theme.current.color.lightGray
		}
	}


	// MARK: - Area
//	@IBAction func selectArea() {
//		guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AreaPickerViewController") as? AreaPickerViewController else { return }
//		vc.delegate = self
//		vc.selectedAreas = areas
//		self.navigationController?.pushViewController(vc, animated: true)
//	}
//
//	func areaPicker(_ areaPicker: AreaPickerViewController, didSelect areas: [Area]) {
//		self.areas = areas
//		self.setAreaString()
//	}

//	func setAreaString() {
//		if self.areas.count > 0 {
//			self.lblAreaSelect.text = self.areas.map({$0.typeValue}).joined(separator: ", ")
//			self.lblAreaSelect.textColor = UIColor.black
//		} else {
//			self.lblAreaSelect.text = "Select your Area".localized
//			self.lblAreaSelect.textColor = Theme.current.color.lightGray
//		}
//	}


	// MARK: - GPS Coordinates format

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == tvCoordinates {
			return GpsFormatter.Format.allValues.count
		}
		if tableView == tvOther {
			return 2
		}
		return 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView == tvCoordinates {
			let cell = tableView.dequeueReusableCell(withIdentifier: "GpsFormatCell") as! GpsFormatCell

			let coords = LocationManager.manager.currentLocation.coordinate

			let format = GpsFormatter.Format.allValues[indexPath.row]

			if format == GpsFormatter.defaultFormat {
				cell.ivCheck.isHidden = false
			} else {
				cell.ivCheck.isHidden = true
			}
			cell.lblTitle.text = format.instance.string(fromLat: coords.latitude, lng: coords.longitude)
			return cell
		}
		if tableView == tvOther {
			let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCheckCell", for: indexPath) as! ProfileCheckCell
			if indexPath.row == 0 {
				cell.lblTitle.text = "event.organizeAction".localized
				cell.swSwitch.isOn = organizeEvents
				cell.onSwitch = { [weak self] (checked) in
					self?.organizeEvents = checked
				}
			}
			if indexPath.row == 1 {
				cell.lblTitle.text = "user.volunteerCleanup.yes".localized
				cell.swSwitch.isOn = volunteerCleanup
				cell.onSwitch = { [weak self] (checked) in
					self?.volunteerCleanup = checked
				}
			}

			return cell
		}

		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView == tvCoordinates {
			let format = GpsFormatter.Format.allValues[indexPath.row]
			GpsFormatter.defaultFormat = format
			tableView.reloadData()
		}
	}

	// MARK: - Photo

	var photoManager: PhotoManager?

    @IBAction func takeAPhoto(_ sender: Any) {
        let alert = UIAlertController(title: "global.camera.photoSource".localized, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction.init(title: "global.camera".localized, style: .default) { (action) in
            self.photoManager = PhotoManager()
            self.photoManager?.takePhoto(vc: self, source: .camera , success: { [weak self] (localImage) in
                self?.userImage = localImage
                self?.ivPhoto.image = localImage.image
                }, failure: { (error) in
                    // dont care, all errors shoud be handled by manager
            })
            
        }
        let photoRoll = UIAlertAction.init(title: "global.gallery".localized, style: .default) { (action) in
            self.photoManager = PhotoManager()
            self.photoManager?.takePhoto(vc: self, source: .photoLibrary , success: { [weak self] (localImage) in
                self?.userImage = localImage
                self?.ivPhoto.image = localImage.image
                }, failure: { (error) in
                    // dont care, all errors shoud be handled by manager
            })
        }
        let cancel = UIAlertAction.init(title: "global.cancel".localized, style: .cancel) { (action) in
                
        }
        alert.addAction(camera)
        alert.addAction(photoRoll)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
 
    
    }

}

class ProfileImage: NSObject {
    var fullDownloadUrl: String
    var storageLocation: String

    init(fullDownloadUrl: String, storageLocation: String) {
        self.fullDownloadUrl = fullDownloadUrl
        self.storageLocation = storageLocation
    }
}

class GpsFormatCell: UITableViewCell {

	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var ivCheck: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		ivCheck.image = #imageLiteral(resourceName: "Checked").withRenderingMode(.alwaysTemplate)
		ivCheck.tintColor = Theme.current.color.green
	}

}

class ProfileCheckCell: UITableViewCell {

	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var swSwitch: UISwitch!

	var onSwitch: ((Bool)->())?

	override func awakeFromNib() {
		super.awakeFromNib()
		swSwitch.addTarget(self, action: #selector(switched), for: .valueChanged)
	}

	@IBAction func switched() {
		if let cb = onSwitch {
			cb(swSwitch.isOn)
		}
	}

}
