//
//  UserAssembly.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 17/08/2023.
//  Copyright © 2023 TrashOut NGO. All rights reserved.
//

import Swinject
import SwinjectAutoregistration

class UserAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(
            UserRepository.self,
            initializer: UserRepositoryImpl.init
        )
        .inObjectScope(.container)
    }
}
