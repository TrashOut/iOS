//
//  OfflineDumpManagerType.swift
//  OfflineDumpManagerType
//
//  Created by Juraj Macák on 27/07/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import Foundation

typealias BoolClosure = (Bool) -> Void

protocol OfflineDumpManagerType: AnyObject {
    func uploadCachedOfflineDumps(completion: BoolClosure?)
}
