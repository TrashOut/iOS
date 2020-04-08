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

class ReportViewController: ViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

//    @IBOutlet var loadingView: UIView! {
//        didSet {
//            loadingView.isHidden = true
//        }
//    }
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var takeFirstPhotoView: UIView! {
        didSet {
            takeFirstPhotoView.isHidden = true
        }
    }
    @IBOutlet var takeAnotherPhotoView: UIView! {
        didSet {
            takeAnotherPhotoView.isHidden = true
        }
    }
    @IBOutlet var sizeOfTrashView: UIView!
    @IBOutlet var typesOfTrashView: UIView!
    @IBOutlet var accessibilityView: UIStackView!
    @IBOutlet var statusView: UIView! {
        didSet {
            statusView.isHidden = true
        }
    }
    @IBOutlet var locationView: UIStackView!
    @IBOutlet var locationAccuracyView: UIView! {
        didSet {
            locationAccuracyView.isHidden = true
        }
    }
    @IBOutlet var locationAddressView: UIView! {
        didSet {
            locationAddressView.isHidden = true
        }
    }

//    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var vDescSeparator: [UIView]!

    @IBOutlet var cnByCarSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var cnInCaveSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var cnUnderWaterSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var cnStatusSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var cnAccuracyViewHeight: NSLayoutConstraint!
    @IBOutlet var cnAddressTop: NSLayoutConstraint!

    @IBOutlet var cvPhoto: UICollectionView!

    @IBOutlet var map: MKMapView!

    @IBOutlet var swByCar: UISwitch!
    @IBOutlet var swInCave: UISwitch!
    @IBOutlet var swUnderWater: UISwitch!
    @IBOutlet var swNotForGeneralCleanup: UISwitch!
    @IBOutlet var swStillHere: UISwitch!
    @IBOutlet var swICleanedIt: UISwitch!
    @IBOutlet var swSendAnonymously: UISwitch!

    @IBOutlet var lblPhotoInfoTitle: UILabel!
    @IBOutlet var lblPhotoInfoSubtitle: UILabel!
    @IBOutlet var lblSizeOfTrash: UILabel!
    @IBOutlet var lblFitsABag: UILabel!
    @IBOutlet var lblFitsAWheelbarrow: UILabel!
    @IBOutlet var lblCarNeeded: UILabel!
    @IBOutlet var lblTypeOfTrash: UILabel!
    @IBOutlet var lblDomestic: UILabel!
    @IBOutlet var lblAutomotive: UILabel!
    @IBOutlet var lblConstruction: UILabel!
    @IBOutlet var lblPlastic: UILabel!
    @IBOutlet var lblElectronic: UILabel!
    @IBOutlet var lblOrganic: UILabel!
    @IBOutlet var lblMetal: UILabel!
    @IBOutlet var lblLiquid: UILabel!
    @IBOutlet var lblDangerous: UILabel!
    @IBOutlet var lblDeadAnimals: UILabel!
    @IBOutlet var lblGlass: UILabel!
    @IBOutlet var lblAccessibility: UILabel!
    @IBOutlet var lblByCar: UILabel!
    @IBOutlet var lblInCave: UILabel!
    @IBOutlet var lblUnderWater: UILabel!
    @IBOutlet var lblNotForGeneralCleanup: UILabel!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblCleaned: UILabel!
    @IBOutlet var lblICleanedIt: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblLocationAccuracy: UILabel!
    @IBOutlet var lblTryingBetterLocation: UILabel!
    @IBOutlet var lblAccuracy: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblCoordinates: UILabel!
    @IBOutlet var lblAdditionalInformation: UILabel!
    @IBOutlet var lblSendAnonymously: UILabel!

    @IBOutlet var btnAddPhoto: UIButton!
    @IBOutlet var btnTakeAnotherPhoto: UIButton!
    @IBOutlet var btnsSizeOfTrash: [UIButton]!
    @IBOutlet var btnDomestic: UIButton!
    @IBOutlet var btnAutomotive: UIButton!
    @IBOutlet var btnConstruction: UIButton!
    @IBOutlet var btnPlastic: UIButton!
    @IBOutlet var btnElectronic: UIButton!
    @IBOutlet var btnOrganic: UIButton!
    @IBOutlet var btnMetal: UIButton!
    @IBOutlet var btnLiquid: UIButton!
    @IBOutlet var btnDangerous: UIButton!
    @IBOutlet var btnDeadAnimals: UIButton!
    @IBOutlet var btnGlass: UIButton!

    @IBOutlet var tvAdditionalInformation: UITextView!

    var trash: Trash?
    var cleaned: Bool?

	var photos: [LocalImage] = []
    // var photo: String?
    // var uploadData = [Data]()
    // var photosNames = [String]()

	var photoManager: PhotoManager = PhotoManager()

    // fileprivate var photos = [String]()
    fileprivate var thumbsURL = [String]()
    fileprivate var thumbsStorage = [String]()
    fileprivate var photosURL = [String]()
    fileprivate var photosStorage = [String]()
    fileprivate var gps: Coordinates!
    fileprivate var note: String!
    fileprivate var anonymous = false
    fileprivate var cleanedByMe = false
    fileprivate var byCar = false
    fileprivate var inCave = false
    fileprivate var underWater = false
    fileprivate var notForGeneralCleanup = false
    fileprivate var accessibility: DumpsAccessibility!
    fileprivate var images: [DumpsImages]! = []
    fileprivate var trashTypes: [String]!
    fileprivate var trashSize: String!
    fileprivate var trashStatus: String!

    override func viewDidLoad() {
		super.viewDidLoad()

        title = "trash.create.title".localized
        navigationController?.isNavigationBarHidden = false

        // If user took a photo, show it, otherwise show view with info to take picture
		if photos.count > 0 {
			cvPhoto.reloadData()
			takeAnotherPhotoView.isHidden = false
		} else {
			takeFirstPhotoView.isHidden = false
		}

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

		let backButton = UIBarButtonItem.init(title: "global.cancel".localized, style: .plain, target: self, action: #selector(close))
		navigationItem.leftBarButtonItem = backButton
        let sendButton = UIBarButtonItem(title: "global.create.send".localized, style: .plain, target: self, action: #selector(sendReport))
        navigationItem.rightBarButtonItem = sendButton

        cnByCarSeparatorHeight.preciseConstant = 1
        cnInCaveSeparatorHeight.preciseConstant = 1
        cnUnderWaterSeparatorHeight.preciseConstant = 1
        cnStatusSeparatorHeight.preciseConstant = 1

        btnAddPhoto.setTitle("trash.create.addPhoto".localized.uppercased(with: Locale.current), for: .normal)
        btnAddPhoto.theme()
        btnTakeAnotherPhoto.setTitle("trash.create.takeAnotherPhoto".localized.uppercased(with: Locale.current), for: .normal)
        btnTakeAnotherPhoto.theme()

        if trash == nil {
            lblPhotoInfoTitle.text = "trash.create.takeAtLeastOnePhoto".localized
        } else {
            lblPhotoInfoTitle.text = "trash.create.takeAtLeastOnePhoto".localized
        }
        lblPhotoInfoSubtitle.text = "trash.create.ofIllegalDump".localized
        lblPhotoInfoSubtitle.textColor = Theme.current.color.lightGray
        lblSizeOfTrash.text = "trash.trashSize".localized
        lblSizeOfTrash.textColor = Theme.current.color.green
        lblFitsABag.text = "trash.size.bag".localized
        lblFitsAWheelbarrow.text = "trash.size.wheelbarrow".localized
        lblCarNeeded.text = "trash.size.carNeeded".localized
        lblTypeOfTrash.text = "trash.trashType".localized
        lblTypeOfTrash.textColor = Theme.current.color.green
        lblDomestic.text = "trash.types.domestic".localized
        lblAutomotive.text = "trash.types.automotive".localized
        lblConstruction.text = "trash.types.construction".localized
        lblPlastic.text = "trash.types.plastic".localized
        lblElectronic.text = "trash.types.electronic".localized
        lblOrganic.text = "trash.types.organic".localized
        lblMetal.text = "trash.types.metal".localized
        lblLiquid.text = "trash.types.liquid".localized
        lblDangerous.text = "trash.types.dangerous".localized
        lblDeadAnimals.text = "trash.types.deadAnimals".localized
        lblGlass.text = "trash.types.glass".localized
        lblAccessibility.text = "trash.accessibility".localized
        lblAccessibility.textColor = Theme.current.color.green
        lblByCar.text = "trash.accessibility.byCar".localized
        lblInCave.text = "trash.accessibility.inCave".localized
        lblUnderWater.text = "trash.accessibility.underWater".localized
        lblNotForGeneralCleanup.text = "trash.accessibility.notForGeneralCleanup".localized
        lblStatus.text = "global.status".localized
        lblStatus.textColor = Theme.current.color.green
        lblCleaned.text = "trash.status.cleaned".localized
        lblICleanedIt.text = "trash.cleanedByMe".localized
        lblLocation.text = "trash.gpsLocation".localized
        lblLocation.textColor = Theme.current.color.green
        lblLocationAccuracy.text = "trash.accuracyOfLocation".localized
        lblTryingBetterLocation.text = "trash.edit.betterLocation".localized
        lblTryingBetterLocation.textColor = Theme.current.color.lightGray
        lblCoordinates.textColor = Theme.current.color.lightGray
        lblAdditionalInformation.text = "trash.note".localized
        lblAdditionalInformation.textColor = Theme.current.color.green
        lblSendAnonymously.text = "trash.sendAnonymously".localized

        tvAdditionalInformation.text = "trash.create.additionalInfo.hint".localized
        tvAdditionalInformation.textColor = Theme.current.color.lightGray

        for separator in vDescSeparator {
            separator.backgroundColor = UIColor.theme.separatorLine
        }

        // Initial setup
        trashStatus = ""
        trashTypes = []
        trashSize = nil

        setSizeOfTrashView()
        setTypesOfTrashView()
        setAccessibilityView()
        setStatusView()
    
        LocationManager.manager.refreshCurrentLocation({ [weak self](_) in
            self?.setLocationView()
        })
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		setRoundedButtonWithBorder(button: btnsSizeOfTrash[0])
		setRoundedButtonWithBorder(button: btnsSizeOfTrash[1])
		setRoundedButtonWithBorder(button: btnsSizeOfTrash[2])
		setRoundedButtonWithBorder(button: btnDomestic)
		setRoundedButtonWithBorder(button: btnAutomotive)
		setRoundedButtonWithBorder(button: btnConstruction)
		setRoundedButtonWithBorder(button: btnPlastic)
		setRoundedButtonWithBorder(button: btnElectronic)
		setRoundedButtonWithBorder(button: btnOrganic)
		setRoundedButtonWithBorder(button: btnMetal)
		setRoundedButtonWithBorder(button: btnLiquid)
		setRoundedButtonWithBorder(button: btnDangerous)
		setRoundedButtonWithBorder(button: btnDeadAnimals)
        setRoundedButtonWithBorder(button: btnGlass)
	}
    
	// MARK: - Actions

	@objc func close() {
        LoadingView.hide()
		navigationController?.dismiss(animated: true, completion: nil)
	}

    /**
    Report a dump or update one
    */
    @objc func sendReport() {
        
        //show(message: "trash.create.validation.notFilledRequiredFileds".localized)
        if trash != nil && photos.isEmpty {
            show(message: "trash.create.takeAtLeastOnePhoto".localized)
        } else if trash == nil && photos.count < 1 {
            show(message: "trash.create.takeAtLeastOnePhoto".localized)
        } else if trash != nil && !locationAccuracyView.isHidden {
            show(message: "trash.edit.youAreMoreThan100FromDump".localized)
        } else if trash == nil && !locationAccuracyView.isHidden {
            show(message: "trash.edit.badAccurancy".localized)
        } else if trash == nil && trashSize == nil {
            show(message: "trash.validation.sizeRequired".localized)
        } else if trash == nil && trashTypes.count == 0 {
            show(message: "trash.validation.typeRequired".localized)
        } else {
            let window = self.view.window
            LoadingView.show(on: window!, style: .transparent)

			let failed: () -> () = { [weak self] in
				//self?.show(message: "trash.create.uploadPhotoError".localized)
				self?.show(message: "global.fetchError".localized)
				LoadingView.hide()
			}
            if photos.count > 0 {
				var uploads: [Async.Block] = []

				for photo in photos {
					uploads.append({ [weak self] (completion, failure) in
                        
						guard let photoName = photo.uid, let data = photo.jpegData, let thumbnailData = photo.thumbnailJpegData else {
							let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
							failure(error)
								return
						}
						self?.uploadImage(photoName: photoName, data: data, thumbnailData: thumbnailData, completion: completion, failure: failure)
					})
				}
				uploads.append({ [weak self] (completion, failure) in
                    
					if self?.cleaned != nil {
						if self?.cleaned == true {
							self?.updateTrash(completion: completion, failure: failure)
						} else  {
							self?.updateTrash(completion: completion, failure: failure)
						}
					} else {
						self?.createTrash(completion: completion, failure: failure)
					}
				})
				uploads.append({ [weak self] (completion, failure) in
                    
                    if self?.cleaned != nil {
                        NotificationCenter.default.post(name: .userUpdatedTrash, object: nil)
                    } else {
                        NotificationCenter.default.post(name: .userCreatedTrash, object: nil)
                    }
					LoadingView.hide()
				})
				Async.waterfall(uploads, failure: { (error) in
					failed()
				})
			} else {
				failed()
			}
        }
    }

    func uploadImage(photoName: String, data: Data, thumbnailData:Data,  completion: @escaping ()->(), failure: @escaping (Error)->()) {
        FirebaseImages.instance.uploadImage(photoName, data: data, thumbnailData: thumbnailData) { [weak self] (thumbnailUrl, thumbnailStorage , imageUrl, imageStorage, error) in            
			guard error == nil else {
				print(error?.localizedDescription as Any)
				failure(error!)
				return
			}
            guard thumbnailUrl != nil else {
                let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
                failure(error)
                return
            }
            guard let thumbnailStorage = thumbnailStorage else {
                let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
                failure(error)
                return
            }
			guard imageUrl != nil else {
				let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
				failure(error)
				return
			}
			guard let imageStorage = imageStorage else {
				let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
				failure(error)
				return
			}
            self?.thumbsURL.append(thumbnailUrl!)
            self?.thumbsStorage.append(thumbnailStorage)
			self?.photosURL.append(imageUrl!)
			self?.photosStorage.append(imageStorage)
			completion()
		}
	}

    /**
    User creates a dump report
    */
    fileprivate func createTrash(completion: @escaping ()->(), failure: @escaping (Error)->()) {
        
        accessibility = DumpsAccessibility.init(byCar: byCar, inCave: inCave, underWater: underWater, notForGeneralCleanup: notForGeneralCleanup)
		for i in 0..<photosURL.count {
            let image = DumpsImages.init(thumbDownloadUrl: thumbsURL[i], thumbStorageLocation: thumbsStorage[i] ,fullDownloadUrl: photosURL[i], storageLocation: photosStorage[i])
			images.append(image)
		}
        
        Networking.instance.createTrash(images, gps: gps, size: trashSize, type: trashTypes, note: note, anonymous: anonymous, userId: (UserManager.instance.user?.id)!, accessibility: accessibility) { [weak self] (trash, error) in
            guard error == nil else {
                print(error?.localizedDescription as Any)
				failure(error!)
                return
            }
			completion()
            self?.openThankYouViewController(trash: trash)
            /*
            let alert = UIAlertController(title: nil, message: "trash.create.successfullyReported".localized, preferredStyle: .alert)
            let ok = UIAlertAction.init(title: "global.ok".localized, style: .default) { [weak self] (alertAction) in
                self?.close()
            }
            alert.addAction(ok)
            self?.present(alert, animated: true, completion: nil)
            */
        }
    }

    /**
    User updates a dump
    */
    fileprivate func updateTrash(completion: @escaping ()->(), failure: @escaping (Error)->()) {
        
        accessibility = DumpsAccessibility.init(byCar: byCar, inCave: inCave, underWater: underWater, notForGeneralCleanup: notForGeneralCleanup)
        if !photosURL.isEmpty {
            for i in 0..<photosURL.count {
                let image = DumpsImages.init(thumbDownloadUrl: thumbsURL[i], thumbStorageLocation: thumbsStorage[i] ,fullDownloadUrl: photosURL[i], storageLocation: photosStorage[i])
                images.append(image)
            }
        }
        guard let trashId = trash?.id else {
			let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
			failure(error)
			return
		}

        Networking.instance.updateTrash(trashId, images: images, gps: gps, size: trashSize, type: trashTypes, note: note, anonymous: anonymous, userId: (UserManager.instance.user?.id)!, accessibility: accessibility, status: trashStatus, cleanedByMe: cleanedByMe) { [weak self] (trash, error) in
            guard error == nil else {
                print(error?.localizedDescription as Any)
				failure(error!)
                return
            }
			completion()
            let alert = UIAlertController(title: nil, message: "trash.create.successfullyUpdated".localized, preferredStyle: .alert)
            let ok = UIAlertAction.init(title: "global.ok".localized, style: .default) { [weak self] (alertAction) in
                self?.close()
            }
            alert.addAction(ok)
            self?.present(alert, animated: true, completion: nil)
        }
    }

    /**
    Set rounded button with light gray border
    */
    fileprivate func setRoundedButtonWithBorder(button: UIButton) {
        button.layer.cornerRadius = 0.5 * button.bounds.height
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func addPhoto(_ sender: UIButton) {
		photoManager.takePhoto(vc: self, source: .camera, success: { [weak self] (image) in
			self?.photos.append(image)
			self?.cvPhoto.reloadData()
			if let cnt = self?.photos.count {
				let ip = IndexPath.init(item: cnt - 1, section: 0)
				self?.cvPhoto.scrollToItem(at: ip, at: UICollectionView.ScrollPosition.left, animated: true)
			}
			self?.takeFirstPhotoView.isHidden = true
			self?.takeAnotherPhotoView.isHidden = false
		}) { (_) in
			// no action
		}
    }

    /**
    Set Size of Trash part of UI
    */
    fileprivate func setSizeOfTrashView() {
        if cleaned == true {
            sizeOfTrashView.isHidden = true

            guard let size = trash?.size else { return }
            downloadedSizeOfTrash(trash: size)
        } else {
            guard let size = trash?.size else { return }
            downloadedSizeOfTrash(trash: size)
        }
    }

    /**
    Color downloaded size of trash
    */
    fileprivate func downloadedSizeOfTrash(trash: Trash.Size) {
        for button in btnsSizeOfTrash {
            switch trash {
            case .bag:
                if button.tag == 0 {
                    setSizeOfTrash(sender: button, selectedImage: "BagClear", chosenSize: "bag")
                }
            case .wheelbarrow:
                if button.tag == 1 {
                    setSizeOfTrash(sender: button, selectedImage: "WheelbarrowClear", chosenSize: "wheelbarrow")
                }
            case .car:
                if button.tag == 2 {
                    setSizeOfTrash(sender: button, selectedImage: "CarClear", chosenSize: "car")
                }
            }
        }
    }

    /**
    Set Types of Trash part of UI
    */
    fileprivate func setTypesOfTrashView() {
        if cleaned == true {
            typesOfTrashView.isHidden = true

            guard let types = trash?.types else { return }
            downloadedTypesOfTrash(trash: types)
        } else {
            guard let types = trash?.types else { return }
            downloadedTypesOfTrash(trash: types)
        }
    }

    /**
    Color downloaded types of trash
    */
    fileprivate func downloadedTypesOfTrash(trash: [Trash.TrashType]) {
        if trash.count > 0 {
            for i in 0...trash.count - 1 {
                if trash[i].rawValue == "domestic" {
                    setTypesOfTrash(sender: btnDomestic, selectedImage: "DomesticClear", color: Theme.current.color.domestic, chosenType: "domestic")
                } else if trash[i].rawValue == "automotive" {
                    setTypesOfTrash(sender: btnAutomotive, selectedImage: "AutomotiveClear", color: Theme.current.color.automotive, chosenType: "automotive")
                } else if trash[i].rawValue == "construction" {
                    setTypesOfTrash(sender: btnConstruction, selectedImage: "ConstructionClear", color: Theme.current.color.construction, chosenType: "construction")
                } else if trash[i].rawValue == "plastic" {
                    setTypesOfTrash(sender: btnPlastic, selectedImage: "PlasticClear", color: Theme.current.color.plastic, chosenType: "plastic")
                } else if trash[i].rawValue == "electronic" {
                    setTypesOfTrash(sender: btnElectronic, selectedImage: "ElectronicClear", color: Theme.current.color.electronic, chosenType: "electronic")
                } else if trash[i].rawValue == "organic" {
                    setTypesOfTrash(sender: btnOrganic, selectedImage: "OrganicClear", color: Theme.current.color.organic, chosenType: "organic")
                } else if trash[i].rawValue == "metal" {
                    setTypesOfTrash(sender: btnMetal, selectedImage: "MetalClear", color: Theme.current.color.metal, chosenType: "metal")
                } else if trash[i].rawValue == "liquid" {
                    setTypesOfTrash(sender: btnLiquid, selectedImage: "LiquidClear", color: Theme.current.color.liquid, chosenType: "liquid")
                } else if trash[i].rawValue == "dangerous" {
                    setTypesOfTrash(sender: btnDangerous, selectedImage: "DangerousClear", color: Theme.current.color.dangerous, chosenType: "dangerous")
                } else if trash[i].rawValue == "glass" {
                    setTypesOfTrash(sender: btnGlass, selectedImage: "GlassClear", color: Theme.current.color.glass, chosenType: "glass")
                }
                else {
                    setTypesOfTrash(sender: btnDeadAnimals, selectedImage: "AnimalsClear", color: Theme.current.color.deadAnimals, chosenType: "deadAnimals")
                }
            }
        }
    }

    /**
    Set Accessibility part of UI
    */
    fileprivate func setAccessibilityView() {
        if trash != nil && cleaned == false {
            downloadedAccessibility(defaultValue: trash?.accessibility?.byCar, sw: swByCar)
            byCar = (trash?.accessibility?.byCar)!
            downloadedAccessibility(defaultValue: trash?.accessibility?.inCave, sw: swInCave)
            inCave = (trash?.accessibility?.inCave)!
            downloadedAccessibility(defaultValue: trash?.accessibility?.underWater, sw: swUnderWater)
            underWater = (trash?.accessibility?.underWater)!
            downloadedAccessibility(defaultValue: trash?.accessibility?.notForGeneralCleanup, sw: swNotForGeneralCleanup)
            notForGeneralCleanup = (trash?.accessibility?.notForGeneralCleanup)!
        } else if cleaned == true {
            accessibilityView.isHidden = true
            byCar = (trash?.accessibility?.byCar)!
            inCave = (trash?.accessibility?.inCave)!
            underWater = (trash?.accessibility?.underWater)!
            notForGeneralCleanup = (trash?.accessibility?.notForGeneralCleanup)!
        }
    }
    
    fileprivate func showTrashOnMap(coords: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coords
        
        map.addAnnotation(annotation)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion.init(center: coords, span: span)
        map.setRegion(region, animated: true)
    }

    /**
    If accessibility is true, set its switch on
    */
    fileprivate func downloadedAccessibility(defaultValue: Bool?, sw: UISwitch) {
        guard let value = defaultValue else { return }
        if value {
            sw.setOn(true, animated: true)
        }
    }

    @IBAction func byCar(_ sender: UISwitch) {
        if sender.isOn {
            byCar = true
        } else {
            byCar = false
        }
    }

    @IBAction func inCave(_ sender: UISwitch) {
        if sender.isOn {
            inCave = true
        } else {
            inCave = false
        }
    }

    @IBAction func underWater(_ sender: UISwitch) {
        if sender.isOn {
            underWater = true
        } else {
            underWater = false
        }
    }

    @IBAction func notForGeneralCleanup(_ sender: UISwitch) {
        if sender.isOn {
            notForGeneralCleanup = true
        } else {
            notForGeneralCleanup = false
        }
    }

    /**
    Set Status part of UI
    */
    fileprivate func setStatusView() {
        if cleaned == true {
            statusView.isHidden = false
            trashStatus = "cleaned"
			swStillHere.isEnabled = false
			
        } else if cleaned == false {
            trashStatus = "stillHere"
        }
    }

    @IBAction func cleanedByMe(_ sender: UISwitch) {
        if sender.isOn {
            cleanedByMe = true
        } else {
            cleanedByMe = false
        }
    }
    
    /**
    Set Location part of UI
    */
    fileprivate func setLocationView() {
        // If user wants to report new dump, the trash is nill. Otherwise user is updating existing trash.
        if trash == nil {
            locationAddressView.isHidden = false

            let accuracy = Int(LocationManager.manager.currentLocation.horizontalAccuracy)
            if accuracy > 100 {
                locationAccuracyView.isHidden = false
                lblAccuracy.text = "\(Int(accuracy)) m"
            } else {
                cnAccuracyViewHeight.constant = 76
                cnAddressTop.constant = 0
            }

            let coords = LocationManager.manager.currentLocation.coordinate

            gps = Coordinates.init(lat: coords.latitude, long: coords.longitude, accuracy: accuracy, source: "gps")

            showAddressAndCoorinates(latitude: coords.latitude, longitude: coords.longitude)
        } else {
            cnAccuracyViewHeight.constant = 76

            let accuracy = Int(LocationManager.manager.currentLocation.horizontalAccuracy)
            if accuracy > 100 {
                locationAccuracyView.isHidden = false
                lblAccuracy.text = "\(Int(accuracy)) m"
            } else {
                if let trashGps = trash?.gps {
                    let trashLocation = CLLocation.init(latitude: trashGps.lat, longitude: trashGps.long)
                    let distance = LocationManager.manager.currentLocation.distance(from: trashLocation)
                    let distanceInM = Int(round(distance))

                    if distanceInM > 100 {
						lblAccuracy.text = DistanceRounding.shared.localizedDistance(meteres: distanceInM)
//                        if distanceInM < 501 {
//                            lblAccuracy.text = "∼\(DistanceRounding.roundDistance(distance: distanceInM))m away".localized
//                        } else {
//                            if DistanceRounding.roundDistance(distance: distanceInM) > 10000 {
//                                lblAccuracy.text = "> 10km away".localized
//                            } else {
//                                lblAccuracy.text = "∼\(DistanceRounding.roundDistance(distance: distanceInM))km away".localized
//                            }
//                        }
                        locationAccuracyView.isHidden = false
                        lblLocationAccuracy.text = "trash.dumpsDistance".localized
                        lblTryingBetterLocation.text = "trash.edit.getCloser".localized
                        lblAccuracy.adjustsFontSizeToFitWidth = true
                        
                        
                    } else {
                        locationView.isHidden = true
                    }

                    var source = ""
                    if Reachability.isConnectedToCellularNetwork() {
                        source = "network"
                    } else if Reachability.isConnectedToNetwork() {
                        source = "wifi"
                    } else {
                        source = "gps"
                    }

                    gps = Coordinates.init(lat: trashGps.lat, long: trashGps.long, accuracy: accuracy, source: source)
                }
            }
        }
        
        let coords = CLLocationCoordinate2DMake(gps.lat, gps.long)
        showTrashOnMap(coords: coords)
    }

    /**
    Show address and coordinates
    */
    fileprivate func showAddressAndCoorinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        lblAddress.text = ""
        lblCoordinates.text = "\(String(format:"%.6f", latitude)), \(String(format:"%.6f", longitude))"

        LocationManager.manager.resolveName(for: CLLocation.init(latitude: latitude, longitude: longitude)) { [weak self] (name) in
			guard let name = name else { return }
            let locality = name.locality != nil ? name.locality! + ", " : ""
            let administrativeArea = name.administrativeArea != nil ? name.administrativeArea! + ", " : ""
            let country = name.country ?? ""

            self?.lblAddress.text = locality + administrativeArea + country
            self?.lblAddress.adjustsFontSizeToFitWidth = true
        }
    }

    /**
    Move keyboard for text view below the text itself
    */
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!

        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + 10, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset

        let selectedRange = tvAdditionalInformation.selectedRange
        tvAdditionalInformation.scrollRangeToVisible(selectedRange)
    }

    /**
    Save the text entered by user to text view
    */
    func textViewDidChange(_ textView: UITextView) {
        note = textView.text
    }

    /**
    When user starts edit text view, delete placeholder
    */
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "trash.create.additionalInfo.hint".localized {
            textView.text = nil
        }
    }

    /**
    When user ends edit text view, put placeholder back
    */
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "trash.create.additionalInfo.hint".localized
        }
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

    @IBAction func chooseSizeOfTrash(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            setSizeOfTrash(sender: sender, selectedImage: "BagClear", chosenSize: "bag")
        case 1:
            setSizeOfTrash(sender: sender, selectedImage: "WheelbarrowClear", chosenSize: "wheelbarrow")
        case 2:
            setSizeOfTrash(sender: sender, selectedImage: "CarClear", chosenSize: "car")
        default: break
        }
    }

    /**
    Set size of trash, color chosen size and disable other buttons
    */
    fileprivate func setSizeOfTrash(sender: UIButton, selectedImage: String, chosenSize: String) {
        for btn in btnsSizeOfTrash {
            btn.backgroundColor = .clear
            btn.isEnabled = true
        }
        trashSize = chosenSize
        sender.setImage(UIImage(named: selectedImage), for: .disabled)
        sender.backgroundColor = Theme.current.color.green
        sender.clipsToBounds = true
        sender.isEnabled = false
    }

    @IBAction func chooseTypesOfTrash(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            setTypesOfTrash(sender: sender, selectedImage: "DomesticClear", color: Theme.current.color.domestic, chosenType: "domestic")
        case 1:
            setTypesOfTrash(sender: sender, selectedImage: "AutomotiveClear", color: Theme.current.color.automotive, chosenType: "automotive")
        case 2:
            setTypesOfTrash(sender: sender, selectedImage: "ConstructionClear", color: Theme.current.color.construction, chosenType: "construction")
        case 3:
            setTypesOfTrash(sender: sender, selectedImage: "PlasticClear", color: Theme.current.color.plastic, chosenType: "plastic")
        case 4:
            setTypesOfTrash(sender: sender, selectedImage: "ElectronicClear", color: Theme.current.color.electronic, chosenType: "electronic")
        case 5:
            setTypesOfTrash(sender: sender, selectedImage: "OrganicClear", color: Theme.current.color.organic, chosenType: "organic")
        case 6:
            setTypesOfTrash(sender: sender, selectedImage: "MetalClear", color: Theme.current.color.metal, chosenType: "metal")
        case 7:
            setTypesOfTrash(sender: sender, selectedImage: "LiquidClear", color: Theme.current.color.liquid, chosenType: "liquid")
        case 8:
            setTypesOfTrash(sender: sender, selectedImage: "DangerousClear", color: Theme.current.color.dangerous, chosenType: "dangerous")
        case 9:
            setTypesOfTrash(sender: sender, selectedImage: "AnimalsClear", color: Theme.current.color.deadAnimals, chosenType: "deadAnimals")
        case 10:
            setTypesOfTrash(sender: sender, selectedImage: "GlassClear", color: Theme.current.color.glass, chosenType: "glass")
            
        default: break
        }
    }

    /**
    Set types of trash, color chosen size and disable other buttons
    */
    fileprivate func setTypesOfTrash(sender: UIButton, selectedImage: String, color: UIColor, chosenType: String) {
        if sender.isSelected == false {
            trashTypes.append(chosenType)
            sender.setImage(UIImage(named: selectedImage), for: .selected)
            sender.backgroundColor = color
            sender.clipsToBounds = true
            sender.isSelected = true
        } else {
            trashTypes = trashTypes.filter { $0 != chosenType }
            sender.backgroundColor = .clear
            sender.isSelected = false
        }
    }

    @IBAction func sendAnonymously(_ sender: UISwitch) {
        if sender.isOn {
            anonymous = true
        } else {
            anonymous = false
        }
    }

    // MARK: - Collection view

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TakePhotoCell", for: indexPath) as? TakePhotoCollectionViewCell else { fatalError("Could not dequeue cell with identifier: TakePhotoCell") }

        let photo = photos[indexPath.item]
        cell.ivPhoto.image = photo.image

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cvPhoto.bounds.size
    }

    // MARK: - Navigaton
    
    func openThankYouViewController(trash: Trash?) {
        performSegue(withIdentifier:"openThankYouVC", sender: trash)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openThankYouVC" {
            if let tyvc = segue.destination as? ReportThankYouViewController {
                tyvc.trash = sender as? Trash
                tyvc.dismissHandler = { [weak self] in
                    self?.close()
                }
            }
        }
    }
    
}

class TakePhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var ivPhoto: UIImageView!

    override func prepareForReuse() {
        ivPhoto.cancelRemoteImageRequest()
    }

}

class DumpsAccessibility: NSObject {
    var byCar: Bool
    var inCave: Bool
    var underWater: Bool
    var notForGeneralCleanup: Bool

    init(byCar: Bool, inCave: Bool, underWater: Bool, notForGeneralCleanup: Bool) {
        self.byCar = byCar
        self.inCave = inCave
        self.underWater = underWater
        self.notForGeneralCleanup = notForGeneralCleanup
    }
}

class DumpsImages: NSObject {
    var fullDownloadUrl: String
    var storageLocation: String
    var thumbDownloadUrl: String
    var thumbStorageLocation: String

    init(thumbDownloadUrl: String, thumbStorageLocation: String, fullDownloadUrl: String, storageLocation: String) {
        self.thumbDownloadUrl = thumbDownloadUrl
        self.thumbStorageLocation = thumbStorageLocation
        self.fullDownloadUrl = fullDownloadUrl
        self.storageLocation = storageLocation
    }
}
