//
//  TrashUpdateModel+UI.swift
//  TrashOut
//
//  Created by Lukáš Andrlik on 05/12/2017.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit

extension TrashUpdate.ActivityStatus {
    
    var localizedName: String {
        switch self {
        case .cleaned: return "profile.cleaned".localized
        case .reported: return "profile.reported".localized
        case .updated: return "trash.updated".localized
        }
    }
    
    
    
    var color: UIColor {
        switch self {
        case .cleaned: return Theme.current.color.green
        case .reported: return Theme.current.color.red
        case .updated: return Theme.current.color.orange
        }
    }
    
    var image: UIImage {
        switch self {
        case .cleaned: return #imageLiteral(resourceName: "Cleaned")
        case .reported: return #imageLiteral(resourceName: "Reported")
        case .updated: return #imageLiteral(resourceName: "Updated")
        }
    }
    
    /*
 
     1. jen first name
     
     
     [12:43]
     2. ked som to ja, tak to ma byt len ze “You” namiesto mena
     
     
     [12:45]
     3. Reported (vznikla v databaze) = John reported this dump . Updated (dalsia aktivita)= John updated this dump as still here. Cleaned (v pripade ze bola oznacena za vycistena) = John updated this dump as cleaned.
     
     
     [12:47]
     4. tab bar v profile activities bily
     
     */
    
    static func getActivityCellTitle(trashUpdate: TrashUpdate, action: Action, for name: String) -> String {
        guard let status = trashUpdate.status else { return "" }
        let tuple = (status, action)
        switch tuple {
        case (.cleaned, _):
            return name.capitalized + " " + "trash.updated".localized.lowercased() + " " + "user.activity.title.thisDump".localized + " " + "home.recentActivity.as".localized + " " + "profile.cleaned".localized.lowercased()
        case (.less, _):
            return name.capitalized + " " + ("trash.updated".localized.lowercased()) + " " + "user.activity.title.thisDump".localized  + " " + "home.recentActivity.as".localized + " " + "trash.status.less".localized.lowercased()
        case (.more, _):
            return name.capitalized + " " + ("trash.updated".localized.lowercased()) + " " + "user.activity.title.thisDump".localized + " " + "home.recentActivity.as".localized + " " + "trash.status.more".localized.lowercased()
        case (.stillHere, .update):
            return name.capitalized + " " + ("trash.updated".localized.lowercased()) + " " + "user.activity.title.thisDump".localized + " " + "home.recentActivity.as".localized + " " + "trash.status.stillHere".localized.lowercased()
        case (.stillHere, .join):
            return ""
        case (.stillHere, .create):
            return name.capitalized + " " + "profile.reported".localized.lowercased() + " " + "user.activity.title.thisDump".localized.lowercased()
        }
    }
    
    static func getStatus(trashUpdate: TrashUpdate, action: Action) -> TrashUpdate.ActivityStatus {
        guard let status = trashUpdate.status else { return .updated }
        let tuple = (status, action)
        switch tuple {
        case (.cleaned, _):
            return .cleaned
        case (.less, _):
            return .updated
        case (.more, _):
            return .updated
        case (.stillHere, .update):
            return .updated
        case (.stillHere, .join):
            return .updated
        case (.stillHere, .create):
            return .reported
        }
    }
}
