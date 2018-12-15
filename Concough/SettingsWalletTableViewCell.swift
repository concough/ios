//
//  SettingsWalletTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-05-26.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit

class SettingsWalletTableViewCell: UITableViewCell {

    @IBOutlet weak var costLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    override func drawRect(rect: CGRect) {
    }
    
    internal func configureCell(cost cost: Int) {
        self.costLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(cost)!
    }

}
