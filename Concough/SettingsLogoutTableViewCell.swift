//
//  SettingsOptionTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-02-03.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class SettingsLogoutTableViewCell: UITableViewCell {

    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    internal func configureCell(optionTitle ot: String, iconName: String) {
        self.optionButton.setTitle(ot, forState: .Normal)
        self.iconImageView.image = UIImage(named: iconName)
    }
}
