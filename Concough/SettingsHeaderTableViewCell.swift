//
//  SettingsHeaderTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-02-03.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class SettingsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastChangedlabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    override func drawRect(rect: CGRect) {
        self.profileImageView.layer.cornerRadius = self.profileImageView.layer.frame.height / 2.0
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.borderColor = UIColor(netHex: 0xEEEEEE, alpha: 1.0).CGColor
        self.profileImageView.layer.borderWidth = 0.8
    }
    
    internal func configureCell(fullname fullname: String, username: String, lastChanged: NSDate, isEditing: Bool) {
        self.fullNameLabel.text = fullname
        self.lastChangedlabel.text = "آخرین بروز رسانی: " + FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(lastChanged)
     
        self.usernameLabel.text = "(\(username))"
        
        if isEditing {
            editButton.setTitle("اتمام ویرایش", forState: .Normal)
        } else {
            editButton.setTitle("ویرایش اطلاعات", forState: .Normal)
        }
    }
}
