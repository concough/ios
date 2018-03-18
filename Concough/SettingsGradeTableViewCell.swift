//
//  SettingsGradeTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-02-03.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class SettingsGradeTableViewCell: UITableViewCell {

    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    override func drawRect(rect: CGRect) {
        self.changeButton.layer.cornerRadius = 5.0
        self.changeButton.layer.masksToBounds = true
        self.changeButton.layer.borderColor = self.changeButton.currentTitleColor.CGColor
        self.changeButton.layer.borderWidth = 0.8
    }
    
    internal func configureCell(gradeTitle gradeTitle: String, isEditing: Bool) {
        self.gradeLabel.text = gradeTitle
        
        if isEditing {
            changeButton.hidden = false
        } else {
            changeButton.hidden = true
        }
    }
}
