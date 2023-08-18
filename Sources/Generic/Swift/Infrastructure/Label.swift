//
//  Label.swift
//  TrashOut
//
//  Created by Lukáš Andrlik on 22/11/2017.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//
import UIKit

extension UILabel {
    
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
    
    func requiredHighlightTextField(){
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
    }
    
    func removeRequiredHighlightTextField(){
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 0
    }
}
