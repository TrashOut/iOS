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

protocol WriteCityAndStreetBack: class {
    func writeCityAndStreetBack(value: String)
}

protocol WriteLocationBack: class {
    func writeLocationBack(value: CLLocationCoordinate2D)
}

protocol WriteStartDateBack: class {
    func writeStartDateBack(value: String, date: Date?)
}

protocol WriteEndDateBack: class {
    func writeEndDateBack(value: String, date: Date?)
}

protocol WriteNumberOfSelectedDumpsBack: class {
    func writeNumberOfSelectedDumpsBack(value: String, selectedDumps: [Int]?, numberOfSelectedDumps: Int?)
}

class EventNewViewController: ViewController, UITextViewDelegate {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBOutlet var scrollView: UIScrollView!

//    @IBOutlet var loadingView: UIView! {
//        didSet {
//            loadingView.isHidden = true
//        }
//    }
    @IBOutlet var locationOnMapView: UIView! {
        didSet {
            locationOnMapView.isHidden = true
        }
    }

//    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var vDescSeparator: [UIView]!

    @IBOutlet var lblAboutAnEvent: UILabel!
    @IBOutlet var lblMeetingPoint: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblGPS: UILabel!
    @IBOutlet var lblDumpsToBeCleaned: UILabel!
    @IBOutlet var lblSelectedDumps: UILabel!
    @IBOutlet var lblDuration: UILabel!
    @IBOutlet var lblStartDate: UILabel!
    @IBOutlet var lblEndDate: UILabel!
    @IBOutlet var lblEquipment: UILabel!
    @IBOutlet var lblContact: UILabel!

    @IBOutlet var btnSetLocationOnMap: UIButton!
    @IBOutlet var btnSelectDumpsOnMap: UIButton!

    @IBOutlet var tvEventName: UITextView!
    @IBOutlet var tvDescription: UITextView!
    @IBOutlet var tvEquipmentAttendees: UITextView!
    @IBOutlet var tvEquipmentWe: UITextView!
    @IBOutlet var tvEmail: UITextView!
    @IBOutlet var tvPhone: UITextView!

    @IBOutlet var cnAboutAnEventSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var cnEventDateSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var cnEquipmentSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var cnContactSeparatorHeight: NSLayoutConstraint!

    var savedLocation: CLLocationCoordinate2D?
    var trashId: Int!

	var onEventCreated: (() -> ())?

