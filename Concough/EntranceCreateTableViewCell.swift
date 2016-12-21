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
    
    @IBOutlet weak var containerUIView: UIView!
    @IBOutlet weak var entranceImage: UIImageView!
    @IBOutlet weak var entranceSetUILabel: UILabel!
    @IBOutlet weak var entranceTitleUILabel: UILabel!
    @IBOutlet weak var entranceYearUILabel: UILabel!
    @IBOutlet weak var entranceUpdateTimeUILabel: UILabel!
    @IBOutlet weak var entranceDlCount: UILabel!
    
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
        self.entranceYearUILabel.layer.borderColor = self.entranceYearUILabel.textColor.CGColor
        self.entranceYearUILabel.layer.borderWidth = 1.0
        self.entranceYearUILabel.layer.cornerRadius = 5.0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func cellConfigure(indexPath: NSIndexPath, target: JSON) {
        
        self.entranceTitleUILabel.text = "\(target["entrance_type"]["title"].stringValue) \(target["organization"]["title"].stringValue) "
        self.entranceSetUILabel.text = "\(target["entrance_set"]["title"].stringValue) (\(target["entrance_set"]["group"]["title"].stringValue))"
        self.entranceYearUILabel.text = " \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(target["year"].numberValue)!) "
        self.entranceDlCount.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(14)!)"
        
        if let publishedStr = target["last_published"].string {
            let date:NSDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(publishedStr)!
            self.entranceUpdateTimeUILabel.text = "\(FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(date))"
        } else if let publishedStr = target["last_update"].string {
            let date:NSDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(publishedStr)!
            self.entranceUpdateTimeUILabel.text = "\(FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(date))"
        }        
        
        let imageID = target["entrance_set"]["id"].intValue
        
        if let esetUrl = MediaRestAPIClass.makeEsetImageUri(imageID) {
            MediaRequestRepositorySingleton.sharedInstance.cancel(key: "\(indexPath.section):\(indexPath.row):\(esetUrl)")
            
            if let myData = MediaCacheSingleton.sharedInstance[esetUrl] {
                self.entranceImage.image = UIImage(data: myData)
                
            } else {
                // set associate object of entracneImage
                self.entranceImage.assicatedObject = esetUrl
                
                // cancel download image request
                
                MediaRestAPIClass.downloadEsetImage(indexPath, imageId: imageID, completion: {
                    fullPath, data, error in
                    
                    MediaRequestRepositorySingleton.sharedInstance.remove(key: "\(indexPath.section):\(indexPath.row):\(esetUrl)")
                    
                    if error != .Success {
                        // print the error for now
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
