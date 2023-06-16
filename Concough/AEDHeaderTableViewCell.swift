//
//  AEDHeaderTableViewCell.swift
//  Concough
//
//  Created by Owner on 2016-12-26.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class AEDHeaderTableViewCell: UITableViewCell {

    private let localName: String = "ArchiveVC"
    
    @IBOutlet weak var entranceImage: UIImageView!
    @IBOutlet weak var entranceSetLabel: UILabel!
    @IBOutlet weak var entranceCountLabel: UILabel!
    @IBOutlet weak var entranceSetCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
        self.entranceSetLabel.lineBreakMode = .ByWordWrapping
        self.entranceSetLabel.numberOfLines = 0
    }

    override func drawRect(rect: CGRect) {
        self.entranceImage.layer.cornerRadius = self.entranceImage.layer.frame.size.width / 2.0
        self.entranceImage.layer.masksToBounds = true
        
        self.entranceImage.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.5).CGColor
        self.entranceImage.layer.borderWidth = 0.5
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    override func prepareForReuse() {
        self.entranceImage.image = UIImage(named: "NoImage")
    }
    
    internal func configureCell(indexPath indexPath: NSIndexPath, esetId: Int, esetTitle: String, entranceCount: Int, entranceSetCode: Int) {
        let count = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entranceCount)!
        
        self.entranceSetLabel.text = esetTitle
        self.entranceCountLabel.text = "\(count) آزمون منتشر شده"
        if (entranceSetCode == 0) {
            self.entranceSetCodeLabel.hidden = true
            self.entranceSetCodeLabel.text = "کد: ندارد"
        } else {
            self.entranceSetCodeLabel.text = "کد: " + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entranceSetCode)!
        }
        
        self.downloadImage(esetId: esetId, indexPath: indexPath)
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
                            self.entranceImage?.image = UIImage()
                            self.setNeedsLayout()
//                            print("error in downloaing image from \(fullPath!)")
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
