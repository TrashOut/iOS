//
//  View.swift
//  TrashOut
//
//  Created by Jakub Cizek on 17/10/2017.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
	// Shadow
	@IBInspectable var shadow: Bool {
		get {
			return layer.shadowOpacity > 0.0
		}
		set {
			if newValue == true {
				self.addShadow()
			}
		}
	}
	
	fileprivate func addShadow(shadowColor: CGColor = UIColor.black.cgColor, shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0), shadowOpacity: Float = 0.35, shadowRadius: CGFloat = 4.0) {
		let layer = self.layer
		layer.masksToBounds = false
		
		layer.shadowColor = shadowColor
		layer.shadowOffset = shadowOffset
		layer.shadowRadius = shadowRadius
		layer.shadowOpacity = shadowOpacity
		layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
		
		let backgroundColor = self.backgroundColor?.cgColor
		self.backgroundColor = nil
		layer.backgroundColor =  backgroundColor
	}
	

    // Circle button shadow
    var circleButtonShadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow(shadowColor: UIColor.black.cgColor, shadowOffset: CGSize(width: 0.0, height: 20.0), shadowOpacity: 0.25, shadowRadius: 10.0)
            }
        }
    }
    
	// Corner radius
	@IBInspectable var circle: Bool {
		get {
			return layer.cornerRadius == self.bounds.width*0.5
		}
		set {
			if newValue == true {
				self.cornerRadius = self.bounds.width*0.5
			}
		}
	}
	
	@IBInspectable var cornerRadius: CGFloat {
		get {
			return self.layer.cornerRadius
		}
		
		set {
			self.layer.cornerRadius = newValue
		}
	}
	
	
	// Borders
	// Border width
	@IBInspectable
	public var borderWidth: CGFloat {
		set {
			layer.borderWidth = newValue
		}
		
		get {
			return layer.borderWidth
		}
	}
	
	// Border color
	@IBInspectable
	public var borderColor: UIColor? {
		set {
			layer.borderColor = newValue?.cgColor
		}
		
		get {
			if let borderColor = layer.borderColor {
				return UIColor(cgColor: borderColor)
			}
			return nil
		}
	}
    
    // View visibility
    public func isVisible(view: UIView) -> Bool {
        
        if view.window == nil {
            return false
        }
        
        var currentView: UIView = view
        while let superview = currentView.superview {
            
            if (superview.bounds).intersects(currentView.frame) == false {
                return false;
            }
            
            if currentView.isHidden {
                return false
            }
            
            currentView = superview
        }
        
        return true
    }
}
