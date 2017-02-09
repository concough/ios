//
//  EDDownloadedTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-01-10.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class EDDownloadedTableViewCell: UITableViewCell {

    @IBOutlet weak var jumpToFavoritesButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    override func drawRect(rect: CGRect) {
        self.jumpToFavoritesButton.layer.cornerRadius = 3.0
        self.jumpToFavoritesButton.layer.masksToBounds = true
        self.jumpToFavoritesButton.layer.borderColor = self.jumpToFavoritesButton.titleColorForState(.Normal)?.CGColor
        self.jumpToFavoritesButton.layer.borderWidth = 1.0
    }
}
