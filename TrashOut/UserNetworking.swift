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
import Alamofire

extension Networking {

	/**
	Get user using id

	```
	GET /user/:id
	```
	*/
	func user(_ id: Int, callback: @escaping (User?, Error?) -> ()) {
		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/user/\(id)", headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, callback: callback)
			}
		}
	}

	func userMe(callback: @escaping (User?, Error?) -> ()) {
		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/user/me", headers: tokenHeader).responseJSON { [weak self] (response) in
				if let code = response.response?.statusCode, (400..<405).contains(code) {
					let error = NSError.init(domain: "cz.trashout.auth", code: 404, userInfo: [
						NSLocalizedDescriptionKey: "User not found"
						])
					callback(nil, error)
				} else {
					self?.callbackHandler(response: response, callback: callback)
				}
			}
		}
	}

	/**
	```
	{
	  "firstName": "Jim",
	  "lastName": "Raynor",
	  "email": "jim.raynor@sonsofkorhal.com",
	  "info": "Jim Raynor's description goes here.",
	  "birthdate": "2012-04-20T22:00:00.000Z",
	  "created": "2016-11-22T12:57:55.259Z",
	  "active": true,
	  "newsletter": true,
	  "imageKey": "images.key2345",
	  "firebaseId": "JNgNzUH3XdNnmi0IlMbNzR3SMm93",
	  "tokenFCM": "asdfxcvb9876",
	  "facebookUrl": "",
	  "twitterUrl": "",
	  "googlePlusUrl": "",
	  "phoneNumber": "+420123456789",
	  "points": 9000,
	  "reviewed": false,
	  "userRoleId": 1,
	  "areaId": null
	}
	```
	*/
	func createUser(user: User, uid: String, callback: @escaping (User?, Error?) -> ()) {
        var params: Parameters = [:]
		if let fn = user.firstName {
			params["firstName"] = fn
		}
		if let ln = user.lastName {
			params["lastName"] = ln
		}
		if let email = user.email {
			params["email"] = email
		}
		params["uid"] = uid
		params["userRoleId"] = 1

		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/user", method: .post, parameters: params, headers: tokenHeader).responseJSON { [weak self] (response) in

                self?.callbackHandler(response: response, callback: callback)
			}
		}
	}

	func updateUser(user: User, id: Int, uid: String, organizations: [Organization] = [], areas: [Area] = [], image: ProfileImage?, callback: @escaping (User?, Error?) -> ()) {
        var params: Parameters = [:]
        if let fn = user.firstName {
            params["firstName"] = fn
        }
        if let ln = user.lastName {
            params["lastName"] = ln
        }
        if let email = user.email {
            params["email"] = email
        }
		if let phone = user.phone {
			params["phoneNumber"] = phone
		}

        if let image = image {
            params["image"] = ["fullDownloadUrl": image.fullDownloadUrl, "fullStorageLocation": image.storageLocation]
        }
        params["uid"] = uid
		// TODO: FIXME: check how it works at api ( should be maybe 3)
        params["userRoleId"] = 1


		// TODO: FIXME: check how it works at api
//		let orgs = organizations.map { (o) -> Parameters in
//			var p: Parameters = [:]
//			p["organizationId"] = o.id
//			p["organizationRoleId"] = 1
//			return p
//		}
//		params["organizations"] = orgs

		params["eventOrganizer"] = user.eventOrganizer
        params["volunteerCleanup"] = user.volunteerCleanup
        //params["newsletter"] = user.newsletter

		// TODO: FIXME: check how it works at api
//		params["areas"] = areas.map({ area -> Parameters in
//			var p: Parameters = [:]
//			p["id"] = area.id
//			p["userAreaRoleId"] = 1
//			return p
//		})

		Async.waterfall([
			{	[weak self] (completion: @escaping ()->(), failure: @escaping (Error)->()) in
				let orgs = organizations.map { return (id: $0.id, role: 1) }
				self?.setUserOrganizations(user: user, organizations: orgs, callback: { (error) in
					if let error = error {
						failure(error)
					} else {
						completion()
					}
				})
			},
			{ [weak self] (completion: @escaping ()->(), failure: @escaping (Error)->()) in

				UserManager.instance.tokenHeader { tokenHeader in
					guard let base = self?.apiBaseUrl else { return }
					let req = Networking.manager.request("\(base)/user/\(id)", method: .put, parameters: params, headers: tokenHeader)
					print(req.debugDescription)
					req.responseJSON { [weak self] (response) in
						self?.callbackHandler(response: response, callback: callback)
					}
				}
			}], failure: { (error) in
				callback(nil, error)
            }
        )

    }

	func organizations(page: Int, limit: Int, callback: @escaping ([Organization]?, Error?)->()) {
		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/organization/", headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, callback: callback)
			}
		}
	}

	/**
	Set organizations to user
	
	cycle remove/join organization
	*/
	func setUserOrganizations(user: User, organizations: [(id: Int, role: Int)], callback: @escaping (Error?) -> ()) {
			let remove = user.organizations.filter({ (org) -> Bool in
				return organizations.contains(where: { (o: (id: Int, role: Int)) -> Bool in
					o.id == org.id
				}) == false
			})
			let add = organizations.filter({ (org: (id: Int, role: Int)) -> Bool in
				return user.organizations.contains(where: { (o) -> Bool in
					o.id == org.id
				}) == false
			})
			var blocks: [Async.Block] = []

			for org in remove {
				blocks.append({ [weak self] (completion: @escaping ()->(), failure: @escaping (Error)->()) in
					self?.removeOrganization(userId: user.id, organizationId: org.id, callback: { (error) in
						if let error = error {
							failure(error)
						} else {
							completion()
						}
					})
				})
			}
			for org in add {
				blocks.append({ [weak self] (completion: @escaping ()->(), failure: @escaping (Error)->()) in
					self?.joinOrganization(userId: user.id, organizationId: org.id, callback: { (error) in
						if let error = error {
							failure(error)
						} else {
							completion()
						}
					})
				})
			}
			blocks.append({ [weak self] (completion: ()->(), failure: (Error)->()) in
				callback(nil)
				completion()
			})

			Async.waterfall(blocks, failure: { (error) in
				callback(error)
			})
	}

	/**
	```
	POST /organization/:organizationId/user/:userId
	```
	*/
	func joinOrganization(userId: Int, organizationId: Int, callback: @escaping (Error?) -> ()) {
		UserManager.instance.tokenHeader { tokenHeader in
			/*var params: Parameters = [:]
			params["organizationRoleId"] = 1
			Alamofire.request("\(self.apiBaseUrl)/organization/\(organizationId)/user/\(userId)", method: .post, parameters: params, headers: tokenHeader).responseJSON { (response) in
				callback(response.result.error)
			}
            */
            Networking.manager.request("\(self.apiBaseUrl)/user/joinOrganization/\(organizationId)", method: .post, parameters: nil, headers: tokenHeader).responseJSON { (response) in
                callback(response.result.error)
            }
		}
	}

	/**
	```
	DELETE /organization/:organizationId/user/:userId
	```
	*/
	func removeOrganization(userId: Int, organizationId: Int, callback: @escaping (Error?) -> ()) {
		UserManager.instance.tokenHeader { tokenHeader in
            /*
			Alamofire.request("\(self.apiBaseUrl)/organization/\(organizationId)/user/\(userId)", method: .delete, headers: tokenHeader).responseJSON { (response) in
				callback(response.result.error)
			}
            */
            Networking.manager.request("\(self.apiBaseUrl)/user/leaveOrganization/\(organizationId)", method: .delete, parameters: nil, headers: tokenHeader).responseJSON { (response) in
                callback(response.result.error)
            }
		}
	}

	/**
	List activity for user
	
	```
	GET /user/:user/activity
	```
	*/
	func recentActivity(user: Int, page: Int, limit: Int, callback: @escaping ([Activity]?, Error?)->()) {
		var params: Parameters = [:]
		// FIXME: not working
		params["type"] = "trashPoint"
		params["page"] = page
		params["limit"] = limit
		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/user/\(user)/activity", parameters: params, headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, callback: callback)
			}
		}
	}
    
    func userActivity(user: Int, page: Int, limit: Int, callback: @escaping ([Activity]?, Error?)->()) {
        var params: Parameters = [:]
        // FIXME: not working
        params["type"] = "trashPoint"
        params["page"] = page
        params["limit"] = limit
        UserManager.instance.tokenHeader { tokenHeader in
            Networking.manager.request("\(self.apiBaseUrl)/user/\(user)/userActivity", parameters: params, headers: tokenHeader).responseJSON { [weak self] (response) in
                self?.callbackHandler(response: response, callback: callback)
            }
        }
    }

	func addArea(user: Int, area: Area, callback: @escaping (Error?)->()) {
		var params: Parameters = [:]
		params["areaId"] = area.id
		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/user/\(user)/userHasArea", method: .post, parameters: params, headers: tokenHeader).responseJSON {  (response) in
				callback(response.result.error)
			}
		}
	}

	func removeArea(user: Int, area: Area, callback: @escaping (Error?)->()) {
		// TODO: -
		callback(nil)
	}
	
}
