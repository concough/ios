//
//  EMDInitailTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-05-21.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

class EMDInitailTableViewCell: UITableViewCell {

    private let localName: String = "EntranceVC"
    
    
    @IBOutlet weak var entranceImageView: UIImageView!
    @IBOutlet weak var entranceSetLabel: UILabel!
    @IBOutlet weak var entranceTypeLabel: UILabel!
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var payCostLabel: UILabel!
    @IBOutlet weak var entrancesCountLabel: UILabel!
    @IBOutlet weak var costContainerStackView: UIStackView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .None
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.buyButton.layer.borderColor = self.buyButton.titleColorForState(.Normal)?.CGColor
        self.buyButton.layer.cornerRadius = 5.0
        self.buyButton.layer.borderWidth = 1.0
        self.buyButton.layer.masksToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func configureCell(firstEntrance firstEntrance: JSON, totalCost: Int, payCost: Int, entrancesCount: Int, disabelBuy: Bool, indexPath: NSIndexPath) {
        self.disableBuy(state: disabelBuy)
        
//        if totalCost == 0 {
//            self.totalCostLabel.text = "رایگان"
//            self.totalCostLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
//        } else {
//            self.totalCostLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(totalCost)!
//        }
//
//        if payCost == 0 {
//            self.payCostLabel.text = "رایگان"
//            self.payCostLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
//        } else {
//            self.payCostLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(payCost)!
//        }

        self.orgLabel.text = firstEntrance["organization"]["title"].stringValue
        self.entranceTypeLabel.text = firstEntrance["entrance_type"]["title"].stringValue
        self.entranceSetLabel.text = "\(firstEntrance["entrance_set"]["title"].stringValue) (\(firstEntrance["entrance_set"]["group"]["title"].stringValue))"
        
        self.entrancesCountLabel.text = "حاوی \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrancesCount)!) آزمون"

        self.downloadImage(esetId: firstEntrance["entrance_set"]["id"].intValue, indexPath: indexPath)
    }
    
    internal func configureCosts(saleStruct saleStruct: EntranceMultiSaleStructure) {
        if saleStruct.totalCost! == 0 {
            self.totalCostLabel.text = "رایگان"
        } else {
            self.totalCostLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(saleStruct.totalCost!)!
        }
        
        if saleStruct.payCost! == 0 {
            self.payCostLabel.text = "رایگان"
            self.payCostLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
        } else {
            self.payCostLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(saleStruct.payCost!)!
        }
        
    }
    
    internal func disableBuyButton() {
        self.buyButton.enabled = false
        self.buyButton.setTitleColor(UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 1.0), forState: .Normal)
        self.buyButton.setTitle("●●●", forState: .Normal)
        self.buyButton.layer.borderColor = self.buyButton.titleColorForState(.Normal)?.CGColor
    }
    
    internal func disableBuy(state state: Bool) {
        if state {
            self.costContainerStackView.hidden = true
            self.loadingIndicator.startAnimating()
            
            self.buyButton.enabled = false
            self.buyButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.buyButton.layer.borderColor = self.buyButton.titleColorForState(.Normal)?.CGColor
            
        } else {
            self.costContainerStackView.hidden = false
            self.loadingIndicator.stopAnimating()

            self.buyButton.enabled = true
            self.buyButton.setTitleColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
            self.buyButton.layer.borderColor = self.buyButton.titleColorForState(.Normal)?.CGColor
        }
    }
    
    private func downloadImage(esetId esetId: Int, indexPath: NSIndexPath) {
        if let esetUrl = MediaRestAPIClass.makeEsetImageUri(esetId) {
            MediaRequestRepositorySingleton.sharedInstance.cancel(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
            
            if let myData = MediaCacheSingleton.sharedInstance[esetUrl] {
                self.entranceImageView?.image = UIImage(data: myData)
            } else {
                // set associate object of entracneImage
                self.imageView?.assicatedObject = esetUrl
                
                // cancel download image request
                
                MediaRestAPIClass.downloadEsetImage(localName: self.localName, indexPath: indexPath, imageId: esetId, completion: {
                    fullPath, data, error in
                    
                    MediaRequestRepositorySingleton.sharedInstance.remove(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
                    
                    if error != .Success {
                        // print the error for now
                        if error == HTTPErrorType.Refresh {
                            self.downloadImage(esetId: esetId, indexPath: indexPath)
                        } else {
                            self.entranceImageView?.image = UIImage()
                            self.setNeedsLayout()
                            //                            print("error in downloaing image from \(fullPath!)")
                        }
                    } else {
                        if let myData = data {
                            MediaCacheSingleton.sharedInstance[fullPath!] = myData
                            
                            if self.imageView?.assicatedObject == esetUrl {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.entranceImageView?.image = UIImage(data: myData)
                                    //self.setNeedsLayout()
                                })
                            }
                        }
                    }
                    }, failure: { (error) in
                        if let err = error {
                            switch err {
                            case .NoInternetAccess:
                                break
                            default:
                                break
                            }
                        }
                })
            }
        }
    }
    
}
