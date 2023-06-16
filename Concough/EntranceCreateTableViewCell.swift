//
//  EntranceCreateTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-11-10.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class EntranceCreateTableViewCell: UITableViewCell {
    
    private let localName: String = "HomeVC"
    
    @IBOutlet weak var containerUIView: UIView!
    @IBOutlet weak var entranceImage: UIImageView!
    @IBOutlet weak var entranceSetUILabel: UILabel!
    @IBOutlet weak var entranceTitleUILabel: UILabel!
    @IBOutlet weak var entranceYearUILabel: UILabel!
    @IBOutlet weak var entranceUpdateTimeUILabel: UILabel!
    @IBOutlet weak var entranceDlCount: UILabel!
    @IBOutlet weak var entranceExtraDataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func drawRect(rect: CGRect) {
        /*
        entranceImage.layer.cornerRadius = entranceImage.layer.frame.width / 2.0
        entranceImage.layer.masksToBounds = true
        */
        self.entranceYearUILabel.layer.borderColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0).CGColor
        self.entranceYearUILabel.layer.borderWidth = 1.0
        self.entranceYearUILabel.layer.cornerRadius = 5.0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.entranceImage?.image = nil
        self.entranceImage?.assicatedObject = ""
    }
    
    func cellConfigure(indexPath: NSIndexPath, target: JSON) {
//        self.entranceImage?.image = UIImage(named: "NoImage")
        
//        self.entranceTitleUILabel.text = "\(target["entrance_type"]["title"].stringValue) \(target["organization"]["title"].stringValue) " 
        self.entranceTitleUILabel.text = "\(target["entrance_type"]["title"].stringValue) "
        self.entranceSetUILabel.text = "\(target["entrance_set"]["title"].stringValue) (\(target["entrance_set"]["group"]["title"].stringValue))"
//        self.entranceYearUILabel.text = " \(monthToString(target["month"].intValue)) \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(target["year"].numberValue)!)   "
//        self.entranceYearUILabel.text = " \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(target["year"].numberValue)!) "
        self.entranceDlCount.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(target["stats"][0]["purchased"].numberValue)!) خرید"
        
        if let publishedStr = target["last_published"].string {
            let date:NSDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(publishedStr)!
//            self.entranceUpdateTimeUILabel.text = "\(FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(date))"
            self.entranceUpdateTimeUILabel.text = "\(date.timeAgoSinceDate())"
        } else if let publishedStr = target["last_update"].string {
            let date:NSDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(publishedStr)!
//            self.entranceUpdateTimeUILabel.text = "\(FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(date))"
            self.entranceUpdateTimeUILabel.text = "\(date.timeAgoSinceDate())"
        }
        
        let myAttribute = [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 12)!,
                           NSForegroundColorAttributeName: UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.7)]
        let str1 = NSAttributedString(string: " \(monthToString(target["month"].intValue))", attributes: myAttribute)

        let str2 = NSAttributedString(string: " \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(target["year"].numberValue)!)  ")

        let strFinal = NSMutableAttributedString(string: "")
        strFinal.appendAttributedString(str1)
        strFinal.appendAttributedString(str2)
        
        self.entranceYearUILabel.attributedText = strFinal
        
        
//        if let extra_data = target["extra_data"].stringValue.dataUsingEncoding(NSUTF8StringEncoding) {
//            let extraData = JSON(data: extra_data)
//
//            var s = ""
//            for (key, item) in extraData {
//                s += "\(key): \(item.stringValue)" + " - "
//            }
//            
//            if s.characters.count > 3 {
//                s = s.substringToIndex(s.endIndex.advancedBy(-3))
//            }
//            self.entranceExtraDataLabel.text = s
//        }
        self.entranceExtraDataLabel.text = "\(target["organization"]["title"].stringValue)"

        let imageID = target["entrance_set"]["id"].intValue
        
        //self.downloadEsetImage(imageID, indexPath: indexPath)
    }
    
    internal func downloadEsetImage(imageID: Int, indexPath: NSIndexPath) {
        if let esetUrl = MediaRestAPIClass.makeEsetImageUri(imageID) {
//            MediaRequestRepositorySingleton.sharedInstance.cancel(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
            
            if let myData = MediaCacheSingleton.sharedInstance[esetUrl] {
                self.entranceImage.image = UIImage(data: myData)
                
            } else {
                // set associate object of entracneImage
                self.entranceImage.assicatedObject = esetUrl
                
                // cancel download image request
                
                MediaRestAPIClass.downloadEsetImage(localName: self.localName, indexPath: indexPath, imageId: imageID, completion: {
                    fullPath, data, error in
                    
                    //MediaRequestRepositorySingleton.sharedInstance.remove(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
                    
                    if error != .Success {
                        // print the error for now
                        if error == HTTPErrorType.Refresh {
                            self.downloadEsetImage(imageID, indexPath: indexPath)
                        }
//                        print("error in downloaing image from \(fullPath!)")
                        
                    } else {
                        if let myData = data {
                            MediaCacheSingleton.sharedInstance[fullPath!] = myData
                            
                            if self.entranceImage.assicatedObject == esetUrl {
//                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.entranceImage.image = UIImage(data: myData)
//                                })
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
