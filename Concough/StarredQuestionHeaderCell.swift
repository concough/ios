//
//  StarredQuestionHeader.swift
//  Concough
//
//  Created by Owner on 2017-01-21.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class StarredQuestionHeaderCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLable: UILabel!
    @IBOutlet weak var headerMainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.countLable.layer.cornerRadius = self.countLable.layer.frame.width / 2.0
        self.countLable.layer.masksToBounds = true
        
        //self.titleLabel.textColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
    }
    
    override func prepareForReuse() {
        //self.headerMainView.backgroundColor = UIColor(netHex: 0xEEEEEE, alpha: 1.0)
    }
    
    override func drawRect(rect: CGRect) {
    }
    
    internal func configureHeader(title title: String, count: String) {
        self.titleLabel.text = title
        self.countLable.text = count
        
    }
    
}
