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
import MapKit
import CoreLocation
import EventKit

class EventDetailViewController: ViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {

    @IBOutlet var map: MKMapView!

    @IBOutlet var dumpsToBeCleanedView: UIView! {
        didSet {
            dumpsToBeCleanedView.isHidden = true
        }
    }

    @IBOutlet var tvDumpsToClean: UITableView!

    @IBOutlet var lblEventName: UILabel!
    @IBOutlet var lblEventDateAndTime: UILabel!
    @IBOutlet var lblEventInfo: UILabel!
    @IBOutlet var lblMeetingPoint: UILabel!
    @IBOutlet var lblWeHave: UILabel!
    @IBOutlet var lblGlovesBags: UILabel!
    @IBOutlet var lblPleaseBring: UILabel!
    @IBOutlet var lblShovelGoodMood: UILabel!
    @IBOutlet var lblListOfDumps: UILabel!

    @IBOutlet var btnJoin: UIButton!
    @IBOutlet var btnDirections: UIButton!

    @IBOutlet var tvCoordinates: UITextView!
    @IBOutlet var tvAddress: UITextView!
    
    @IBOutlet var cnListOfDumpsTableView: NSLayoutConstraint!
    
    @IBOutlet weak var svContact: UIStackView?
    
    @IBOutlet weak var emailView: UIView?
    @IBOutlet weak var ivEmail: UIImageView?
    @IBOutlet weak var lEmailTitle: UILabel?
    @IBOutlet weak var lEmailValue: UILabel?
    
    @IBOutlet weak var phoneView: UIView?
    @IBOutlet weak var ivPhone: UIImageView?
    @IBOutlet weak var lPhoneTitle: UILabel?
    @IBOutlet weak var lPhoneValue: UILabel?
    
    @IBOutlet weak var vWeHave: UIView?
    @IBOutlet weak var vWeNeed: UIView?
    
    var showJoinButton: Bool = false
    var id: Int!
    //var reportTime: String!
	let eventsManager = EventManager()

    var event: Event? {
        didSet {
            setEventInfoView()
            setLocationView()
            setWeHaveView()
            setPleaseBringView()
            setupPhoneView(phoneNumber: event?.contact?.phone)
            setupEmailView(email: event?.contact?.email)
            
            if event?.trash != nil {
                dumpsToBeCleanedView.isHidden = false
                tvDumpsToClean.reloadData()
            }
        }
    }

    deinit {
        unregisterFromNotifcations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "event.header".localized

//        let backButton = UIBarButtonItem(title: "global.done".localized, style: .plain, target: self, action: #selector(goBack))
//        navigationItem.rightBarButtonItem = backButton

        lblEventDateAndTime.textColor = Theme.current.color.lightGray
        lblMeetingPoint.text = "event.meetingPoint".localized
        lblWeHave.text = "event.whatWeHave".localized
        lblWeHave.textColor = Theme.current.color.green
        lblPleaseBring.text = "event.detail.pleaseBring".localized
        lblPleaseBring.textColor = Theme.current.color.green
        lblListOfDumps.text = "event.listOfDumpsToBeCleaned".localized
        lblListOfDumps.textColor = Theme.current.color.green

        btnJoin.setTitle("event.join".localized.uppercased(with: .current), for: .normal)
        btnJoin.theme()
        btnJoin.isHidden = !showJoinButton
        btnDirections.setTitle("global.direction".localized.uppercased(with: .current), for: .normal)
        btnDirections.theme()

        tvCoordinates.textColor = Theme.current.color.lightGray

        // remove ios default insets of content
        tvCoordinates.contentInset = .zero
        tvCoordinates.layoutMargins = .zero
        tvCoordinates.textContainer.lineFragmentPadding = 0
        tvCoordinates.textContainerInset = .zero

		tvDumpsToClean.tableFooterView = UIView()
        
        loadData()
        registerForNotifcations()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tvCoordinates.textContainer.lineFragmentPadding = 0
        tvCoordinates.textContainerInset = .zero
        
        tvAddress.textContainer.lineFragmentPadding = 0
        tvAddress.textContainerInset = .zero
    }
    
    
    // MARK: - Networking

