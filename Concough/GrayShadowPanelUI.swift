//
//  GrayShadowPanelUI.swift
//  Concough
//
//  Created by Owner on 2018-05-19.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit

class GrayShadowPanelUI: UIView {
    override func awakeFromNib() {
        layer.borderWidth = 0.8
        layer.borderColor = UIColor(white: 0.90, alpha: 1).CGColor
        layer.cornerRadius = 10.0
        
//        layer.shadowColor = UIColor(white: 0.95, alpha: 1).CGColor
//        layer.shadowOpacity = 0.8
//        layer.shadowRadius = 4.0
//        layer.shadowOffset = CGSizeMake(0.0, 0.0)
        
    }
}
