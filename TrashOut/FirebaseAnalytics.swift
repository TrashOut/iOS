//
//  TrashOut
//  Copyright 2017 TrashOut NGO. All rights reserved.
//  License GNU GPLv3
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

import Firebase

class FirebaseAnalytics {
    
    enum Event: String {
        case showFAQ = "faq_button_about"
        case supportUsFromInfo = "support_us_button_about"
        case supportUsFromDashboard = "support_us_button_dashboard"
        case addJunkyard = "add_collection_point_button"
        case editJunkyard = "edit_collection_point_button"
    }
    
    private init() {}
    
    static func log(_ event: Event) {
        Analytics.logEvent(event.rawValue, parameters: nil)
    }
}
