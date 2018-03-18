//
//  FavoriteEntranceDeleteTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-01-22.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class FavoriteEntranceDeleteTableViewCell: UITableViewCell {

    private let localName: String = "FavoriteVC"
    private let imageBasePath: String = ("images" as NSString).stringByAppendingPathComponent("eset")
    
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var extraData: UILabel!
    @IBOutlet weak var entranceImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
    }
    
    override func drawRect(rect: CGRect) {
        self.deleteStackView.layer.cornerRadius = 3.0
        self.deleteStackView.layer.masksToBounds = true
        self.deleteStackView.layer.borderColor = self.deleteButton.currentTitleColor.CGColor
        self.deleteStackView.layer.borderWidth = 0.8
    }
    
    // MARK: - Functions
    internal func configureCell(entrance entrance: EntranceStructure, purchased: EntrancePrurchasedStructure, indexPath: NSIndexPath) {
        self.title.text = "آزمون \(entrance.entranceTypeTitle!) " + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!
        self.subTitle.text = "\(entrance.entranceSetTitle!) (\(entrance.entranceGroupTitle!))"
        
//        if let extraData = entrance.entranceExtraData {
//            var s = ""
//            for (key, item) in extraData {
//                s += "\(key): \(item.stringValue)" + " - "
//            }
//            
//            if s.characters.count > 3 {
//                s = s.substringToIndex(s.endIndex.advancedBy(-3))
//            }
//            self.extraData.text = s
//            
//        }
        self.extraData.text = "\(entrance.entranceOrgTitle!)"
        self.deleteButton.assicatedObject = "\(indexPath.section):\(indexPath.row)"
        
        
        // download Images
        self.downloadImage(esetId: entrance.entranceSetId!, indexPath: indexPath)
    }
    
    private func downloadImage(esetId esetId: Int, indexPath: NSIndexPath) {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        let filePath = (docsDir.stringByAppendingPathComponent(imageBasePath) as NSString).stringByAppendingPathComponent(String(esetId))
        
        if filemgr.fileExistsAtPath(filePath) == true {
            if let data = filemgr.contentsAtPath(filePath) {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.entranceImageView?.image = UIImage(data: data)
                    self.setNeedsLayout()
                })
                
            }
        } else {
            downloadImageFromNet(esetId: esetId, indexPath: indexPath)
        }
    }
    
    
    private func downloadImageFromNet(esetId esetId: Int, indexPath: NSIndexPath) {
        if let esetUrl = MediaRestAPIClass.makeEsetImageUri(esetId) {
            MediaRequestRepositorySingleton.sharedInstance.cancel(key: "\(self.localName):\(indexPath.section):\(indexPath.row):\(esetUrl)")
            
            if let myData = MediaCacheSingleton.sharedInstance[esetUrl] {
                self.entranceImageView?.image = UIImage(data: myData)
                
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
                            self.entranceImageView?.image = UIImage()
                            self.setNeedsLayout()
                            print("error in downloaing image from \(fullPath!)")
                        }
                    } else {
                        if let myData = data {
                            MediaCacheSingleton.sharedInstance[fullPath!] = myData
                            
                            if self.imageView?.assicatedObject == esetUrl {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.entranceImageView?.image = UIImage(data: myData)
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
