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

extension Junkyard.JunkyardType {


	var localizedName: String {
		switch self {

		case .paper: return "collectionPoint.types.paper".localized
		//case .glass: return "glass".localized
		case .glassAll: return "collectionPoint.types.glassAll".localized
		case .glassGreen: return "collectionPoint.types.glassGreen".localized
		case .glassGold: return "collectionPoint.types.glassGold".localized
		case .glassWhite: return "collectionPoint.types.glassWhite".localized
		case .metal: return "collectionPoint.types.metal".localized
		case .plastic: return "collectionPoint.types.plastic".localized
		case .dangerous: return "collectionPoint.types.dangerous".localized
		case .cardboard: return "collectionPoint.types.cardboard".localized
		case .clothes: return "collectionPoint.types.clothes".localized
		case .biodegradable: return "collectionPoint.types.biodegradable".localized
		case .electronic: return "collectionPoint.types.electronic".localized
		case .everything: return "collectionPoint.types.everything".localized
		case .recyclables: return "collectionPoint.types.recyclables".localized

		case .wiredGlass: return "collectionPoint.types.wiredGlass".localized
		case .battery: return "collectionPoint.types.battery".localized
		case .tires: return "collectionPoint.types.tires".localized
		case .iron: return "collectionPoint.types.iron".localized
		case .woodenAndUpholsteredFurniture: return "collectionPoint.types.woodenAndUpholsteredFurniture".localized
		case .carpets: return "collectionPoint.types.carpets".localized
		case .wooden: return "collectionPoint.types.wooden".localized
		case .window: return "collectionPoint.types.window".localized
		case .buildingRubble: return "collectionPoint.types.buildingRubble".localized
		case .oil: return "collectionPoint.types.oil".localized
		case .fluorescentLamps: return "collectionPoint.types.fluorescentLamps".localized
		case .neonLamps: return "collectionPoint.types.neonLamps".localized
		case .lightBulbs: return "collectionPoint.types.lightBulbs".localized
		case .color: return "collectionPoint.types.color".localized
		case .thinner: return "collectionPoint.types.thinner".localized
		case .mirror: return "collectionPoint.types.mirror".localized
		case .carParts: return "collectionPoint.types.carParts".localized
		case .medicines: return "collectionPoint.types.medicines".localized
		case .materialsFromBituminousPaper: return "collectionPoint.types.materialsFromBituminousPaper".localized
		case .eternitCoverings: return "collectionPoint.types.eternitCoverings".localized
		case .asbestos: return "collectionPoint.types.asbestos".localized
		case .fireplaces: return "collectionPoint.types.fireplaces".localized
		case .slag: return "collectionPoint.types.slag".localized
		case .glassWool: return "collectionPoint.types.glassWool".localized
		case .cinder: return "collectionPoint.types.cinder".localized
		case .asphalt: return "collectionPoint.types.asphalt".localized
		case .bitumenPaper: return "collectionPoint.types.bitumenPaper".localized

		case .undefined: fallthrough
		default:
			return "global.undefined".localized
		}
	}

}

extension Junkyard.Category {

	var localizedName: String {
		switch self {
		case .dustbin: return "collectionPoint.size.recyclingBin".localized
		case .scrapyard: return "collectionPoint.size.recyclingCenter".localized
		}
	}
}
