//
//  AEDAdvanceTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-12-29.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class AEDAdvanceTableViewCell: UITableViewCell {
    private let localName: String = "ArchiveVC"

    @IBOutlet weak var orgYearLabel: UILabel!
    @IBOutlet weak var extraDataLabel: UILabel!
    @IBOutlet weak var buyCountLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var orgTypeLabel: UILabel!
    @IBOutlet weak var esetImageView: UIImageView!
    @IBOutlet weak var addToBasketButton: UIButton!
    @IBOutlet weak var buyedDoubleTickImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    override func prepareForReuse() {
        self.esetImageView.image = UIImage(named: "NoImage")
    }
    
    internal func configureCell(indexPath indexPath: NSIndexPath, esetId: Int,  entrance: ArchiveEntranceStructure, state: Bool, buyed: Bool) {
//        self.orgTypeLabel.text = "\(entrance.organization!) "
        self.orgYearLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.year!)!
        
        self.buyCountLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.buyCount!)! + " خرید"
        self.publishedDateLabel.text = FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(entrance.lastPablished!)
        
//        if let extraData = entrance.extraData {
//            var s = ""
//            for (key, item) in extraData {
//                s += "\(key): \(item.stringValue)" + " - "
//            }
//            
//            if s.characters.count > 3 {
//                s = s.substringToIndex(s.endIndex.advancedBy(-3))
//            }
//            self.extraDataLabel.text = s
//        }
        self.extraDataLabel.text = "\(entrance.organization!)"
        self.changeButtonState(state: state, buyed: buyed)
        //self.downloadImage(esetId: esetId, indexPath: indexPath)
    }
    
    private func changeButtonState(state state: Bool, buyed: Bool) {
        if buyed == false {
            self.addToBasketButton.hidden = false
            self.buyedDoubleTickImage.hidden = true
            
            self.changeBuyButtonState(state: state)
        } else {
            self.addToBasketButton.hidden = true
            self.buyedDoubleTickImage.hidden = false
            
//            self.addToBasketButton.setTitleColor(UIColor(netHex: GREEN_COLOR_HEX, alpha: 1.0), forState: .Normal)
//            self.addToBasketButton.setTitle("مشاهده آزمون", forState: .Normal)
//            self.addToBasketButton.layer.cornerRadius = 5.0
//            self.addToBasketButton.layer.masksToBounds = true
//            self.addToBasketButton.layer.borderWidth = 1.0
//            self.addToBasketButton.layer.borderColor = self.addToBasketButton.titleColorForState(.Normal)?.CGColor
        }
    }
    
    internal func disableBuyButton() {
        self.addToBasketButton.enabled = false
        self.addToBasketButton.setTitleColor(UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 1.0), forState: .Normal)
//        self.addToBasketButton.setTitle("منتظر بمانید ...", forState: .Normal)
        self.addToBasketButton.setTitle("●●●", forState: .Normal)
        self.addToBasketButton.layer.cornerRadius = 5.0
        self.addToBasketButton.layer.masksToBounds = true
        self.addToBasketButton.layer.borderWidth = 1.0
        self.addToBasketButton.layer.borderColor = self.addToBasketButton.titleColorForState(.Normal)?.CGColor        
    }
    
    internal func changeBuyButtonState(state state: Bool) {
        self.addToBasketButton.enabled = true
        if state == false {
            self.addToBasketButton.setTitleColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
            self.addToBasketButton.setTitle("+ سبد خرید", forState: .Normal)
            self.addToBasketButton.layer.cornerRadius = 5.0
            self.addToBasketButton.layer.masksToBounds = true
            self.addToBasketButton.layer.borderWidth = 1.0
            self.addToBasketButton.layer.borderColor = self.addToBasketButton.titleColorForState(.Normal)?.CGColor
        } else if state == true {
            self.addToBasketButton.setTitleColor(UIColor(netHex: RED_COLOR_HEX, alpha: 1.0), forState: .Normal)
            self.addToBasketButton.setTitle("- سبد خرید", forState: .Normal)
            self.addToBasketButton.layer.cornerRadius = 5.0
            self.addToBasketButton.layer.masksToBounds = true
            self.addToBasketButton.layer.borderWidth = 1.0
            self.addToBasketButton.layer.borderColor = self.addToBasketButton.titleColorForState(.Normal)?.CGColor
        }
    }
    

    private func downloadImage(esetId esetId: Int, indexPath: NSIndexPath) {
        if let esetUrl = MediaRestAPIClass.makeEsetImageUri(esetId) {
            MediaRequestRepositorySingleton.sharedInstance.cancel(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
            
            if let myData = MediaCacheSingleton.sharedInstance[esetUrl] {
                self.esetImageView?.image = UIImage(data: myData)
                
            } else {
                // set associate object of entracneImage
                self.imageView?.assicatedObject = esetUrl
                
                // cancel download image request
                
                MediaRestAPIClass.downloadEsetImage(localName: self.localName, indexPath: indexPath, imageId: esetId, completion: {
                    fullPath, data, error in
                    
                    MediaRequestRepositorySingleton.sharedInstance.remove(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
                    
                    if error != .Success {
                        if error == HTTPErrorType.Refresh {
                            self.downloadImage(esetId: esetId, indexPath: indexPath)
                            
                        } else {
                            // print the error for now
                            self.esetImageView?.image = UIImage()
                            self.setNeedsLayout()
                            print("error in downloaing image from \(fullPath!)")
                        }
                    } else {
                        if let myData = data {
                            MediaCacheSingleton.sharedInstance[fullPath!] = myData
                            
                            if self.imageView?.assicatedObject == esetUrl {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.esetImageView?.image = UIImage(data: myData)
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