    fileprivate var name: String! {
        didSet {
            if name == "" { name = nil }
        }
    }
    fileprivate var descript: String! {
        didSet {
            if descript == "" { descript = nil }
        }
    }
    fileprivate var start: String!
    fileprivate var bring: String!
    fileprivate var duration = 0
    fileprivate var have: String!
    fileprivate var phone: String! {
        didSet {
            if phone == "" { phone = nil }
        }
    }
    fileprivate var email: String!
    {
        didSet {
            if email == "" { email = nil }
        }
    }
    fileprivate var startDate: Date!
    fileprivate var endDate: Date!
    fileprivate var numberOfDumps = 1
    fileprivate var collectionPointIds: [Int]! = []
    fileprivate var gps: Coordinates!
    fileprivate var trashIds = [Int]() {
        didSet {
            print(trashIds)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "event.create.header".localized

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)

        let backButton = UIBarButtonItem.init(title: "global.cancel".localized, style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        let sendButton = UIBarButtonItem(title: "global.create".localized, style: .plain, target: self, action: #selector(createEvent))
        navigationItem.rightBarButtonItem = sendButton

        cnAboutAnEventSeparatorHeight.preciseConstant = 1
        cnEventDateSeparatorHeight.preciseConstant = 1
        cnEquipmentSeparatorHeight.preciseConstant = 1
        cnContactSeparatorHeight.preciseConstant = 1

        lblAboutAnEvent.text = "event.about".localized
        lblAboutAnEvent.textColor = Theme.current.color.green
        lblMeetingPoint.text = "event.meetingPoint".localized
        lblMeetingPoint.textColor = Theme.current.color.green
        lblGPS.textColor = Theme.current.color.lightGray
        lblDumpsToBeCleaned.text = "event.create.dumpsToBeCleaned".localized
        lblDumpsToBeCleaned.textColor = Theme.current.color.green
        lblSelectedDumps.text = "event.create.dumpIsAlreadySelected".localized
        lblSelectedDumps.textColor = Theme.current.color.lightGray
        lblDuration.text = "event.eventDate".localized
        lblDuration.textColor = Theme.current.color.green
        lblStartDate.text = "event.start".localized
        lblStartDate.textColor = Theme.current.color.lightGray
        lblEndDate.text = "event.end".localized
        lblEndDate.textColor = Theme.current.color.lightGray
        lblEquipment.text = "event.equipment".localized
        lblEquipment.textColor = Theme.current.color.green
        lblContact.text = "event.contact".localized
        lblContact.textColor = Theme.current.color.green

        tvEventName.text = "event.name".localized
        tvEventName.textColor = Theme.current.color.lightGray
        tvDescription.text = "event.description.hint".localized
        tvDescription.textColor = Theme.current.color.lightGray
        tvEquipmentAttendees.text = "event.whatBringFull".localized
        tvEquipmentAttendees.textColor = Theme.current.color.lightGray
        tvEquipmentWe.text = "event.whatWeHaveFull".localized
        tvEquipmentWe.textColor = Theme.current.color.lightGray
        tvPhone.text = "global.phone".localized
        tvPhone.textColor = Theme.current.color.lightGray

        btnSetLocationOnMap.setTitle("event.create.setLocationOnMap".localized.uppercased(with: .current), for: .normal)
        btnSetLocationOnMap.theme()
        btnSelectDumpsOnMap.setTitle("event.create.selectDumpsOnMap".localized.uppercased(with: .current), for: .normal)
        btnSelectDumpsOnMap.theme()

        for separator in vDescSeparator {
            separator.backgroundColor = UIColor.theme.separatorLine
        }

        // Making Date and Time labels touchable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(setStartDate(_:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(setEndDate(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture2.numberOfTapsRequired = 1
        lblStartDate.isUserInteractionEnabled = true
        lblStartDate.addGestureRecognizer(tapGesture)
        lblEndDate.isUserInteractionEnabled = true
        lblEndDate.addGestureRecognizer(tapGesture2)

        addDoneButtonToPhonePad()

		if let user = UserManager.instance.user {
			if let userEmail = user.email {
				email = userEmail
				tvEmail.text = userEmail
			} else {
				email = "global.email".localized
				tvEmail.text = email
			}
			if let userPhone = user.phone {
				phone = userPhone
				tvPhone.text = userPhone
			} else {
				tvPhone.text = "global.phone".localized
			}
		}

        if trashIds.isEmpty {
            trashIds.append(trashId)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.window?.endEditing(true)
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tvEventName.adjustSize()
		tvDescription.adjustSize()
		tvEquipmentAttendees.adjustSize()
		tvEquipmentWe.adjustSize()
		tvPhone.adjustSize()
	}

    // MARK: - Actions

    func close() {
        LoadingView.hide()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    /**
    Create an event
    */
    func createEvent() {
		guard let name = name,
			let descript = descript,
			let start = start,
			let _ = endDate,
			//let bring = bring,
			//let have = have,
			let email = email,
			let phone = phone,
			let gps = gps,
			!trashIds.isEmpty else {
            show(message: "trash.create.validation.notFilledRequiredFileds".localized) { [unowned self] in
                if (self.name == nil || self.name!.isEmpty == true) { self.tvEventName.requiredHighlightTextField() }
                if (self.descript == nil || self.descript!.isEmpty == true) { self.tvDescription.requiredHighlightTextField() }
                //if (self.bring == nil || self.bring!.isEmpty == true) { self.tvEquipmentAttendees.requiredHighlightTextField() }
                //if (self.have == nil || self.have!.isEmpty == true) { self.tvEquipmentWe.requiredHighlightTextField() }
                if (self.gps == nil) { self.lblMeetingPoint.requiredHighlightTextField() }
                if (self.email == nil || self.email!.isEmpty == true) { self.tvEmail.requiredHighlightTextField() }
                if (self.phone == nil || self.phone!.isEmpty == true) { self.tvPhone.requiredHighlightTextField() }
                if (self.start == nil || self.start!.isEmpty == true) { self.lblStartDate.requiredHighlightTextField() }
                if (self.endDate == nil) { self.lblEndDate.requiredHighlightTextField() }
            }
			return
		}

		LoadingView.show(on: self.view, style: .white)

		let interval = Int(endDate.timeIntervalSince(startDate))
		duration = interval / 60

		let contact = Contact.init(email: email, phone: phone)
        if (bring == nil ) { bring = "" }
        if (have == nil ) { have = "" }
        
		Networking.instance.createEvent(name, gps: gps, description: descript, start: start, duration: duration, bring: bring, have: have, contact: contact, trashPointsId: trashIds, collectionPointIds: collectionPointIds) { [weak self] (event, error) in
			guard error == nil else {
				print(error?.localizedDescription as Any)
				self?.show(message: (error?.localizedDescription)!)
				LoadingView.hide()
				return
			}
			self?.onEventCreated?()
			let alert = UIAlertController(title: nil, message: "event.create.saved".localized, preferredStyle: .alert)
			let ok = UIAlertAction.init(title: "global.ok".localized, style: .default) { [weak self] (alertAction) in
				self?.close()
			}
			alert.addAction(ok)
			self?.present(alert, animated: true, completion: nil)
		}
    }

    /**
    Trigger new controller where user choose start of meeting
    */
    func setStartDate(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "EventDateViewController") as? EventDateViewController else { return }
            vc.writeStartDateBackDelegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /**
    Trigger new controller where user choose end of meeting
    */
    func setEndDate(_ sender: UITapGestureRecognizer) {
        if lblStartDate.text != "Start" {
            if sender.state == .ended {
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "EventDateViewController") as? EventDateViewController else { return }
                vc.writeEndDateBackDelegate = self
                vc.date = startDate ?? Date()
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            show(message: "event.create.validation.setStartFirst".localized)
        }
    }

    /**
    Move keyboard for text view below the text itself
    */
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!

        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + 10, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset

        let rangeOfName = tvEventName.selectedRange
        tvEventName.scrollRangeToVisible(rangeOfName)
        let rangeOfDescription = tvDescription.selectedRange
        tvDescription.scrollRangeToVisible(rangeOfDescription)
        let rangeOfEquipmentAttendees = tvEquipmentAttendees.selectedRange
        tvEquipmentAttendees.scrollRangeToVisible(rangeOfEquipmentAttendees)
        let rangeOfEquipmentWe = tvEquipmentWe.selectedRange
        tvEquipmentWe.scrollRangeToVisible(rangeOfEquipmentWe)
        let rangeOfPhone = tvPhone.selectedRange
        tvPhone.scrollRangeToVisible(rangeOfPhone)
    }

    /**
    Save the text entered by user to text view
    */
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 0:
            name = textView.text
        case 1:
            descript = textView.text
        case 2:
            bring = textView.text
        case 3:
            have = textView.text
        case 4:
            phone = textView.text
        default:
            break
        }
		textView.adjustSize()
    }

    /**
    When user starts edit text view, delete placeholder
    */
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "event.name".localized || textView.text == "event.description.hint".localized || textView.text == "event.whatBringFull".localized || textView.text == "event.whatWeHaveFull".localized || textView.text == "global.email".localized || textView.text == "global.phone".localized {
            textView.text = nil
        }
		textView.adjustSize()
    }

