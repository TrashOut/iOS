//
//  UserRepositoryImpl.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 17/08/2023.
//  Copyright © 2023 TrashOut NGO. All rights reserved.
//

import Combine
import Foundation

final class UserRepositoryImpl: UserRepository {

    @Inject private var localStorage: UserLocalStorage

    private lazy var networking: Networking = {
        Networking.instance
    }()

    var activeUser: User? {
        localStorage.get()
    }

    func userPublisher() -> AnyPublisher<User?, Error> {
        Future<User?, Error> { [weak self] seal in
            if Reachability.isConnectedToNetwork() {
                self?.loadDBMe { user, error in
                    if let error {
                        seal(.failure(error))
                    } else {
                        if let user {
                            self?.localStorage.set(user)
                        }
                        seal(.success(user))
                    }
                }
            } else {
                seal(.success(self?.localStorage.user))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Private

extension UserRepositoryImpl {

    private func loadDBMe(callback: @escaping (User?, Error?) -> ()) {
        networking.userMe(callback: { (user, error) in
            if let e = error as NSError?, e.code == 404 {
                callback(nil, error)
            } else {
                guard let user = user, error == nil else {
                    callback(nil, error)
                    return
                }
                callback(user, error)
            }
        })
    }
}
