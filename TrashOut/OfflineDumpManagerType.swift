//
//  OfflineDumpManagerType.swift
//  OfflineDumpManagerType
//
//  Created by Juraj Macák on 27/07/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import Foundation

protocol OfflineDumpManagerType: AnyObject {
    var didUploadOfflineDump: VoidClosure? { get set }

    func uploadOfflineDumps()
}
