//
//  AEDBasicTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-12-26.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class AEDBasicTableViewCell: UITableViewCell {

    @IBOutlet weak var orgYearLabel: UILabel!
    @IBOutlet weak var extraDataLabel: UILabel!
    @IBOutlet weak var buyCountLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var BottonLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    internal func configureCell(indexPath indexPath: NSIndexPath, esetTitle: String, entrance: ArchiveEntranceStructure, hiddenLine: Bool = false) {
        self.orgYearLabel.text = "\(esetTitle) \(entrance.organization!) " + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.year!)!
        
        self.buyCountLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.buyCount!)! + " خرید"
        self.publishedDateLabel.text = FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(entrance.lastPablished!)
        
        if let extraData = entrance.extraData {
            var s = ""
            for (key, item) in extraData {
                s += "\(key): \(item.stringValue)" + " - "
            }
            
            if s.characters.count > 3 {
                s = s.substringToIndex(s.endIndex.advancedBy(-3))
            }
            self.extraDataLabel.text = s
        }
        
        if hiddenLine == true {
            self.BottonLineView.hidden = true
        }
    }
}
