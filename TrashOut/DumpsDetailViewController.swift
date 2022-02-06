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
import MessageUI
import EventKit

class DumpsDetailViewController: ViewController {

    let eventManager = EventManager()

    // MARK: - Outlets

    @IBOutlet var map: MKMapView!

    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var additionalInformationView: UIView!
    @IBOutlet var noCleaningEventView: UIView!
    @IBOutlet var cleaningEventView: UIView! {
        didSet {
            cleaningEventView.isHidden = true
        }
    }

    @IBOutlet var vDescSeparator: [UIView]!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tvHistory: UITableView!
    @IBOutlet var tvCleaningEvents: UITableView!
    @IBOutlet var cvTypeOfTrash: UICollectionView!

    @IBOutlet var lblCurrentStatus: UILabel!
    @IBOutlet var lblCurrentStatusDate: UILabel!
    @IBOutlet var lblNumberOfPhotos: UILabel!
    @IBOutlet var lblUpdateThisDumpsite: UILabel!
    @IBOutlet var lblUpdateThisDumpsiteInfo: UILabel!
    @IBOutlet var lblHistory: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblDistance: UILabel!
    
    @IBOutlet var lblAccuracy: UILabel!
    @IBOutlet var lblSizeAndType: UILabel!
    @IBOutlet var lblSizeOfTrash: UILabel!
    @IBOutlet var lblAccessibility: UILabel!
    @IBOutlet var lblAccessibilityInfo: UILabel!
    @IBOutlet var lblAdditionalInformation: UILabel!
    @IBOutlet var lblAdditionalInformationInfo: UILabel!
    @IBOutlet var lblCleaningEvent: [UILabel]!
    @IBOutlet var lblCleaningEventInfo: UILabel!
    @IBOutlet var lblReportToMunicipality: UILabel!
    @IBOutlet var lblDumpId: UILabel!
    @IBOutlet var lblReportToMunicipalityInfo: UILabel!
    @IBOutlet var lblSpam: UILabel!
    @IBOutlet var lblSpamInfo: UILabel!

    @IBOutlet var btnCleaned: UIButton!
    @IBOutlet var btnStillThere: UIButton!
    @IBOutlet var btnDirections: UIButton!
    @IBOutlet var btnsCreateAnEvent: [UIButton]!
    @IBOutlet var btnSendNotification: UIButton!
    @IBOutlet var btnReportAsSpam: UIButton!

    @IBOutlet var tvCoordinates: UITextView!
    @IBOutlet var tvRemainAddress: UITextView!
    
    @IBOutlet var ivMainPhoto: UIImageView!
    @IBOutlet var ivCurrentStatusImage: UIImageView!
    @IBOutlet var ivSizeOfTrash: UIImageView!

    @IBOutlet var cnHistoryTableView: NSLayoutConstraint!
    @IBOutlet var cnInformationCollectionView: NSLayoutConstraint!
    @IBOutlet var cnInformationSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var cnInformationSeparatorHeight2: NSLayoutConstraint!
    @IBOutlet var cnCleaningEventsTableView: NSLayoutConstraint!

    // MARK: - Variables

    private var trash: Trash? {
        didSet {
            updateMainPhotoAndStatusOfTrash()
            updateLocationView()
            updateInformationView()
            updateAdditionalyInformationView()
            tvHistory.reloadData()
			cnHistoryTableView.constant = tvHistory.contentSize.height - 1/UIScreen.main.scale
            cvTypeOfTrash.reloadData()
            updateEventView()
            loadingView.isHidden = true
            activityIndicator.stopAnimating()
        }
    }

    var id: Int?

    fileprivate var photos = [String]()
    fileprivate var storedOffsets = [Int: CGFloat]()
    fileprivate var rowCount: Int?
    
    deinit {
        unregisterFromNotifcations()
    }

}

// MARK: - Lifecycle

