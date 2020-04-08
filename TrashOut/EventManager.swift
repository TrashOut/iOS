//
//  EventManager.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 20.02.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import EventKit
import UIKit

class EventManager {
    
    func joinButtonTest (_ event: Event, callback: @escaping (Bool) -> ()) {

        if UserManager.instance.isLoggedIn == false {
            event.showJoinButton = false
            callback(event.showJoinButton)
            return
        }
        
        guard let userId = UserManager.instance.user?.id else {
            event.showJoinButton = false
            callback(event.showJoinButton)
            return
        }
        
        Networking.instance.event(event.id, callback: { (loadedEvent, error) in
            guard error == nil else {
                event.showJoinButton = false
                callback(event.showJoinButton)
                return
            }
            guard let loadedEvent = loadedEvent else {
                event.showJoinButton = false
                callback(event.showJoinButton)
                return
            }
            // Creator of the event
            if userId == loadedEvent.userId {
                event.showJoinButton = false
                callback(event.showJoinButton)
                return
            }
            // Joined user
            if loadedEvent.users.contains(where: { (u) -> Bool in
                return u.id == userId
            }) {
                event.showJoinButton = false
                callback(event.showJoinButton)
                return
            }
            event.showJoinButton = true
            callback(event.showJoinButton)
        })
    }

	func joinEvent(_ event: Event, controller: UIViewController, callback: @escaping (Error?) -> ()) {
		guard let userId = UserManager.instance.user?.id else {
			let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [
				NSLocalizedDescriptionKey: "global.noDateToSave".localized
			])
			callback(error)
			return
		}
/*
		let date = startDate
		let calendar = NSCalendar.current
		let components = DateComponents()
		let newDate = calendar.date(byAdding: components, to: date)
		let calendarEventName = String(format: "event.header_X".localized, name)
*/

		Networking.instance.event(event.id, callback: { (event, error) in
			guard error == nil else {
				callback(error)
				return
			}
            
            let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "event.joinEventFailed".localized
                ])
			guard let event = event else {
				callback(error)
				return
			}
            
            if userId == event.userId {
                callback(error)
                return
            }
            
			if event.users.contains(where: { (u) -> Bool in
				return u.id == userId
			}) {
				self.addToCalendar(event: event, controller: controller, callback: callback)
				return
			}
            
			Networking.instance.userJoinedEvent(event.id, userId: userId) { [weak self] (_, error) in
				guard error == nil else {
					callback(error)
					return
				}
                NotificationCenter.default.post(name: .userJoindedEvent, object: nil)
				self?.addToCalendar(event: event, controller: controller, callback: callback)
			}
		})

	}

    func addToCalendar(event: Event, controller: UIViewController, callback: @escaping (Error?)->()) {
		guard let startDate = event.start, let name = event.name, let description = event.description else {
			callback(nil)
			return
		}
		let calendarEventName = String(format: "event.header_X".localized, name)

		self.confirmJoin(controller: controller) { [weak self] (confirmed) in
			if confirmed {
				self?.addEventToCalendar(title: calendarEventName, description: description, startDate: startDate, endDate: startDate + TimeInterval(event.duration * 60)) { (success, error) in
					if success {
						if let vc = controller as? ViewController {
							vc.show(message: "event.addedToCalender.success".localized)
						}
					}
					callback(error)
				}
			} else {
				callback(nil)
			}
		}
	}

	func confirmJoin(controller: UIViewController, callback: @escaping (Bool)->()) {
		let alert = UIAlertController(title: "event.addToCalendar".localized, message: nil, preferredStyle: .alert)
		let ok = UIAlertAction.init(title: "global.add".localized, style: .default) { (_) in
			callback(true)
		}
        
		alert.addAction(ok)
        alert.addAction(UIAlertAction(title: "global.cancel".localized, style: .cancel, handler: { _ in callback(false) }))

		controller.present(alert, animated: true, completion: nil)
	}

	/**
	Add cleaning event to calendar
	*/
	fileprivate func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
		let eventStore = EKEventStore()

		eventStore.requestAccess(to: .event, completion: { (granted, error) in
			if granted && error == nil {
				let event = EKEvent(eventStore: eventStore)
				event.title = title.localized
				event.startDate = startDate
				event.endDate = endDate
				event.notes = description?.localized
				event.calendar = eventStore.defaultCalendarForNewEvents
				do {
					try eventStore.save(event, span: .thisEvent)
				} catch {
					let error = NSError(domain: "cz.trashout.TrashOut", code: 500, userInfo: [
						NSLocalizedDescriptionKey: "event.validation.cannotBeAddedToCalendar".localized
						])
					completion?(false, error)
					return
				}
				// self?.show(message: "event.addedToCalender.success".localized)
				completion?(true, nil)
			} else {
				//self?.showWithSettings(message: "global.enableAccessToCalendar".localized)
				let error = NSError.init(domain: "cz.trashout.TrashOut", code: 300, userInfo: [
					NSLocalizedDescriptionKey: "global.enableAccessToCalendar".localized
					])
				completion?(false, error)

			}
		})
	}

}
