//
//  EDPurchasedSectionTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-01-10.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class EDPurchasedSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var downloadCountLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var purchaseTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    override func drawRect(rect: CGRect) {
        self.downloadButton.layer.cornerRadius = 3.0
        self.downloadButton.layer.masksToBounds = true
    }
    
    internal func configureCell(purchased purchased: EntrancePrurchasedStructure) {
        self.downloadCountLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(purchased.downloaded!)! + " دستگاه"
        self.purchaseTime.text = FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(purchased.created!)
    }
}
