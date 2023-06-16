//
//  EMDEntranceItemTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-05-21.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

class EMDEntranceItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var buyCountStackView: UIStackView!
    @IBOutlet weak var buyCountLabel: UILabel!
    @IBOutlet weak var buyedImageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
    }
    
    internal func configureCell(entrance entrance: JSON) {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        let unique_id = entrance["unique_key"].stringValue
        
        var buyed = false
        if EntranceModelHandler.existById(id: unique_id, username: username) {
            buyed = true
        }

        if buyed {
            self.yearLabel.textColor = UIColor(netHex: GREEN_COLOR_HEX, alpha: 1.0)
            let myAttribute = [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 12)!,
                               NSForegroundColorAttributeName: UIColor(netHex: GREEN_COLOR_HEX, alpha: 0.8)]
            let str1 = NSAttributedString(string: " \(monthToString(entrance["month"].intValue))", attributes: myAttribute)
            
            let str2 = NSAttributedString(string: " \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance["year"].numberValue)!)  ")
            
            let strFinal = NSMutableAttributedString(string: "")
            strFinal.appendAttributedString(str1)
            strFinal.appendAttributedString(str2)
            
            self.yearLabel.attributedText = strFinal
        } else {
            self.yearLabel.textColor = UIColor.blackColor()
            let myAttribute = [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 12)!,
                               NSForegroundColorAttributeName: UIColor(white: 0.0, alpha: 0.8)]
            let str1 = NSAttributedString(string: " \(monthToString(entrance["month"].intValue))", attributes: myAttribute)
            
            let str2 = NSAttributedString(string: " \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance["year"].numberValue)!)  ")
            
            let strFinal = NSMutableAttributedString(string: "")
            strFinal.appendAttributedString(str1)
            strFinal.appendAttributedString(str2)
            
            self.yearLabel.attributedText = strFinal
        }
        
        self.buyCountLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance["stats"][0]["purchased"].intValue)
        
        
        if buyed {
            self.buyedImageView.hidden = false
            self.buyCountStackView.hidden = true
//            self.containerView.backgroundColor = UIColor(netHex: GREEN_COLOR_HEX, alpha: 0.05)
//            self.containerView.layer.borderColor = UIColor(netHex: GREEN_COLOR_HEX, alpha: 0.2).CGColor
        } else {
            self.buyedImageView.hidden = true
            self.buyCountStackView.hidden = false
//            self.containerView.backgroundColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.05)
//            self.containerView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
//            self.containerView.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.5).CGColor
        }
        
    }
}
