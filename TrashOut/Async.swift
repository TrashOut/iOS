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

/**
Helper methods for executing blocks.

Inspired by node.js Async library

- TODO: implement some async methods
*/
open class Async {
	
	// MARK: - Types
	
	/// Error callback type
	public typealias ErrorBlock = (Error) -> ()
	/// Execution block type
	public typealias Block = (_ completion: @escaping ()->(), _ failure: @escaping (Error)->()  ) -> ()
	
	// MARK: - Public
	
	/**
	Execute in waterfall order.
	
	- Parameter blocks: List of blocks to be executed in order
	- Parameter failure: Callback for error
	*/
	open static func waterfall (_ blocks: [Block], failure: @escaping ErrorBlock) {
		self.executeWaterfall(blocks, index: 0, failure: failure)
	}
	
	// MARK: - Private
	
	/**
	Execute block at given index, recursive on success, ends on failure
	*/
	internal static func executeWaterfall (_ blocks: [Block], index: Int, failure: @escaping ErrorBlock) {
		guard index < blocks.count else { return }
		let block = blocks[index]
		block({ _ in
			Async.executeWaterfall(blocks, index: index + 1, failure:  failure)
		}, failure)
	}
	
	
	
	
}
