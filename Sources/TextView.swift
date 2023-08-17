//
//  TextField.swift
//  TrashOut
//
//  Created by Lukáš Andrlik on 23/11/2017.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//
import UIKit

extension UITextView {

    func requiredHighlightTextField(){
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
    }
    
    func removeRequiredHighlightTextField(){
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 0
    }
}
