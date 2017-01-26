//
//  ArchiveBasicTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-12-25.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class ArchiveAdvanceTableViewCell: UITableViewCell {

    private let localName: String = "ArchiveVC"
    
    @IBOutlet weak var entranceSetImageView: UIImageView!
    @IBOutlet weak var entranceSetTitle: UILabel!
    @IBOutlet weak var entranceSetSubTitle: UILabel!
    @IBOutlet weak var entranceCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.selectionStyle = UITableViewCellSelectionStyle.None        
    }
    
    override func drawRect(rect: CGRect) {
        //self.entranceSetImageView.layer.cornerRadius = (self.entranceSetImageView?.layer.frame.size.width)! / 2.0
        self.entranceSetImageView.layer.masksToBounds = true
        //self.entranceSetImageView.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.5).CGColor
        //self.entranceSetImageView.layer.borderWidth = 0.5
        
    }

    override func prepareForReuse() {
        self.selectionStyle = .None
    }
    
    internal func configureCell(indexPath indexPath: NSIndexPath, setId: Int, title: String, subTitle: String, code: Int) {
        self.entranceSetTitle.text = title
        self.entranceSetSubTitle.text = subTitle
        self.entranceCodeLabel.text = "کد: " + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(code)!
        
        self.downloadImage(esetId: setId, indexPath: indexPath)
    }

    internal func configureCell(indexPath indexPath: NSIndexPath, set: ArchiveEsetStructure) {
        var count = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(0)
        if let c = set.entranceCount {
            count = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(c)
        }
        
        if set.entranceCount > 0 {
            self.selectionStyle = .Default
        }
        
        self.configureCell(indexPath: indexPath, setId: set.id!, title: set.title!, subTitle: "\(count!) کنکور", code: set.code!)
    }
    
    private func downloadImage(esetId esetId: Int, indexPath: NSIndexPath) {
        if let esetUrl = MediaRestAPIClass.makeEsetImageUri(esetId) {
            MediaRequestRepositorySingleton.sharedInstance.cancel(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
            
            if let myData = MediaCacheSingleton.sharedInstance[esetUrl] {
                self.entranceSetImageView?.image = UIImage(data: myData)
                
            } else {
                // set associate object of entracneImage
                self.imageView?.assicatedObject = esetUrl
                
                // cancel download image request
                
                MediaRestAPIClass.downloadEsetImage(localName: self.localName, indexPath: indexPath, imageId: esetId, completion: {
                    fullPath, data, error in
                    
                    MediaRequestRepositorySingleton.sharedInstance.remove(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
                    
                    if error != .Success {
                        // print the error for now
                        self.entranceSetImageView?.image = UIImage()
                        self.setNeedsLayout()
                        print("error in downloaing image from \(fullPath!)")
                        
                    } else {
                        if let myData = data {
                            MediaCacheSingleton.sharedInstance[fullPath!] = myData
                            
                            if self.imageView?.assicatedObject == esetUrl {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.entranceSetImageView?.image = UIImage(data: myData)
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

