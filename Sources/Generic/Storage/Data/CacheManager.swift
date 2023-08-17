//
//  CacheManager.swift
//  TrashOut
//
//  Created by Juraj Macák on 14/07/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import Foundation

class CacheManager {

    enum Key {
        static let OFFLINE_DUMP_KEY = "OfflineDumpKey"
    }

    public static let shared = CacheManager()
    private init() {}

    var offlineDumps: [OfflineDump] {
        get {
            let result: [OfflineDump] = decode(data: retrieveData(from: Key.OFFLINE_DUMP_KEY)) ?? []
            return result
        }
        set {
            save(newValue, for: Key.OFFLINE_DUMP_KEY)
        }
    }

}

// MARK: - Privates

extension CacheManager {

    private func retrieveData(from key: String) -> Data? {
        return UserDefaults.standard.data(forKey: key)
    }

    private func save<T: Codable>(_ object: T, for key: String) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(object)

        UserDefaults.standard.set(data, forKey: key)
    }

    private func decode<T:Codable>(data: Data?) -> T? {
        guard let data = data else { return nil }

        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }

}
