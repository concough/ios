//
//  ShadowedBorderImageView.swift
//  Concough
//
//  Created by Owner on 2018-04-15.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit

class ShadowedBorderImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        //layer.masksToBounds = true
        layer.borderColor = UIColor(white: 0.8, alpha: 1).CGColor
        layer.borderWidth = 0.5
        
        layer.shadowColor = UIColor(white: 0.85, alpha: 1.0).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 3.0
        layer.shadowOffset = CGSizeMake(0.0, 0.0)
        
    }
    
    override func drawRect(rect: CGRect) {
        
    }

}
