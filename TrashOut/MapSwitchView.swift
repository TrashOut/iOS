//
//  MapSwitchView.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 06/03/2022.
//  Copyright © 2022 TrashOut NGO. All rights reserved.
//

import UIKit

// MARK: - Class

final class MapSwitchView: ReusableNibView {

    enum MapType {
        case satellite, standard
    }

    struct Model {
        var typeAction: (MapType) -> Void
    }
    
    @IBOutlet weak var buttonWrapperView: UIView!

    // MARK: - Variable

    private var model: Model?
    private var isSatelliteType: Bool = false

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Setup

    func setup(_ model: Model) {
        self.model = model
        
        updateAppearance(isSatelliteType: isSatelliteType)
    }

    @IBAction func standartButtonPressed(_ sender: Any) {
        isSatelliteType.toggle()
        
        updateAppearance(isSatelliteType: isSatelliteType)
        model?.typeAction(isSatelliteType ? .satellite : .standard)
    }

}

// MARK: - Private

extension MapSwitchView {
    
    private func updateAppearance(isSatelliteType: Bool) {
        buttonWrapperView.backgroundColor = Theme.Color().green.withAlphaComponent(isSatelliteType ? 1.0 : 0.7)
    }
    
}
