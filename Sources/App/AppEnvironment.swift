//
//  AppEnvironment.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 05/02/2022.
//  Copyright © 2022 TrashOut NGO. All rights reserved.
//

enum AppEnvironment {

    case alpha
    case beta
    case production

}

// MARK: - Type

extension AppEnvironment {

    static var type: AppEnvironment {
#if DEBUG
        return AppEnvironment.alpha
#elseif BETA
        return AppEnvironment.beta
#else
        return AppEnvironment.production
#endif
    }

}

extension AppEnvironment {

    /// Execute provided task just for specified App Environemnt type
    /// - Parameters:
    ///   - task: Executable function
    ///   - type: App Environment Type (alpha, beta, production)
    ///   - optionalTask: Task performed if type is not valid with current App environment
    static func execute(task: VoidClosure, for type: AppEnvironment, optionalTask: VoidClosure? = nil) {
        debugPrint("Current type: \(self.type) | Task suitable for type: \(type)")
        guard type == AppEnvironment.type else {
            optionalTask?()
            return
        }

        task()
    }

    /// Execute provided task just for specified App Environemnt type
    /// - Parameters:
    ///   - task: Executable function
    ///   - types: App Environment Types (alpha, beta, production)
    ///   - optionalTask: Task performed if type is not valid with current App environment
    static func execute(task: VoidClosure, for types: [AppEnvironment], optionalTask: VoidClosure? = nil) {
        debugPrint("Current type: \(self.type) | Task suitable for type: \(types)")

        let currentType = self.type
        guard types.contains(where: { $0 == currentType } ) else {
            optionalTask?()
            return
        }

        task()
    }

}
