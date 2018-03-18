//
//  BasketEntranceTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-01-08.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class BasketEntranceTableViewCell: UITableViewCell {

    private let localName: String = "EntranceVC"
    
    @IBOutlet weak var entranceImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var extraLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func drawRect(rect: CGRect) {
        self.entranceImage.layer.cornerRadius = self.entranceImage.layer.frame.width / 2.0
        self.entranceImage.layer.masksToBounds = true
        self.entranceImage.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.5).CGColor
        self.entranceImage.layer.borderWidth = 0.7
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }

    internal func configureCell(entrance entrance: EntranceStructure, cost: Int, indexPath: NSIndexPath) {
        self.titleLabel.text = "آزمون \(entrance.entranceTypeTitle!) \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!)"
        //self.subTitleLabel.text = "مجموعه مهندسی کامپیوتر و الکترونیک ایخ هطر هسطر هشرط هشسط هشس هسط هشس طهشسرش هشسط (مجموعه فنی و مهندسی)"
        self.subTitleLabel.text = "\(entrance.entranceSetTitle!) (\(entrance.entranceGroupTitle!))"
//        self.subTitleLabel.semanticContentAttribute = .ForceRightToLeft
//        self.subTitleLabel.sizeToFit()
        
        if (cost != 0) {
            self.costLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(cost)! + " تومان"
        } else {
            self.costLabel.text = "رایگان"
        }
        
//        if let extraData = entrance.entranceExtraData {
//            var s = ""
//            for (key, item) in extraData {
//                s += "\(key): \(item.stringValue)" + " - "
//            }
//            
//            if s.characters.count > 3 {
//                s = s.substringToIndex(s.endIndex.advancedBy(-3))
//            }
//            self.extraLabel.text = s
//        }
        self.extraLabel.text = "\(entrance.entranceOrgTitle!)"
        
        self.downloadImage(esetId: entrance.entranceSetId!, indexPath: indexPath)
    }

    private func downloadImage(esetId esetId: Int, indexPath: NSIndexPath) {
        if let esetUrl = MediaRestAPIClass.makeEsetImageUri(esetId) {
            MediaRequestRepositorySingleton.sharedInstance.cancel(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
            
            if let myData = MediaCacheSingleton.sharedInstance[esetUrl] {
                self.entranceImage?.image = UIImage(data: myData)
                
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
                            self.entranceImage?.image = UIImage()
                            self.setNeedsLayout()
                            print("error in downloaing image from \(fullPath!)")
                        }
                    } else {
                        if let myData = data {
                            MediaCacheSingleton.sharedInstance[fullPath!] = myData
                            
                            if self.imageView?.assicatedObject == esetUrl {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.entranceImage?.image = UIImage(data: myData)
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
