//
//  WhitePanelUI.swift
//  Concough
//
//  Created by Owner on 2016-11-22.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class WhitePanelUI: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderColor = UIColor(white: 0.75, alpha: 1).CGColor
        layer.borderWidth = 1.0
        
        layer.shadowColor = UIColor(white: 0.8, alpha: 1).CGColor
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 3.0
        layer.shadowOffset = CGSizeMake(0.0, 0.0)
        
    }

}
