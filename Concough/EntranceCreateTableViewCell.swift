//
//  EntranceCreateTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-11-10.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

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
    
    func cellConfigure(target: JSON) {
        
        self.entranceTitleUILabel.text = "\(target["entrance_type"]["title"].stringValue) \(target["organization"]["title"].stringValue) "
        self.entranceSetUILabel.text = "\(target["entrance_set"]["title"].stringValue) (\(target["entrance_set"]["group"]["title"].stringValue))"
        self.entranceYearUILabel.text = " \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(target["year"].numberValue)!) "
        self.entranceDlCount.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(14)!)"
        
        let publishedStr = target["last_published"].stringValue
        let date:NSDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(publishedStr)!
        self.entranceUpdateTimeUILabel.text = "\(FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(date))"
        
        
        let imageID = target["entrance_set"]["id"].intValue
        
        if let esetUrl = MediaRestAPIClass.makeEsetImageUri(imageID) {
            
            if let myData = MediaCacheSingleton.sharedInstance[esetUrl] {
                self.entranceImage.image = UIImage(data: myData)
                
            } else {
                MediaRestAPIClass.downloadEsetImage(imageID) {
                    fullPath, data, error in
                    
                    if error != nil {
                        // print the error for now
                        print("error in downloaing image from \(fullPath!)")
                        
                    } else {
                        if let myData = data {
                            self.entranceImage.image = UIImage(data: myData)
                            MediaCacheSingleton.sharedInstance[fullPath!] = myData
                        }
                    }
                }
                
            }
        }
        
    }
}
