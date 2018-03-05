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
public protocol EnumCollection: Hashable {
	static var allValues: [Self] { get }
}


extension EnumCollection {

	static func cases() -> AnySequence<Self> {
		typealias S = Self
		return AnySequence { () -> AnyIterator<S> in
			var raw = 0
			return AnyIterator {
				let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee } }
				guard current.hashValue == raw else { return nil }
				raw += 1
				return current
			}
		}
	}

	public static var allValues: [Self] {
		return Array(self.cases())
	}
}