extension DumpsDetailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupRefreshControl()

        registerForNotifcations()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tvCoordinates.textContainer.lineFragmentPadding = 0
        tvCoordinates.textContainerInset = .zero

        tvRemainAddress.textContainer.lineFragmentPadding = 0
        tvRemainAddress.textContainerInset = .zero
    }

}

// MARK: - IBActions

extension DumpsDetailViewController {

    @IBAction func itsCleanedTouched(_ sender: AnyObject) {
        guard let trash = trash else { return }
        let storyboard = UIStoryboard.init(name: "Report", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ReportCameraViewController") as? ReportCameraViewController else { return }
        let navController = UINavigationController(rootViewController: vc)
        vc.trash = trash
        vc.cleaned = true
        present(navController, animated: true, completion: nil)
    }

    @IBAction func stillHereTouched(_ sender: Any) {
        guard let trash = trash else { return }
        let storyboard = UIStoryboard.init(name: "Report", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ReportCameraViewController") as? ReportCameraViewController else { return }
        let navController = UINavigationController(rootViewController: vc)
        vc.trash = trash
        vc.cleaned = false
        present(navController, animated: true, completion: nil)
    }

    @IBAction func goToNavigation(_ sender: UIButton) {
        guard let gps = trash?.gps else { return }

        let coords = CLLocationCoordinate2D(latitude: gps.lat, longitude: gps.long)
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coords, addressDictionary: nil))
        item.name = "Illegal dump".localized
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    @IBAction func createAnEvent(_ sender: Any) {
        if UserManager.instance.isLoggedIn == true {
            guard let trash = trash else { return }
            let storyboard = UIStoryboard.init(name: "Event", bundle: Bundle.main)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "EventNewViewController") as? EventNewViewController else { return }
            vc.onEventCreated = { [weak self] in
                self?.reloadData()
            }
            vc.trashId = trash.id
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        } else {
            show(message: "event.create.loginMessage".localized,  okActionTitle: "global.login".localized ,okAction: { [unowned self] (alertAction) in
                guard let tabs = self.navigationController?.parent as? TabbarViewController else { return }
                tabs.openProfile { (profileVC) in
                    guard let profileVC = profileVC as? ProfileViewController else { return }
                    profileVC.openActivityList()
                }
            })
        }
    }

