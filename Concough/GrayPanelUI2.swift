//
//  GrayPanelUI2.swift
//  Concough
//
//  Created by Owner on 2017-09-21.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class GrayPanelUI2: UIView {
    
    override func awakeFromNib() {
        layer.cornerRadius = 3
        //layer.masksToBounds = true
//        layer.borderColor = UIColor(white: 0.95, alpha: 1).CGColor
//        layer.borderWidth = 1.0
        
        layer.shadowColor = UIColor(white: 0.95, alpha: 1).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 4.0
        layer.shadowOffset = CGSizeMake(0.0, 0.0)
        
    }
    
}
