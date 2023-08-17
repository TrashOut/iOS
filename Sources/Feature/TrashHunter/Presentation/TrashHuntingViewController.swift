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

class TrashHuntingViewController: UIViewController {

	@IBOutlet var lblTrashHunter: UILabel!
	@IBOutlet var lblTrashHunterInfo: UILabel!

	@IBOutlet var btnMore: UIButton!
	@IBOutlet var btnStop: UIButton!

	@IBOutlet var countdown: ClockCountdownView!

	@IBOutlet var lblDumpsFound: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.translatesAutoresizingMaskIntoConstraints = false

		lblTrashHunter.text = "trashHunter".localized
		lblTrashHunter.textColor = Theme.current.color.green
		lblTrashHunterInfo.text = "trashHunter.turnedOnInfo".localized
		lblTrashHunterInfo.textColor = Theme.current.color.lightGray

		btnMore.theme()
        btnMore.setTitle("trash.status.more".localized.uppercased(), for: .normal)
		btnStop.theme()
		btnStop.backgroundColor = Theme.current.color.red
		btnStop.setTitle("trashHunter.stopHunting".localized.uppercased(), for: .normal)

		lblDumpsFound.text = "trashHunter.lookingForDumps".localized

		countdown.bounds = CGRect.init(x: 0, y: 0, width: 100, height: 100)
        if let hunter = TrashHunter.hunter {
            let interval = hunter.config.duration.duration
            countdown.setTimer(value: interval)
            countdown.startTimer()
            countdown.onFinish = stop
        }
	}

	func refresh() {
		guard let hunter = TrashHunter.hunter else { return }
		let dumpsCount = hunter.lastTrashes.count
		UIView.transition(with: lblDumpsFound, duration: 0.35, options: [.transitionCrossDissolve], animations: { 
			self.lblDumpsFound.text = "trash.foundDumps_X".localized(dumpsCount)
		}, completion: nil)

	}


	@IBAction func more() {
		TrashHunter.hunter?.openList()
	}

	@IBAction func stop() {
        countdown.stopTimer()
        
		guard let parent = self.view.superview else {
			TrashHunter.hunter?.end()
			return
		}
		UIView.transition(with: parent, duration: 0.35, options: [.transitionFlipFromRight], animations: {
			TrashHunter.hunter?.end()
		}, completion: nil)

	}

}