    fileprivate func loadData() {
        Networking.instance.event(id) { [weak self] (event, error) in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                self?.showInfo(message: "Can not load event data, please try it again later")
                return
            }
            guard let newEvent = event else { return }
            self?.event = newEvent
        }
    }

    /**
    Go back to dumps detial
    */
    func goBack() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    /**
    Set event info view
    */
    fileprivate func setEventInfoView() {
        if let name = event?.name {
            lblEventName.text = name
        }

        if let startDate = event?.start, let duration = event?.duration {
            let formatter = DateFormatter.utc
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let stringFromDate = formatter.string(from: startDate)
            let formattedString = stringFromDate.replacingOccurrences(of: "/", with: ". ")

            if duration / 60 > 0 {
                lblEventDateAndTime.text = "\(formattedString), \(duration / 60) \("event.hours".localized)"
            } else {
                lblEventDateAndTime.text = "\(formattedString), \(duration) \("global.minutes".localized)"
            }
        }

        if let description = event?.description {
            lblEventInfo.text = description
        }
        
        // Join btn.
        if event != nil {
            eventsManager.joinButtonTest(event!) { [weak self] (show) in
                DispatchQueue.main.async {
                    if show {
                        self?.btnJoin.isHidden = false
                    } else {
                        self?.btnJoin.isHidden = true
                    }
                }
            }
        }
    }

    /**
    Set location view
    */
    fileprivate func setLocationView() {
        guard let gps = event?.gps else { return }

        // Address and coordinates labels
        let coords = CLLocationCoordinate2DMake(gps.lat, gps.long)
        showEventOnMap(coords: coords)
        setAddress(gps: gps, textView: tvAddress)
        tvCoordinates.text = GpsFormatter.instance.string(fromLat: gps.lat, lng: gps.long)
    }

    /**
    Show trash on map with specific region
    */
    fileprivate func showEventOnMap(coords: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coords

        map.addAnnotation(annotation)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion.init(center: coords, span: span)
        map.setRegion(region, animated: true)
    }

    fileprivate func setWeHaveView() {
        guard let text = event?.have?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            vWeHave?.removeFromSuperview()
            return
        }
        lblGlovesBags.text = text
    }

    fileprivate func setPleaseBringView() {
        guard let text = event?.bring?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            vWeNeed?.removeFromSuperview()
            return
        }
        lblShovelGoodMood.text = text
    }

    @IBAction func joinEvent(_ sender: Any) {
        guard let event = self.event else { return }
		eventsManager.joinEvent(event, controller: self) { [weak self, weak event] (error) in
            DispatchQueue.main.async {
                if let error = error {
                    let nsError = error as NSError
                    if nsError.code == 300 {
                        self?.showWithSettings(message: nsError.localizedDescription)
                    } else {
                        self?.showInfo(message: nsError.localizedDescription)
                    }
                    event?.showJoinButton = true
                } else {
                    event?.showJoinButton = false
                }
            }
		}
    }

    
    /// Setup e-mail view.
    ///
    /// - Parameter email: E-mail string.
    
    fileprivate func setupEmailView(email: String?) {
        if let view = self.emailView {
            self.svContact?.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if let email = email {
            if let emailView = self.emailView {
                svContact?.addArrangedSubview(emailView)
                setupContactView(image: #imageLiteral(resourceName: "EventEmail"), title: "global.email".localized, value: email, imageView: ivEmail, titleLabel: lEmailTitle, valueLabel: lEmailValue)
            }
        }
    }
    
    
    /// Setup number view.
    ///
    /// - Parameter phoneNumber: Phone number.
    
    fileprivate func setupPhoneView(phoneNumber: String?) {
        if let view = self.phoneView {
            self.svContact?.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if let phoneNumber = phoneNumber {
            if let phoneView = self.phoneView {
                svContact?.addArrangedSubview(phoneView)
                setupContactView(image: #imageLiteral(resourceName: "EventPhone"), title: "global.phone".localized, value: phoneNumber, imageView: ivPhone, titleLabel: lPhoneTitle, valueLabel: lPhoneValue)
            }
        }
    }
    
    
    /// Common setup for contact view.
    ///
    /// - Parameters:
    ///   - image: Image.
    ///   - title: Title text.
    ///   - value: Value text.
    ///   - imageView: Image view.
    ///   - titleLabel: Title label.
    ///   - valueLabel: Value labe.
    
    fileprivate func setupContactView(image: UIImage?, title: String?, value: String?, imageView: UIImageView?, titleLabel: UILabel?, valueLabel: UILabel?) {
        
        // Setup image view
        imageView?.image = imageView?.image?.withRenderingMode(.alwaysTemplate)
        imageView?.tintColor = Theme.Color().green
        imageView?.image = image
        
        // Setup title label
        titleLabel?.text = title
        
        // Setup value label
        valueLabel?.text = value
    }
    
    /**
    Add cleaning event to calendar
    */
	/*
    fileprivate func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event, completion: { [weak self] (granted, error) in
            if granted && error == nil {
                let event = EKEvent(eventStore: eventStore)
                event.title = title.localized
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description?.localized
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    self?.showInfo(message: "event.validation.cannotBeAddedToCalendar".localized)
                    completion?(false, e)
                    return
                }
                self?.showInfo(message: "event.addedToCalender.success".localized)
                completion?(true, nil)
            } else {
                self?.showWithSettings(message: "global.enableAccessToCalendar".localized)
                completion?(false, error as NSError?)
            }
        })
    }
*/

    @IBAction func goToNavigation(_ sender: UIButton) {
        guard let gps = event?.gps else { return }

        let coords = CLLocationCoordinate2D(latitude: gps.lat, longitude: gps.long)
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coords, addressDictionary: nil))
        item.name = "event.header".localized
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    // MARK: - Annotation view

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationReuseId = "Event"

        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationReuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationReuseId)
        } else {
            anView?.annotation = annotation
        }

        anView?.image = #imageLiteral(resourceName: "Cleaned")
        anView?.frame.size = CGSize(width: 40.0, height: 40.0)
        anView?.layer.cornerRadius = 0.5 * (anView?.bounds.height)!
        anView?.clipsToBounds = true

        return anView
    }

    // MARK: - Table view Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let trashCount = event?.trash.count {
            if event?.trash.last?.id != nil {
                return trashCount
            }
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DumpsToCleanCell", for: indexPath) as? DumpsToCleanCell else { fatalError("Could not dequeue cell with identifier: DumpsToCleanCell") }

        cnListOfDumpsTableView.constant = tableView.contentSize.height

        guard let trash = event?.trash[indexPath.row] else { return cell }

        // Dumps photo
        if let image = trash.images.first?.optimizedDownloadUrl {
            cell.ivPhoto.remoteImage(id: image)
        }

        // Status image
        cell.ivStatus.image = #imageLiteral(resourceName: "Reported")

        // GPS
        if let gps = trash.gps {
            cell.lblGPS.text = "\(gps.lat), \(gps.long)"
        }

        // Types of trash
        var allTypes = [String]()
        if trash.types.count > 0 {
            for i in 0...trash.types.count - 1 {
                allTypes.append(trash.types[i].rawValue)
            }
        }
        cell.lblType.text = allTypes.joined(separator: ", ").uppercaseFirst

        // Time interval from report
		if let time = trash.created {
        	cell.lblTime.text = DateRounding.shared.localizedString(for: time)
		}

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let trashId = event?.trash[indexPath.row].id,
            let vc = UIStoryboard(name: "Dumps", bundle: .main).instantiateViewController(withIdentifier: "DumpsDetailViewController") as? DumpsDetailViewController else {
                return
        }
        vc.id = trashId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Notifications handling
    
    func registerForNotifcations() {
        NotificationCenter.default.addObserver(self, selector: #selector(catchNotification(notification:)), name: .userJoindedEvent, object: nil)
    }
    
    @objc func catchNotification(notification:Notification) -> Void {
        self.loadData()
    }
    
    func unregisterFromNotifcations() {
        NotificationCenter.default.removeObserver(self, name: .userJoindedEvent, object: nil)
    }

}

class DumpsToCleanCell: UITableViewCell {

    @IBOutlet var ivPhoto: UIImageView!
    @IBOutlet var ivStatus: UIImageView!
    @IBOutlet var lblGPS: UILabel!
    @IBOutlet var lblType: UILabel!
    @IBOutlet var lblTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        lblGPS.textColor = Theme.current.color.lightGray
        lblTime.textColor = Theme.current.color.lightGray
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ivPhoto.cancelRemoteImageRequest()
        ivStatus.backgroundColor = .none
        lblGPS.text = ""
        lblType.text = ""
        lblTime.text = ""
    }

}
