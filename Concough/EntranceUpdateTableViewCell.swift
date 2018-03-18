//
//  EntranceUpdateTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-11-10.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

class EntranceUpdateTableViewCell: UITableViewCell {

    private let localName: String = "HomeVC"
    
    @IBOutlet weak var containerUIView: UIView!
    @IBOutlet weak var entranceTitleUILabel: UILabel!
    @IBOutlet weak var entranceSetUILabel: UILabel!
    @IBOutlet weak var entranceUpdateTimeUILabel: UILabel!
    @IBOutlet weak var entranceImage: UIImageView!
    @IBOutlet weak var entranceYearUILabel: UILabel!
    @IBOutlet weak var entranceDlCount: UILabel!
    @IBOutlet weak var entranceExtraDataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }

    
    override func prepareForReuse() {
        self.entranceImage?.image = nil
    }
    
    override func drawRect(rect: CGRect) {
        /*
         entranceImage.layer.cornerRadius = entranceImage.layer.frame.width / 2.0
         entranceImage.layer.masksToBounds = true
         */
        self.entranceYearUILabel.layer.borderColor = self.entranceYearUILabel.textColor.CGColor
        self.entranceYearUILabel.layer.borderWidth = 1.0
        self.entranceYearUILabel.layer.cornerRadius = 5.0
        
        self.entranceImage.layer.cornerRadius = self.entranceImage.layer.frame.width / 2.0
        self.entranceImage.layer.masksToBounds = true
        self.entranceImage.layer.borderWidth = 1.0
        self.entranceImage.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func cellConfigure(indexPath: NSIndexPath, target: JSON) {
//        
//        self.entranceImage?.image = UIImage(named: "NoImage")
        
//        self.entranceTitleUILabel.text = "آزمون" + " \(target["entrance_type"]["title"].stringValue) \(target["organization"]["title"].stringValue)"
        self.entranceTitleUILabel.text = "آزمون" + " \(target["entrance_type"]["title"].stringValue)"
        
//        self.entranceTitleUILabel.text = "آزمون" + " پروانه کارموزی کانون وکلای دادگستری"
        self.entranceSetUILabel.text = "\(target["entrance_set"]["title"].stringValue) (\(target["entrance_set"]["group"]["title"].stringValue))"
        self.entranceYearUILabel.text = " \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(target["year"].numberValue)!) "
        self.entranceDlCount.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(0)!)"
        
        if let publishedStr = target["last_published"].string {
            let date:NSDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(publishedStr)!
            self.entranceUpdateTimeUILabel.text = "\(FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(date))"
        } else if let publishedStr = target["last_update"].string {
            let date:NSDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(publishedStr)!
            self.entranceUpdateTimeUILabel.text = "\(FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(date))"            
        }
        
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
        
//        self.downloadEsetImage(imageID, indexPath: indexPath)
    }
    
    public func downloadEsetImage(imageID: Int, indexPath: NSIndexPath) {
        if let esetUrl = MediaRestAPIClass.makeEsetImageUri(imageID) {
            //MediaRequestRepositorySingleton.sharedInstance.cancel(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
            
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
                        print("error in downloaing image from \(fullPath!)")
                        
                    } else {
                        if let myData = data {
                            MediaCacheSingleton.sharedInstance[fullPath!] = myData
                            
                            if self.entranceImage.assicatedObject == esetUrl {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.entranceImage.image = UIImage(data: myData)
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
