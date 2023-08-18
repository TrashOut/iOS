//
//  AssemblyList.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 17/08/2023.
//  Copyright © 2023 TrashOut NGO. All rights reserved.
//

import Swinject

let appAssemblyList: [Assembly] = {[
    OfflineAssembly(),
    UserAssembly()
]}()