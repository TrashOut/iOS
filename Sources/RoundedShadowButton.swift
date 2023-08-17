//
//  RoundedShadowButton.swift
//  TrashOut
//
//  Created by Jakub Cizek on 17/10/2017.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {
	
	var shadowLayer: CAShapeLayer!
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if shadowLayer == nil {
			shadowLayer = CAShapeLayer()
			shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height/2).cgPath
			shadowLayer.fillColor = UIColor.white.cgColor
			
			shadowLayer.shadowColor = UIColor.darkGray.cgColor
			shadowLayer.shadowPath = shadowLayer.path
			shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
			shadowLayer.shadowOpacity = 0.8
			shadowLayer.shadowRadius = 2
			
			layer.insertSublayer(shadowLayer, at: 0)
			//layer.insertSublayer(shadowLayer, below: nil) // also works
		}
	}
	
}
