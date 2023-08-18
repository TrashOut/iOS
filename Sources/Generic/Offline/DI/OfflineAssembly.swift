//
//  OfflineAssembly.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 17/08/2023.
//  Copyright © 2023 TrashOut NGO. All rights reserved.
//

import Swinject
import SwinjectAutoregistration

class OfflineAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(
            OfflineDumpStorage.self,
            initializer: OfflineDumpStorage.init
        )

        container.autoregister(
            OfflineDumpManager.self,
            initializer: OfflineDumpManager.init
        )
    }
}
