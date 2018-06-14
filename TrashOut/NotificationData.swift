//
//  NotificationData.swift
//  TrashOut-Prod
//
//  Created by Grünvaldský Dávid on 13/06/2018.
//  Copyright © 2018 TrashOut NGO. All rights reserved.
//

import Foundation

/// Notification data.
class NotificationData {
    
    /// Type.
    var type: NotificationTargetType
    
    /// Report type.
    var reportType: NotificationReportType?
    
    /// ID.
    var id: Int?
    
    /// Message title.
    var title: String?
    
    /// Message body.
    var message: String?
    
    /// Action handler.
    var actionHandler: (() -> Void)? = nil
    
    init(type: NotificationTargetType, reportType: NotificationReportType?, id: Int?, title: String?, message: String?, actionHandler: (() -> Void)? = nil) {
        self.type          = type
        self.reportType    = reportType
        self.id            = id
        self.title         = title
        self.message       = message
        self.actionHandler = actionHandler
    }
}