    /**
    When user ends edit text view, put placeholder back
    */
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            switch textView {
            case tvEventName:
                textView.text = "event.name".localized
            case tvDescription:
                textView.text = "event.description.hint".localized
            case tvEquipmentAttendees:
                textView.text = "event.whatBringFull".localized
            case tvEquipmentWe:
                textView.text = "event.whatWeHaveFull".localized
            case tvEmail:
                textView.text = "global.email".localized
            case tvPhone:
                textView.text = "global.phone".localized
            default:
                break
            }
        }
        textView.removeRequiredHighlightTextField()
		textView.adjustSize()
    }

    /**
    Hides keyboard when user touches Done button
    */
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }

    /**
    Add Done button to phone pad
    */
    func addDoneButtonToPhonePad() {
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()

        let flexibleItem = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(phonePadDoneButton))

        toolbarDone.items = [flexibleItem, barBtnDone]
        tvPhone.inputAccessoryView = toolbarDone
    }

    /**
    Hides phone pad when user touches Done button
    */
    func phonePadDoneButton() {
        tvPhone.resignFirstResponder()
    }

    @IBAction func setLocationOnMap(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "EventLocationViewController") as? EventLocationViewController else { return }
        vc.WriteCityAndStreetBackDelegate = self
        vc.WriteLocatonBackDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func selectDumpsOnMap(_ sender: Any) {
        if savedLocation != nil {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "EventDumpsViewController") as? EventDumpsViewController else { return }
            vc.coords = savedLocation
            vc.WriteNumberOfSelectedDumbsBackDelegate = self
            vc.trashIds = trashIds
            vc.numberOfSelectedDumps = numberOfDumps

            navigationController?.pushViewController(vc, animated: true)
        } else {
            show(message: "event.create.validation.setMeetingPointFirst".localized)
        }
    }

}

