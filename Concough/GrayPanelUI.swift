//
//  WhitePanelUI.swift
//  Concough
//
//  Created by Owner on 2016-11-22.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class GrayPanelUI: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = 5
        //layer.masksToBounds = true
        layer.borderColor = UIColor(white: 0.85, alpha: 1).CGColor
        layer.borderWidth = 1.0
        
        layer.shadowColor = UIColor(white: 0.9, alpha: 1).CGColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSizeMake(0.0, 0.0)
        
    }

}
