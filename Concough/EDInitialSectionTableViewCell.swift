//
//  EDInitialSectionTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-12-20.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class EDInitialSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var entranceImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
                
        self.entranceImageView.layer.cornerRadius = self.entranceImageView.layer.frame.width / 2.0
        //self.entranceImageView.layer.borderWidth = 1.0
        //self.entranceImageView.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.3).CGColor
        self.entranceImageView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    internal func configureCell(title title: String, subTitle: String) {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
    }
}