extension EventNewViewController: WriteCityAndStreetBack {

    /**
    Set the most accurate address of chosen meeting point
    */
    func writeCityAndStreetBack(value: String) {
        locationOnMapView.isHidden = false
        lblAddress.text = value
    }

}

extension EventNewViewController: WriteLocationBack {

    /**
    Save location of meeting point
    */
    func writeLocationBack(value: CLLocationCoordinate2D) {
        savedLocation = value

        var source = ""
        if Reachability.isConnectedToCellularNetwork() {
            source = "network"
        } else if Reachability.isConnectedToNetwork() {
            source = "wifi"
        } else {
            source = "gps"
        }

        let accuracy = Int(LocationManager.manager.currentLocation.horizontalAccuracy)
        gps = Coordinates.init(lat: value.latitude, long: value.longitude, accuracy: accuracy, source: source)

        self.lblMeetingPoint.removeRequiredHighlightTextField()
		lblGPS.text = GpsFormatter.instance.string(fromLat: value.latitude, lng: value.longitude)
        //lblGPS.text = "\(String(format:"%.6f", value.latitude)), \(String(format:"%.6f", value.longitude))"
    }

}

extension EventNewViewController: WriteStartDateBack {

    /**
    Set start of meeting
    */
    func writeStartDateBack(value: String, date: Date?) {
        lblStartDate.text = value
        startDate = date
        self.lblStartDate.removeRequiredHighlightTextField()

        // Convert date to required string
        let dateFormatter = DateFormatter.utc
        start = dateFormatter.string(from: date!)
    }

}

extension EventNewViewController: WriteEndDateBack {

    /**
    Set end of meeting
    */
    func writeEndDateBack(value: String, date: Date?) {
        lblEndDate.text = value
        endDate = date
        self.lblEndDate.removeRequiredHighlightTextField()
    }

}

extension EventNewViewController: WriteNumberOfSelectedDumpsBack {

    /**
    Set how many dumsp are about to be cleaned
    */
    func writeNumberOfSelectedDumpsBack(value: String, selectedDumps: [Int]?, numberOfSelectedDumps: Int?) {
        lblSelectedDumps.text = value
        trashIds = selectedDumps!
        numberOfDumps = numberOfSelectedDumps!
    }

}

class Contact: NSObject {
    var email: String
    var phone: String

    init(email: String, phone: String) {
        self.email = email
        self.phone = phone
    }
}


extension UITextView {

	func adjustSize() {
		let size = self.sizeThatFits(CGSize.init(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
		let height: CGFloat = max(36.5, size.height)
		guard height != self.constraint(for: .height)?.constant else { return }
		self.constraint(for: .height)?.constant = height
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}
}
