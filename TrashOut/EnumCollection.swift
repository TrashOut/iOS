//
//  EnumCollection.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 25.01.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation


/**
Add listing values for hashable enums

https://theswiftdev.com/2017/01/05/18-swift-gist-generic-allvalues-for-enums/
*/
public protocol EnumCollection: CaseIterable {
	static var allValues: [Self] { get }
}


extension EnumCollection {
	static var allValues: [Self] {
        return Array(allCases)
	}
}
