//
//  UserRepository.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 17/08/2023.
//  Copyright © 2023 TrashOut NGO. All rights reserved.
//

import Combine

protocol UserRepository {

    var activeUser: User? { get }

    /// Get user from remote datasource when internet online or cached from local datasrouce
    ///
    /// When the user is successfully fetched from remote resource, it is automatic cached into local repository and retrieved in case the internet is broken.
    ///
    /// - Returns: User object publisher
    func userPublisher() -> AnyPublisher<User?, Error>
}
