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
import CoreLocation
import MapKit
import MessageUI

class JunkyardsDetViewController: ViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var telephoneAndEmailView: UIView! {
        didSet {
            telephoneAndEmailView.isHidden = true
        }
    }
    @IBOutlet var openingHoursView: UIView! {
        didSet {
            openingHoursView.isHidden = true
        }
    }
    @IBOutlet var infoView: UIView! {
        didSet {
            infoView.isHidden = true
        }
    }

    @IBOutlet var txvCoordinates: UITextView!
    @IBOutlet var txvJunkyardAddress: UITextView!
    
    @IBOutlet var lblJunkyardName: UILabel!
    @IBOutlet var lblDistance: UILabel!
    @IBOutlet var lblRecycable: UILabel!
    @IBOutlet var lblContact: UILabel!
    @IBOutlet var lblTelephone: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblWebsite: UILabel!
    @IBOutlet var lblOpeningHours: UILabel!
    @IBOutlet var lblDays: UILabel!
    @IBOutlet var lblDays2: UILabel!
    @IBOutlet var lblDaysOpeningHours: UILabel!
    @IBOutlet var lblDaysOpeningHours2: UILabel!
    @IBOutlet var lblInfo: UILabel!

    @IBOutlet var btnDirections: UIButton!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var btnNoLongerExists: UIButton!

	@IBOutlet var vPhone: UIView!
	@IBOutlet var vEmail: UIView!
    @IBOutlet var vWebsite: UIView!

    var junkyard: Junkyard!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "tab.recycling".localized

        lblDistance.textColor = Theme.current.color.lightGray
        txvCoordinates.textColor = Theme.current.color.lightGray
        lblContact.text = "event.contact".localized
        lblContact.textColor = Theme.current.color.green
        lblOpeningHours.text = "collectionPoint.openingHours".localized
        lblOpeningHours.textColor = Theme.current.color.green

        btnDirections.setTitle("global.direction".localized.uppercased(with: .current), for: .normal)
        btnDirections.theme()
        btnEdit.setTitle("global.edit".localized.uppercased(with: .current), for: .normal)
        btnEdit.theme()
        btnNoLongerExists.setTitle("global.noLongerExistQuestion".localized.uppercased(with: .current), for: .normal)
        btnNoLongerExists.theme()
        btnNoLongerExists.backgroundColor = Theme.current.color.red

        setJunkyardsInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        txvCoordinates.textContainer.lineFragmentPadding = 0
        txvCoordinates.textContainerInset = .zero
        
        txvJunkyardAddress.textContainer.lineFragmentPadding = 0
        txvJunkyardAddress.textContainerInset = .zero
    }

    func setJunkyardAddress() {
        setAddress(gps: junkyard.gps!, input: &txvJunkyardAddress.text)
    }
    
	func setJunkyardName() {
		// Junkyard name
		if let name = junkyard.name, let size = junkyard.size {
            if size == "dustbin" {
                lblJunkyardName.text = "collectionPoint.size.recyclingBin".localized
            } else {
                lblJunkyardName.text = name
            }
		} else {
			if let size = junkyard.size {
				if size == "dustbin" {
					lblJunkyardName.text = "collectionPoint.size.recyclingBin".localized
				} else {
					lblJunkyardName.text = "collectionPoint.size.recyclingCenter".localized
				}
			}
		}
	}

	func setCoordsAndDistance() {
		guard let gps = junkyard.gps else {
			txvCoordinates.text = ""
			lblDistance.text = ""
			return
		}
		let junkyardCollection = CLLocation.init(latitude: gps.lat, longitude: gps.long)
		let distance = LocationManager.manager.currentLocation.distance(from: junkyardCollection)
		let distanceInM = Int(round(distance))
		// Coordinates label
		txvCoordinates.text = GpsFormatter.instance.string(from: gps)
		lblDistance.text = DistanceRounding.shared.localizedDistance(meteres: distanceInM)
	}

	func setTrashTypes() {
        let mutableString = NSMutableAttributedString(string: "collectionPoint.detail.mobile.recycable".localized + ": ")
		mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: Theme.current.color.lightGray, range: NSRange(location: 0, length: mutableString.length))

		if let updatedTypes = junkyard.updates.last?.types {
			let mutableString2 = NSMutableAttributedString(string: showAllTypesOfTrash(junkyard: junkyard, type: updatedTypes))

			let combination = NSMutableAttributedString()
			combination.append(mutableString)
			combination.append(mutableString2)

			lblRecycable.attributedText = combination
		} else {
			if !junkyard.types.isEmpty {
				let mutableString2 = NSMutableAttributedString(string: showAllTypesOfTrash(junkyard: junkyard, type: junkyard.types))

				let combination = NSMutableAttributedString()
				combination.append(mutableString)
				combination.append(mutableString2)

				lblRecycable.attributedText = combination
			}
		}
	}

	func showScrapyardInfo() {
        telephoneAndEmailView.isHidden = false
        
        if let phone = junkyard.phone, phone.count > 0 {
            lblTelephone.text = phone
        } else {
            lblTelephone.text = "collectionPoint.phone_is_missing".localized
            lblTelephone.textColor = Theme.current.color.lightGray
        }
        
		if let email = junkyard.email, email.count > 0 {
			lblEmail.text = email
		} else {
            lblEmail.text = "collectionPoint.email_is_missing".localized
            lblEmail.textColor = Theme.current.color.lightGray
		}
		
        if let website = junkyard.website, website.count > 0 {
            lblWebsite.text = website
        } else {
            lblWebsite.text = "collectionPoint.web_is_missing".localized
            lblWebsite.textColor = Theme.current.color.lightGray
        }

		infoView.isHidden = false
        openingHoursView.isHidden = false
        lblDays.text = ""
        lblDaysOpeningHours.text = ""
        for item in junkyard.openingHours {
            
            lblDays.text = lblDays.text! + (item.localizedName ?? "")
            for period in item.periods {
                lblDays.text = lblDays.text! + "\n"
                var start = period.start ?? ""
                if start.count > 2 {
                    start.insert(":", at: start.index(start.startIndex, offsetBy: 2))
                }
                var finish = period.finish ?? ""
                if finish.count > 2 {
                    finish.insert(":", at: finish.index(finish.startIndex, offsetBy: 2))
                }
                lblDaysOpeningHours.text = lblDaysOpeningHours.text! + start + " - " + finish + "\n"
            }
        }
        
		//lblDaysOpeningHours.text = "FIX" // junkyard.openingHours
		lblInfo.text = junkyard.note
	}

    fileprivate func setJunkyardsInfo() {
		self.setJunkyardName()
        self.setJunkyardAddress()
		self.setCoordsAndDistance()
		self.setTrashTypes()

        // Show more info, if junkyard is a scrapyard
        if let size = junkyard.size, size == "scrapyard" {
			self.showScrapyardInfo()
        }

    }

    /**
    Return all types of trash in junkyard
    */
	fileprivate func showAllTypesOfTrash(junkyard: Junkyard, type: [Junkyard.JunkyardType]) -> String {
		let types: [String] = junkyard.types.map {$0.localizedName}
		let allTypes = types.joined(separator: ", ").uppercaseFirst
		return allTypes
	}

    @IBAction func goToNavigation(_ sender: UIButton) {
        show(message: "collectionPoint.mapNavigation.message".localized, okAction: { [weak self] (alertAction) in
            if let junkyard = self?.junkyard {
                guard let gps = junkyard.gps else { return }
                let coords = CLLocationCoordinate2D(latitude: gps.lat, longitude: gps.long)
                let item = MKMapItem(placemark: MKPlacemark(coordinate: coords, addressDictionary: nil))
                item.name = "collectionPoint.size.recyclingCenter".localized
                item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            }
        })
    }

	@IBAction func reportAsSpam() {
        show(message: "collectionPoint.markAsNoLongerExistsFailed.message".localized, okAction: { [weak self] (alertAction) in
            LoadingView.show(on: (self?.view)!, style: .transparent)
            if let junkyard = self?.junkyard {
                Networking.instance.junkyardReportSpam(junkyard) { [weak self] (error) in
                    LoadingView.hide()
                    if let error = error {
                        self?.show(error: error)
                    } else {
                        self?.show(message: "collectionPoint.markedAsSpam.success.thanksMobile".localized)
                    }
                }
            }
        })
	}

	@IBAction func phoneTap() {
        if let phone = junkyard.phone, !phone.isEmpty {
            show(message: "collectionPoint.phoneCall.message".localized, okAction: { [weak self] (alertAction) in
                if let junkyard = self?.junkyard {
                    guard let phone = junkyard.phone else { return }
                    guard let number = URL(string: "telprompt://" + phone) else { return }
                    UIApplication.shared.open(number)
                }
            })
        } else {
            editJunkyard()
        }
	}
    
    @IBAction func websiteTap() {
        if let url = junkyard.website.flatMap(URL.init) {
            UIApplication.shared.open(url)
        } else {
            editJunkyard()
        }
    }

	@IBAction func emailTap() {
        if let email = junkyard.email, !email.isEmpty {
            show(message: "collectionPoint.email.message".localized, okAction: { [weak self] (alertAction) in
                if let junkyard = self?.junkyard {
                    guard let email = junkyard.email else { return }
                    guard MFMailComposeViewController.canSendMail() else { return }
                    let mail = MFMailComposeViewController.init()
                    mail.setToRecipients([email])
                    mail.mailComposeDelegate = self
                    mail.navigationBar.tintColor = UIColor.white
                    self?.present(mail, animated: true, completion: nil)
                }
            })
        } else {
            editJunkyard()
        }
	}

	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
    
    @IBAction func editJunkyard() {
        let url = Networking.adminWebUrl.appendingPathComponent("/collection-points/update/\(junkyard.id)")
        show(title: "home.recycling_point_edit_title".localized, message: "home.recycling_point_edit_redirect".localized, okAction: { _ in
            UIApplication.shared.open(url)
        })
    }
}
