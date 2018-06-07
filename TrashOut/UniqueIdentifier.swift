//
//  UniqueIdentifier.swift
//  TrashOut-Prod
//
//  Created by Grünvaldský Dávid on 05/06/2018.
//  Copyright © 2018 TrashOut NGO. All rights reserved.
//

import Foundation
import Keychain

class UniqueIdentifier {
    
    private static let kKeychainUniqueIdentifier = "kKeychainUniqueIdentifier"
    
    static var identifier: String? {
        get {
            return Keychain.load(kKeychainUniqueIdentifier)
        }
        
        set {
            guard let identifier = newValue else {
                _ = Keychain.delete(kKeychainUniqueIdentifier)
                return
            }
            
            _ = Keychain.save(identifier, forKey: kKeychainUniqueIdentifier)
        }
    }
}
