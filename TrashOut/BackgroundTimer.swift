//
//  RepeatingTimer.swift
//  TrashOut-Prod
//
//  Created by Grünvaldský Dávid on 21/08/2018.
//  Copyright © 2018 TrashOut NGO. All rights reserved.
//

import UIKit

/// Background timer with interval 1 second.
class BackgroundTimer {
    
    static let `default` = BackgroundTimer(name: "default")
    
    fileprivate let interval: TimeInterval = 1
    fileprivate lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.interval, repeating: self.interval)
        t.setEventHandler(handler: { [unowned self] in
            DispatchQueue.main.async { [unowned self] in
                self.currentTime += 1
                self.eventHandler?(self.currentTime)
            }
        })
        return t
    }()
    
    fileprivate let notificationCenter = NotificationCenter.default
    fileprivate let name: String
    fileprivate var currentTime: TimeInterval = 0
    fileprivate lazy var timerName: String = {
        return "com.trashout.backgroundtimer.\(self.name)"
    }()
    
    public var eventHandler: ((TimeInterval) -> Void)?
    public var isRunning: Bool = false

    init(name: String) {
        self.name = name
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        eventHandler = nil
        UserDefaults.standard.removeObject(forKey: "\(timerName).terminatedTime")
    }

    func start() {
        guard isRunning else {
            timer.resume()
            notificationCenter.removeObserver(self)
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            isRunning = true
            
            return
        }
    }
    
    func stop() {
        guard !isRunning else {
            timer.suspend()
            notificationCenter.removeObserver(self)
            currentTime = -1
            
            isRunning = false
            return
        }
    }
}

// MARK: - Actions
extension BackgroundTimer {
    @objc func appMovedToBackground() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "\(timerName).terminatedTime")
    }
    
    @objc func appMovedToForeground() {
        if let terminatedTime = UserDefaults.standard.object(forKey: "\(timerName).terminatedTime") as? TimeInterval {
            let terminatedDate = Date(timeIntervalSince1970: terminatedTime)
            let currentDate = Date()
            let calendar = Calendar.current
            
            if let dateDifference = calendar.dateComponents([.second], from: terminatedDate, to: currentDate).second {
                self.currentTime += TimeInterval(dateDifference)
            }
            
            UserDefaults.standard.removeObject(forKey: "\(timerName).terminatedTime")
        }
    }
}
