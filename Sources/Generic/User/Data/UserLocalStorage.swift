//
//  UserLocalResource.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 17/08/2023.
//  Copyright © 2023 TrashOut NGO. All rights reserved.
//

import Combine

final class UserLocalStorage: UserDefaultsStorage {

    @UserDefaultValue("user.key", defaultValue: nil)
    var user: User?

    lazy var publisher: AnyPublisher<User?, Never> = {
        _user.publisher
    }()

    func get() -> User? {
        user
    }

    func set(_ object: User) {
        user = object
    }

    func remove() {
        user = nil
    }
}
