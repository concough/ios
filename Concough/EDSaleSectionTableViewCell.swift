//
//  EDSaleSectionTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-01-03.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class EDSaleSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var purchaseCount: UILabel!
    @IBOutlet weak var purchaseStackView: UIStackView!
    @IBOutlet weak var bottonLineView: UIView!
    @IBOutlet weak var basketStatusLabel: UILabel!
    @IBOutlet weak var basketFinishButton: UIButton!
    @IBOutlet weak var basketStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .None
        self.basketStackView.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    override func drawRect(rect: CGRect) {
        self.basketFinishButton.layer.cornerRadius = 5.0
        self.basketFinishButton.layer.masksToBounds = true
    }
    
    internal func configureCell(saleData saleData: EntranceSaleStructure?, statData: EntranceStatStructure?, buttonState: Bool, basketItemCount: Int? = nil) {
        
        if (saleData!.cost! != 0) {
            self.costLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(saleData!.cost!)! + " تومان"
        } else {
            self.costLabel.text = "رایگان"
            self.costLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
        }
        
        if let stat = statData {
            self.purchaseCount.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(stat.purchased!)! + " خرید"
        } else {
            self.purchaseStackView.hidden = true
        }
        
        if buttonState == false {
            self.bottonLineView.hidden = true
        }
        
        self.changeButtonState(state: buttonState)
        self.showBasketInfo(state: buttonState, salesCount: basketItemCount)
    }
    
    internal func disableBuyButton() {
        self.buyButton.enabled = false
        self.buyButton.setTitleColor(UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 1.0), forState: .Normal)
//        self.buyButton.setTitle("منتظر بمانید ...", forState: .Normal)
        self.buyButton.setTitle("●●●", forState: .Normal)        
        self.buyButton.layer.cornerRadius = 5.0
        self.buyButton.layer.masksToBounds = true
        self.buyButton.layer.borderWidth = 1.0
        self.buyButton.layer.borderColor = self.buyButton.titleColorForState(.Normal)?.CGColor
    }

    internal func changeButtonState(state state: Bool) {
        self.buyButton.enabled = true
        if state == false {
            self.buyButton.setTitleColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
            self.buyButton.setTitle("+ سبد خرید", forState: .Normal)
            self.buyButton.layer.cornerRadius = 5.0
            self.buyButton.layer.masksToBounds = true
            self.buyButton.layer.borderWidth = 1.0
            self.buyButton.layer.borderColor = self.buyButton.titleColorForState(.Normal)?.CGColor
        } else if state == true {
            self.buyButton.setTitleColor(UIColor(netHex: RED_COLOR_HEX, alpha: 1.0), forState: .Normal)
            self.buyButton.setTitle("- سبد خرید", forState: .Normal)
            self.buyButton.layer.cornerRadius = 5.0
            self.buyButton.layer.masksToBounds = true
            self.buyButton.layer.borderWidth = 1.0
            self.buyButton.layer.borderColor = self.buyButton.titleColorForState(.Normal)?.CGColor
        }
    }
    
    private func showBasketInfo(state state: Bool, salesCount: Int?) {
        self.basketStackView.hidden = !state
        self.basketStatusLabel.hidden = !state
        self.bottonLineView.hidden = !state
        
        if state == true {
            if let count = salesCount {
                self.basketStatusLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(count)! + " قلم در سبد کالا موجود است."
            }
        }
    }
}
