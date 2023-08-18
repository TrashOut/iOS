//
//  MapViewSwitch.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 06/03/2022.
//  Copyright © 2022 TrashOut NGO. All rights reserved.
//

import UIKit
import MapKit

// MARK: - Privates

protocol WithSatelliteMapTypeSwitch where Self: UIViewController {
    var map: MKMapView! { get }
    
    func presentSwitcher(position: CGPoint)
}

extension WithSatelliteMapTypeSwitch {
    
    func presentSwitcher(position: CGPoint = CGPoint(x: 16, y: 16)) {
        let mapSwitch = MapSwitchView(frame: .init(x: position.x, y: position.y, width: map.frame.width / 2.0, height: 40))

        mapSwitch.setup(MapSwitchView.Model(typeAction: { [weak self] selectedMapType in
            switch selectedMapType {
            case .satellite:
                self?.map.mapType = .satellite

            case .standard:
                self?.map.mapType = .standard
            }
        }))
        
        map?.addSubview(mapSwitch)
    }
    
}