    @IBAction func sendNotification(_ sender: Any) {
        guard let trash = trash else { return }
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            let s = String(format: "trash.illegalDumpIn_X".localized, (tvRemainAddress.text ?? ""))
            controller.setSubject(s)
            let b = String(format: "trash.reportedDetailsonWeb_X".localized, trash.sharingUrl)
            controller.setMessageBody(b, isHTML: false)
            controller.mailComposeDelegate = self
            controller.navigationBar.tintColor = UIColor.white
            present(controller, animated: true, completion: nil)
        } else {
            show(message: "global.sendEmail.error".localized)
        }
    }

    @IBAction func reportAsSpam(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "trash.edit.spamText".localized, preferredStyle: .alert)
        let yes = UIAlertAction.init(title: "global.yes".localized, style: .default) { [weak self] (alertAction) in
            Networking.instance.reportSpam((self?.trash?.activityId)!, userId: (UserManager.instance.user?.id)!) { [weak self] (trash, error) in
                guard error == nil else {
                    print(error?.localizedDescription as Any)
                    self?.show(message: (error?.localizedDescription)!)
                    return
                }
                self?.show(message: "trash.messageWasReceived".localized)
            }
        }
        let ok = UIAlertAction.init(title: "global.cancel".localized, style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func openPhotos() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DumpsImageViewController") as? DumpsImageViewController else { return }
        vc.trash = trash
        vc.data = TrashUpdateGalleryData(updates: trash?.updates ?? [])
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - Collection View Datasource, Deleage, Flowlayout

extension DumpsDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let trash = trash else {return 0}
        if collectionView == cvTypeOfTrash {
            let types = trash.types
            return types.count
        } else {
            let index = collectionView.tag

            let update = trash.updates[index]
            return update.images.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvTypeOfTrash {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeCell", for: indexPath) as? TrashTypeCollectionViewCell else { fatalError("Could not dequeue cell with identifier: TypeCell") }

            cnInformationCollectionView.constant = collectionView.contentSize.height
            guard let types = trash?.types else { return cell }
            setTypesOfTrash(trash: types, cell: cell, path: indexPath as NSIndexPath)

            return cell

        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryPhotoCell", for: indexPath) as? HistoryPhotoCollectionViewCell else { fatalError("Could not dequeue cell with identifier: HistoryPhotoCell") }
            guard let trash = trash else { return cell }
            let update = trash.updates[collectionView.tag]
            let image = update.images[indexPath.item]
            guard let imageUrl = image.fullDownloadUrl else { return cell }
            cell.ivPhoto.remoteImage(id: imageUrl, placeholder: #imageLiteral(resourceName: "No image square"), animate: true)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === cvTypeOfTrash {
            let height: CGFloat = 80
            let width: CGFloat = collectionView.bounds.size.width/2 - 10
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 80, height: 80)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let trash = self.trash else { return }
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "DumpsImageViewController") as? DumpsImageViewController else { return }
        vc.trash = trash
        vc.currentIndex = indexPath.item
        vc.data = TrashUpdateGalleryData(updates: [trash.updates[collectionView.tag]])
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - Table View DataSource, Delegate

extension DumpsDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tvHistory {
            return trash?.updates.count ?? 0
        }

        // Events table view
        if let eventsCount = trash?.events.count {
            if trash?.events.last?.name != nil {
                return eventsCount
            }
        }

        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tvHistory {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell else { fatalError("Could not dequeue cell with identifier: HistoryCell") }
            guard let trash = trash else { return cell }
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)

            //cnHistoryTableView.constant = tableView.contentSize.height
            setHistoryCell(trash: trash, cell: cell, index: indexPath.row)

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CleaningEventCell", for: indexPath) as? CleaningEventTableViewCell else { fatalError("Could not dequeue cell with identifier: CleaningEventCell") }

            cnCleaningEventsTableView.constant = tableView.contentSize.height

            guard let event = trash?.events[indexPath.row] else { return cell }

            cell.lblHelpUsToCleanIt.text = event.name

            if let image = event.images.first {
                guard let imageUrl = image.optimizedDownloadUrl else { return cell }
                cell.imageView?.remoteImage(id: imageUrl, placeholder: #imageLiteral(resourceName: "CalendarWhite"), animate: true)
            }

            // Set event date
            if let startDate = event.start {
                let formatter = DateFormatter.utc
                formatter.dateStyle = .short
                let stringFromDate = formatter.string(from: startDate)
                let formattedString = stringFromDate.replacingOccurrences(of: "/", with: ". ")

                cell.lblEventDate.text = formattedString
            } else {
                cell.lblEventDate.text = "global.noDate".localized
            }

            // Join btn

            // Set default value for "Join" button
            cell.btnJoin.setTitle("event.join".localized.uppercased(with: .current), for: .normal)

            eventManager.joinButtonTest(event) { [weak self] (show) in
                DispatchQueue.main.async {
                    if show {

                        // Save the date
                        cell.btnJoin.isHidden = false
                        cell.leadingSpaceToJoinBtn.isActive = true
                        cell.leadingSpaceToContainer.isActive = false
                        cell.btnJoin.tag = indexPath.row
                        cell.btnJoin.setTitle("event.join".localized.uppercased(with: .current), for: .normal)
                        cell.btnJoin.theme()
                        cell.btnJoin.addTarget(self, action: #selector(self?.joinEvent), for: .touchUpInside)
                    } else {
                        cell.btnJoin.isHidden = true
                        cell.leadingSpaceToJoinBtn.isActive = false
                        cell.leadingSpaceToContainer.isActive = true
                    }
                }
            }

            // Go to detail
            cell.btnDetail.tag = indexPath.row
            cell.btnDetail.setTitle("global.detail".localized.uppercased(with: .current), for: .normal)
            cell.btnDetail.theme()
            cell.btnDetail.addTarget(self, action: #selector(goToEventDetail), for: .touchUpInside)
            cell.needsUpdateConstraints()

            return cell
        }
    }

}

// MARK: - MKMap View Delegate

extension DumpsDetailViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationReuseId = "Trash"

        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationReuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationReuseId)
        } else {
            anView?.annotation = annotation
        }
        setAnnotationView(view: anView)
        return anView
    }

}

