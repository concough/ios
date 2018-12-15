//
//  EentranceLessonExamHistoryItemsHeaderTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-04-14.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit

class FavoriteHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.titleLabel.layer.cornerRadius = 15.0
//        self.titleLabel.layer.masksToBounds = true
//        self.titleLabel.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.4).CGColor
//        self.titleLabel.layer.borderWidth = 0.7
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func configureCell(title title: String) {
        self.titleLabel.text = title
    }
}
