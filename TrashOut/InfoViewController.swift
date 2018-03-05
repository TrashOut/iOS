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

class InfoViewController: ViewController {

    @IBOutlet var lblInfoAboutApp: UILabel!
    @IBOutlet var lblVersionDate: UILabel!
    @IBOutlet var lblVersionNumber: UILabel!

    @IBOutlet var btnFeedback: UIButton!
    @IBOutlet var btnPrivace: UIButton!
    @IBOutlet var btnTerms: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "info.header.aboutApp".localized

        lblVersionNumber.textColor = Theme.current.color.lightGray

        btnFeedback.setTitle("info.feedbackAndSupport".localized.uppercased(with: .current), for: .normal)
        btnFeedback.theme()
        btnPrivace.setTitle("info.privatePolicy".localized.uppercased(with: .current), for: .normal)
        btnPrivace.theme()
        btnTerms.setTitle("info.termsAndConditions".localized.uppercased(with: .current), for: .normal)
        btnTerms.theme()

        lblInfoAboutApp.text = "info.aboutApp".localized
        
		let df = DateFormatter()
		df.timeStyle = .none
		df.dateStyle = .long
        
        /*
        let date = try! Date().at(unitsWithValues: [
			Calendar.Component.day: 1,
			Calendar.Component.month: 4,
			Calendar.Component.year: 2017
		])*/
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let date = formatter.date(from: "2018/02/12 00:00")
        
		lblVersionDate.text = String.init(format: "info.appVerison_X".localized, df.string(from: date!))

		let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
		let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
		lblVersionNumber.text = String.init(format: "%@.%@ (iOS)", version, build)

    }
    
    @IBAction func showPrivacePolicy(_ sender: Any) {
		guard let url = URL(string: "http://www.trashout.ngo/policy") else { return }
		UIApplication.shared.openURL(url)
    }

    @IBAction func showTermsAndConditions(_ sender: Any) {
		guard let url = URL(string: "http://www.trashout.ngo/terms") else { return }
		UIApplication.shared.openURL(url)
    }
    
    @IBAction func showFeedback(_ sender: Any) {
        let email = "feedback@trashout.ngo"
        guard let url = URL(string: "mailto:\(email)") else { return }
        UIApplication.shared.openURL(url)
    }
}