// MARK: - Private

extension DumpsDetailViewController {

    func registerForNotifcations() {
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionUserJoinedEvent), name: .userJoindedEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionUserUpdatedTrash), name: .userUpdatedTrash, object: nil)
    }

    private func unregisterFromNotifcations() {
        NotificationCenter.default.removeObserver(self, name: .userJoindedEvent, object: nil)
        NotificationCenter.default.removeObserver(self, name: .userUpdatedTrash, object: nil)
    }

    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        contentScrollView.refreshControl = refreshControl
    }

    private func setupView() {
        title = "trash.detail.dump.mobileHeader".localized

        if let trashId = id {
            analyticsData = ["trash_id": trashId as NSObject]
        }

        self.lblDumpId.isHidden = id == nil
        self.lblDumpId.text = "ID: \(id ?? 0)"

        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareDump))
        navigationItem.rightBarButtonItem = share

        cnInformationSeparatorHeight.preciseConstant = 1
        cnInformationSeparatorHeight2.preciseConstant = 1

        lblDumpId.textColor = Theme.current.color.lightGray
        lblCurrentStatusDate.textColor = Theme.current.color.lightGray
        lblUpdateThisDumpsite.text = "trash.message.updateThisTrash".localized
        lblUpdateThisDumpsiteInfo.text = "trash.create.TakeSomePictures".localized
        lblUpdateThisDumpsiteInfo.textColor = Theme.current.color.lightGray
        lblHistory.text = "trash.history".localized
        lblHistory.textColor = Theme.current.color.green
        lblSizeAndType.text = "global.information".localized
        lblSizeAndType.textColor = Theme.current.color.green
        lblAccessibility.text = "trash.accessibility".localized
        lblAccessibilityInfo.textColor = Theme.current.color.lightGray
        lblLocation.text = "trash.gpsLocation".localized
        lblLocation.textColor = Theme.current.color.green
        lblAdditionalInformation.text = "trash.note".localized
        lblAdditionalInformation.textColor = Theme.current.color.green
        for label in lblCleaningEvent {
            label.text = "event.header".localized
            label.textColor = Theme.current.color.green
        }
        lblCleaningEventInfo.text = "trash.detail.noCleaningEvent".localized
        lblCleaningEventInfo.textColor = Theme.current.color.lightGray
        lblReportToMunicipality.text = "trash.detail.reportToMunicipality".localized
        lblReportToMunicipality.textColor = Theme.current.color.green
        lblReportToMunicipalityInfo.text = "trash.detail.municipalityText".localized
        lblReportToMunicipalityInfo.textColor = Theme.current.color.lightGray
        lblSpam.text = "trash.detail.spam".localized
        lblSpam.textColor = Theme.current.color.green
        lblSpamInfo.text = "trash.detail.spamText".localized
        lblSpamInfo.textColor = Theme.current.color.lightGray

        btnCleaned.setTitle("trash.status.cleaned".localized.uppercased(with: .current), for: .normal)
        btnCleaned.theme()
        btnStillThere.setTitle("trash.status.stillHere".localized.uppercased(with: .current), for: .normal)
        btnStillThere.theme()
        btnStillThere.backgroundColor = Theme.current.color.red
        btnDirections.setTitle("global.direction".localized.uppercased(with: .current), for: .normal)
        btnDirections.theme()
        for button in btnsCreateAnEvent {
            button.setTitle("event.create.header".localized.uppercased(with: .current), for: .normal)
            button.theme()
        }
        btnSendNotification.setTitle("trash.detail.sendNotification".localized.uppercased(with: .current), for: .normal)
        btnSendNotification.theme()
        btnReportAsSpam.setTitle("global.reportSpam".localized.uppercased(with: .current), for: .normal)
        btnReportAsSpam.theme()
        btnReportAsSpam.backgroundColor = Theme.current.color.red

        tvCoordinates.textColor = Theme.current.color.lightGray

        for separator in vDescSeparator {
            separator.backgroundColor = UIColor.theme.separatorLine
        }

        // Making main photo touchable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showBigPhoto(_:)))
        tapGesture.numberOfTapsRequired = 1
        ivMainPhoto.isUserInteractionEnabled = true
        ivMainPhoto.addGestureRecognizer(tapGesture)
        ivMainPhoto.clipsToBounds = true

        tvHistory.tableFooterView = UIView()
        tvCleaningEvents.tableFooterView = UIView()
    }

    // Networking

    private func reloadData(isLoadingViewActive: Bool = true, completion: VoidClosure? = nil) {
        if isLoadingViewActive {
            LoadingView.show(on: self.view, style: .white)
        }

        Networking.instance.trash(id!) { [weak self] (trash, error) in
            if let error = error {
                print(error.localizedDescription as Any)

                if case NetworkingError.noInternetConnection = error {
                    self?.show(message: "global.internet.error.offline".localized) {
                        _ = self?.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self?.show(message: "global.fetchError".localized) {
                        _ = self?.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                LoadingView.hide()
                guard let newTrash = trash else { return }
                self?.trash = newTrash
            }

            completion?()
        }
    }

    /**
    Update First part of UI
    */
    private func updateMainPhotoAndStatusOfTrash() {
        guard let trash = trash else {return}
        // Main photo and number of photos
        if let images = trash.images.first?.fullDownloadUrl {
            ivMainPhoto.remoteImage(id: images, placeholder: #imageLiteral(resourceName: "No image wide"), animate: true)
            let count = trash.updates
                .map{ $0.images }
                .reduce([],+)
                .count

            lblNumberOfPhotos.text = String(count)
        } else {
            if trash.updates.last?.user?.id != nil {
                if let updatedImages = trash.updates.first?.images.last?.fullDownloadUrl {
                    ivMainPhoto.remoteImage(id: updatedImages, placeholder: #imageLiteral(resourceName: "No image wide"), animate: true)
                    if let count = trash.updates.first?.images.count {
                        lblNumberOfPhotos.text = String(count)
                    }
                }
            } else {
                ivMainPhoto.image = #imageLiteral(resourceName: "No image wide")
            }
        }

        let status = Trash.DetailStatus.getStatus(in: trash)
        ivCurrentStatusImage.image = status.image
        lblCurrentStatus.text = status.localizedName.uppercased(with: Locale.current)

        if let ut = trash.updateTime {
            lblCurrentStatusDate.text = DateRounding.shared.localizedString(for: ut).uppercaseFirst
        } else {
            lblCurrentStatusDate.text = "global.unknow".localized
        }
        lblCurrentStatusDate.adjustsFontSizeToFitWidth = true
    }

    /**
    Update Location part of UI
    */
    private func updateLocationView() {
        if let gps = trash?.gps {

            // Address and coordinates labels
            let coords = CLLocationCoordinate2DMake(gps.lat, gps.long)
            showTrashOnMap(coords: coords)

            setAddressOfTrash()

            tvCoordinates.text = GpsFormatter.instance.string(from: gps) //"\(gps.lat), \(gps.long)"

            // Dumps distance from user
            let trashLocation = CLLocation.init(latitude: (gps.lat), longitude: (gps.long))
            let distance = LocationManager.manager.currentLocation.distance(from: trashLocation)
            let distanceInM = Int(round(distance))

            lblDistance.text = DistanceRounding.shared.localizedDistance(meteres: distanceInM)
            lblDistance.adjustsFontSizeToFitWidth = true

            // Accuracy label
            lblAccuracy.text = "trash.accuracyOfLocationSmaller".localized + String(describing: (trash?.gps?.accuracy)!) + " m"
        }
    }

    /**
    Show trash on map with specific region
    */
    private func showTrashOnMap(coords: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coords

        map.addAnnotation(annotation)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion.init(center: coords, span: span)
        map.setRegion(region, animated: true)
    }

    /**
    Set the most accurate address of trash
    */
    private func setAddressOfTrash() {
        guard let gps = trash?.gps else { return }
        setAddress(gps: gps, textView: tvRemainAddress)
    }

    /**
    Update Information part of UI
    */
    private func updateInformationView() {
        // Size image and text
        if let size = trash?.size {
            setSizeImageOfTrash(size: size)
        }

        // Accessibility
        let byCar = setAccessibility(defaultValue: trash?.accessibility?.byCar, text: "trash.accessibility.byCar".localized)
        let inCave = setAccessibility(defaultValue: trash?.accessibility?.inCave, text: "trash.accessibility.inCave".localized)
        let underWater = setAccessibility(defaultValue: trash?.accessibility?.underWater, text: "trash.accessibility.underWater".localized)
        let notForGeneralCleanup = setAccessibility(defaultValue: trash?.accessibility?.notForGeneralCleanup, text: "trash.accessibility.notForGeneralCleanup".localized)

        let array = [byCar, inCave, underWater, notForGeneralCleanup]
        let arrayWithText = array.filter { $0 != "" }
        let accessibilityTextWithSeparators = arrayWithText.joined(separator: ", ")
        lblAccessibilityInfo.text = accessibilityTextWithSeparators.uppercaseFirst
        lblAccessibilityInfo.adjustsFontSizeToFitWidth = true
    }

    /**
    Set dumps accessibility
    */
    private func setAccessibility(defaultValue: Bool?, text: String) -> String {
        var accessibilityString = ""

        guard let value = defaultValue else { return "" }
        if value {
            accessibilityString = text
        }
        return accessibilityString
    }

    /**
    Set image and text according trash size
    */
    private func setSizeImageOfTrash(size: Trash.Size) {
        lblSizeOfTrash.text = size.localizedName.uppercaseFirst
        //lblSizeOfTrash.text = size.rawValue.uppercaseFirst + " needed".localized

        switch size {
        case .bag:
            ivSizeOfTrash.image = #imageLiteral(resourceName: "Bag")
        case .car:
            ivSizeOfTrash.image = #imageLiteral(resourceName: "Car")
        default:
            ivSizeOfTrash.image = #imageLiteral(resourceName: "Wheelbarrow")
        }
    }

    /**
    Update Additional Information part of UI
    */
    private func updateAdditionalyInformationView() {
        if let note = trash?.note {
            if note != "" {
                lblAdditionalInformationInfo.text = note
            } else {
                additionalInformationView.isHidden = true
            }
        } else {
            additionalInformationView.isHidden = true
        }
    }

    /**
    Update Event part of UI
    */
    private func updateEventView() {
        if trash?.status.rawValue == "cleaned" {
            noCleaningEventView.isHidden = true
        }

        guard let _ = trash?.events.last?.start else { return }
        noCleaningEventView.isHidden = true
        cleaningEventView.isHidden = false
        tvCleaningEvents.reloadData()
    }

    /**
    Set annotation view with rounded image of specific size
    */
    private func setAnnotationView(view: MKAnnotationView?) {
        guard let trash = self.trash else { return }
        let status = Trash.DetailStatus.getStatus(in: trash)
        view?.image = status.mapAnnotationImage
        view?.frame.size = CGSize(width: 40.0, height: 40.0)
        view?.layer.cornerRadius = 0.5 * (view?.bounds.height)!
        view?.clipsToBounds = true
    }

    /**
    Set history cell for first load
    */
    private func setHistoryCell(trash: Trash, cell: HistoryTableViewCell, index: Int) {
        let update = trash.updates[index]
        let status = Trash.HistoryStatus.getStatus(update: update, in: trash)

        #if DEBUG
        if let ut = update.updateTime  {
            print("\(index): \(DateFormatter.utc.string(from: ut)) \(status.localizedName) \(update.status!)")
        } else {
            print("no update time")
        }
        #endif

        cell.lblHistoryStatus.text = status.localizedName.uppercased(with: Locale.current)
        cell.lblHistoryStatus.textColor = status.color
        cell.ivHistoryStatusImage.image = status.image

        if let ut = update.updateTime {
            cell.lblHistoryStatusDate.text = DateRounding.shared.localizedString(for: ut)
        } else {
            cell.lblHistoryStatusDate.text = "global.unknow".localized
        }

        if let organization = update.organization, !update.anonymous {
            cell.lblHistoryUser.text = organization.name
        } else if let user = update.user, update.anonymous == false {
            cell.lblHistoryUser.text = user.displayName // anonymous fallback
        } else {
            cell.lblHistoryUser.text = "trash.anonymous".localized
        }
    }

    /**
    Set types of trash for specific cell
    */
    private func setTypesOfTrash(trash: [Trash.TrashType], cell: TrashTypeCollectionViewCell, path: NSIndexPath) {
        if trash.first?.rawValue != nil {
            let type = trash[path.item]
            cell.lblTypeOfTrash.text = type.localizedName.uppercaseFirst
            cell.ivImage.image = type.highlightImage
            cell.ivImage.backgroundColor = type.highlightColor
        } else {
            cell.ivImage.image = #imageLiteral(resourceName: "No image square")
        }
    }

}

// MARK: - OBJC

extension DumpsDetailViewController {

    @objc func refreshContent() {
        reloadData(isLoadingViewActive: false) { [weak self] in

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.contentScrollView.refreshControl?.endRefreshing()
            }
        }
    }

    /**
    Share dumps link with friends
    */
    @objc func shareDump() {
        guard let message = trash?.sharingUrl else { return }
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem

        present(vc, animated: true, completion: nil)
    }

    /**
    Show photos on whole screen
    */
    @objc func showBigPhoto(_ sender: UITapGestureRecognizer) {
        guard let trash = trash else { return }
        if trash.images.last?.fullDownloadUrl != nil {
            if sender.state == .ended {
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "DumpsImageViewController") as? DumpsImageViewController else { return }
                vc.data = TrashUpdateGalleryData(updates: trash.updates)
                vc.trash = trash

                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            show(message: "trash.detail.missingPhoto".localized)
        }
    }

    /**
    Add cleaning event to calendar
    */
    @objc func joinEvent(_ sender: UIButton) {
        guard let event = trash?.events[sender.tag] else { return }
        eventManager.joinEvent(event, controller: self) { [weak self, weak event] (error) in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    if error.code == 300 {
                        self?.showWithSettings(message: error.localizedDescription)
                    } else {
                        self?.show(message: error.localizedDescription)
                    }
                    event?.showJoinButton = true
                } else {
                    event?.showJoinButton = false
                    //sender.isHidden = true
                }
            }
        }
    }

    /**
    Go to event detail
    */
    @objc func goToEventDetail(_ sender: UIButton) {
        guard let event = trash?.events[sender.tag] else { return }
        let storyboard = UIStoryboard.init(name: "Event", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController else { return }
        vc.id = event.id
        vc.showJoinButton = event.showJoinButton
        //vc.btnJoin.isHidden
        //vc.reportTime = setReportOrUpdateTimeInfo(rowCount: nil)
        //let navController = UINavigationController(rootViewController: vc)
        self.navigationController?.pushViewController(vc, animated: true)
        //present(navController, animated: true, completion: nil)
    }

    @objc func subscriptionUserJoinedEvent() {
        reloadData()
    }

    @objc func subscriptionUserUpdatedTrash() {
        reloadData(isLoadingViewActive: false, completion: nil)
    }

}

// MARK: - Mail Compose Delegate

extension DumpsDetailViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

}
