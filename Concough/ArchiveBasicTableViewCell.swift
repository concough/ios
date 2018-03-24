//
//  ArchiveBasicTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-12-25.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class ArchiveBasicTableViewCell: UITableViewCell {

    private let localName: String = "ArchiveVC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.textLabel?.font = UIFont(name: "IRANYekanMobile-Bold", size: 13)
        self.detailTextLabel?.font = UIFont(name: "IRANYekanMobile", size: 13)
        self.detailTextLabel?.textColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 1.0)
        
        self.imageView?.layer.borderWidth = 0.5
        self.imageView?.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.5).CGColor
    }

    internal func configureCell(indexPath indexPath: NSIndexPath, setId: Int, title: String, subTitle: String) {
        let pstyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        pstyle.minimumLineHeight = 20
        
        let subText:NSMutableAttributedString = NSAttributedString(string: subTitle).mutableCopy() as! NSMutableAttributedString
        subText.addAttributes([NSParagraphStyleAttributeName: pstyle], range: NSMakeRange(0, subText.length))
        
        self.textLabel?.text = title
        self.detailTextLabel?.attributedText = subText
        
        self.downloadImage(esetId: setId, indexPath: indexPath)
    }

    internal func configureCell(indexPath indexPath: NSIndexPath, set: ArchiveEsetStructure) {
        var count = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(0)
        if let c = set.entranceCount {
            count = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(c)
        }
        
        self.configureCell(indexPath: indexPath, setId: set.id!, title: set.title!, subTitle: "\(count!) آزمون")
    }
    
    private func downloadImage(esetId esetId: Int, indexPath: NSIndexPath) {
        if let esetUrl = MediaRestAPIClass.makeEsetImageUri(esetId) {
            MediaRequestRepositorySingleton.sharedInstance.cancel(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
            
            if let myData = MediaCacheSingleton.sharedInstance[esetUrl] {
                self.imageView?.image = UIImage(data: myData)
                self.imageView?.layer.cornerRadius = (self.imageView?.layer.frame.size.width)! / 2.0
                self.imageView?.layer.masksToBounds = true
                self.setNeedsLayout()
                
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
                            self.imageView?.image = UIImage()
                            self.setNeedsLayout()
//                            print("error in downloaing image from \(fullPath!)")
                        }
                    } else {
                        if let myData = data {
                            MediaCacheSingleton.sharedInstance[fullPath!] = myData
                            
                            if self.imageView?.assicatedObject == esetUrl {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.imageView?.image = UIImage(data: myData)
                                    self.imageView?.layer.cornerRadius = (self.imageView?.layer.frame.size.width)! / 2.0
                                    self.imageView?.layer.masksToBounds = true
                                    self.setNeedsLayout()
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

