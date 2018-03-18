//
//  SettingsOptionTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-02-03.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class SettingsOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    internal func configureCell(optionTitle optionTitle: String, type: String, showAccessory: Bool, iconName: String) {
        self.optionButton.setTitle(optionTitle, forState: .Normal)
        self.iconImageView.image = UIImage(named: iconName)
        
        if type == "option" {
            self.optionButton.setTitleColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
//            self.bottomLineView.hidden = true
            self.optionButton.enabled = false
            self.selectionStyle = .None
        } else if type == "normal" {
            self.optionButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            self.optionButton.enabled = false
//            self.bottomLineView.hidden = false
            self.selectionStyle = .Default
        }
        
        if showAccessory == true {
            self.accessoryType = .DisclosureIndicator
        } else {
            self.accessoryType = .None
        }
    }
}
