//
//  OfflineDumpLocalResource.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 17/08/2023.
//  Copyright © 2023 TrashOut NGO. All rights reserved.
//

import Combine

final class OfflineDumpStorage: UserDefaultsStorage {

    @UserDefaultValue("offline.dump.key", defaultValue: nil)
    private (set) var offlineDumps: [OfflineDump]?

    var publisher: AnyPublisher<[OfflineDump]?, Never> {
        _offlineDumps.publisher
    }

    func get() -> [OfflineDump]? {
        offlineDumps
    }

    func set(_ object: [OfflineDump]) {
        offlineDumps = object
    }

    func remove() {
        offlineDumps = nil
    }
}
