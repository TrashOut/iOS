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

import Foundation

enum Link {
    
    case termsAndConditions
    case privacyPolicy
    case frequentlyAskedQuestions
    case supportUs
    case adminHome
    case dump(id: Int)
    case event(id: Int)
    case addJunkyard
    case editJunkyard(id: Int)
    case sendEmail(to: String)
    case call(phone: String)
    
    var url: URL {
        let urlString: String
        switch self {
        case .termsAndConditions:
            urlString = "https://www.trashout.ngo/terms"
        case .privacyPolicy:
            urlString = "https://www.trashout.ngo/policy"
        case .frequentlyAskedQuestions:
            urlString = selectByLanguage(faqByLanguage)
        case .supportUs:
            urlString = selectByLanguage(supportUsByLanguage)
        case .adminHome:
            #if STAGE
                urlString = "https://dev-admin.trashout.ngo"
            #else
                urlString = "https://admin.trashout.ngo"
            #endif
        case .dump(let id):
            return Link.adminHome.url.appendingPathComponent("/trash-management/detail/\(id)")
        case .event(let id):
            return Link.adminHome.url.appendingPathComponent("/events/detail/\(id)")
        case .addJunkyard:
            return Link.adminHome.url.appendingPathComponent("/collection-points/create")
        case .editJunkyard(let id):
            return Link.adminHome.url.appendingPathComponent("/collection-points/update/\(id)")
        case .sendEmail(let to):
            urlString = "mailto:\(to)"
        case .call(let phone):
            urlString = "telprompt://\(phone)"
        }
        return URL(string: urlString)!
    }
}

fileprivate let faqByLanguage = [
    "cs": "https://www.trashout.ngo/cs/faq",
    "de": "https://www.trashout.ngo/de/faq",
    "en": "https://www.trashout.ngo/faq",
    "es": "https://www.trashout.ngo/es-ar/faq",
    "fr": "https://www.trashout.ngo/fr/faq",
    "hu": "https://www.trashout.ngo/hu/faq",
    "it": "https://www.trashout.ngo/it/faq",
    "pt": "https://www.trashout.ngo/pt/faq",
    "ru": "https://www.trashout.ngo/ru/faq",
    "sk": "https://www.trashout.ngo/sk/faq"
]

fileprivate let supportUsByLanguage = [
    "cs": "https://www.trashout.ngo/cs/projectsupport",
    "en": "https://www.trashout.ngo/projectsupport",
    "es": "https://www.trashout.ngo/es-ar/projectsupport",
    "de": "https://www.trashout.ngo/de/projectsupport",
    "fr": "https://www.trashout.ngo/fr/projectsupport",
    "hu": "https://www.trashout.ngo/hu/projectsupport",
    "it": "https://www.trashout.ngo/it/projectsupport",
    "pt": "https://www.trashout.ngo/pt/projectsupport",
    "ru": "https://www.trashout.ngo/ru/projectsupport",
    "sk": "https://www.trashout.ngo/sk/projectsupport"
]

fileprivate func selectByLanguage(_ options: [String: String]) -> String {
    assert(options["en"] != nil)
    let languages = Locale.preferredLanguages.map { String($0.prefix(2)) }
    return options[languages.first { options[$0] != nil } ?? "en"]!
}
