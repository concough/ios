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
    
    internal func configureCell(indexPath indexPath: NSIndexPath, esetId: Int,  entrance: ArchiveEntranceStructure) {
        self.orgTypeLabel.text = "\(entrance.organization!) "
        self.orgYearLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.year!)!
        
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
        
        self.downloadImage(esetId: esetId, indexPath: indexPath)
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
                        // print the error for now
                        self.esetImageView?.image = UIImage()
                        self.setNeedsLayout()
                        print("error in downloaing image from \(fullPath!)")
                        
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
