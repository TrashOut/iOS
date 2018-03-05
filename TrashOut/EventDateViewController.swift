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

class EventDateViewController: ViewController {

    @IBOutlet var dateSelector: UIDatePicker!

    weak var writeStartDateBackDelegate: WriteStartDateBack? = nil
    weak var writeEndDateBackDelegate: WriteEndDateBack? = nil

    var date: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "event.create.setDate".localized
        navigationItem.hidesBackButton = true

        let sendButton = UIBarButtonItem(title: "global.done".localized, style: .plain, target: self, action: #selector(savePlace))
        navigationItem.rightBarButtonItem = sendButton

		dateSelector.minimumDate = date
    }

    // MARK: - Actions

    /**
    Go to previous controller
    */
    func savePlace() {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func dateSelectorChanged(_ sender: UIDatePicker) {
        writeStartDateBackDelegate?.writeStartDateBack(value: displayTheDate(theDate: calculateNewDate()), date: calculateNewDate())
        writeEndDateBackDelegate?.writeEndDateBack(value: displayTheDate(theDate: calculateNewDate()), date: calculateNewDate())
    }

    /**
    Display the date in chosen format
    */
    private func displayTheDate(theDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd. MM. YYYY hh:mm"
        let strDate = dateFormatter.string(from: theDate)
        return strDate
    }

    /**
    Calculate date from date picker
    */
    private func calculateNewDate() -> Date {
        let date = dateSelector.date
        let calendar = NSCalendar.current
        let components = DateComponents()
        let newDate = calendar.date(byAdding: components, to: date)
        return newDate!
    }

}
