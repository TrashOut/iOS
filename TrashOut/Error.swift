//
// TrashOut
// Copyright 2017 TrashOut NGO. All rights reserved.
// License GNU GPLv3
//

/**
 * TrashOut is an environmental project that teaches people how to recycle
 * and showcases the worst way of handling waste - illegal dumping. All you need is a smart phone.
 *
 *
 * There are 10 types of programmers - those who are helping TrashOut and those who are not.
 * Clean up our code, so we can clean up our planet.
 * Get in touch with us: help@trashout.ngo
 *
 * Copyright 2017 TrashOut, n.f.
 *
 * This file is part of the TrashOut project.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * See the GNU General Public License for more details: <https://www.gnu.org/licenses/>.
*/

import Foundation


extension NSError {

	static var unknown: Error {
		return NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
	}
    
    static var signUp: Error {
        return NSError.init(domain: "cz.trashout.TrashOut", code: 501, userInfo: [NSLocalizedDescriptionKey: "global.register.identityError".localized])
    }
    
    static var login: Error {
        return NSError.init(domain: "cz.trashout.TrashOut", code: 502, userInfo: [NSLocalizedDescriptionKey: "global.login.errorNoUser".localized])
    }
	
    static var fetch: Error {
        return NSError.init(domain: "cz.trashout.TrashOut", code: 1009, userInfo: [NSLocalizedDescriptionKey: "global.fetchError".localized])
    }
    
    static var fbLoginResult: Error {
        return NSError.init(domain: "cz.trashout.Trashout.FacebookLogin", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
    }
    
    static var fbProfileData: Error {
        return NSError.init(domain: "cz.trashout.Trashout.FacebookLogin", code: 500, userInfo: [NSLocalizedDescriptionKey: "user.validation.failedToReadFacebookProfile".localized])
    }
    
    static var fbGrantedPermissions: Error {
        return NSError.init(domain: "cz.trashout.Trashout.FacebookLogin", code: 500, userInfo: [NSLocalizedDescriptionKey: "user.validation.facebookNotGrantedPermissionForEmail".localized])
    }
    
    static var fbAccessToken: Error {
        return NSError.init(domain: "cz.trashout.Trashout.FacebookLogin", code: 500, userInfo: [NSLocalizedDescriptionKey: "user.validation.authFbMalformed".localized])
    }
    
    static var fbLinkUser: Error {
        return NSError.init(domain: "cz.trashout.Trashout.FacebookLogin", code: 500, userInfo: [NSLocalizedDescriptionKey: "user.validation.authFbCollision".localized])
    }

    static var firUid: Error {
        return NSError.init(domain: "cz.trashout.Trashout.FacebookLogin", code: 500, userInfo: [NSLocalizedDescriptionKey: "user.validation.firebaseUidNotReceived".localized])
    }
    
    static var firUser: Error {
        return NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "user.validation.noFirebaseUser".localized])
    }
}


// MARK: - Networking error

enum NetworkingError: Error {
    case noInternetConnection
    case apiError
}

// MARK: - Localized extension of networking error
extension NetworkingError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noInternetConnection: return "global.internet.offline".localized
        case .apiError: return "global.error.api.text".localized
        }
    }
}
