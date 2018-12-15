//
//  FavoriteEntranceNotDownloadedTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-01-17.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class FavoriteEntranceNotDownloadedTableViewCell: UITableViewCell {
    private let localName: String = "FavoriteVC"
    private let imageBasePath: String = ("images" as NSString).stringByAppendingPathComponent("eset")
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var extraData: UILabel!
    @IBOutlet weak var bookletCount: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var downloadTimes: UILabel!
    @IBOutlet weak var downloadView: UIStackView!
    @IBOutlet weak var entranceImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!

    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var yearLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    override func prepareForReuse() {
        self.progressView.hidden = true
        self.downloadView.hidden = false
        self.progressView.setProgress(0, animated: false)
    }
    
    override func drawRect(rect: CGRect) {
        self.downloadButton.layer.borderWidth = 1.5
        self.downloadButton.layer.borderColor = self.downloadButton.titleColorForState(.Normal)?.CGColor
        self.downloadButton.layer.cornerRadius = 5.0
        self.downloadButton.layer.masksToBounds = true
        
//        self.yearLabel.layer.borderWidth = 0.5
//        self.yearLabel.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.5).CGColor
//        self.yearLabel.layer.cornerRadius = 7.0
//        self.yearLabel.layer.masksToBounds = true
        
    }
    
    // MARK: - Functions
    internal func configureCell(entrance entrance: EntranceStructure, purchased: EntrancePrurchasedStructure, indexPath: NSIndexPath) {
        self.title.text = "آزمون \(entrance.entranceTypeTitle!)"
        if entrance.entranceMonth > 0 {
            let myAttribute = [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 14)!,
                               NSForegroundColorAttributeName: UIColor(netHex: GRAY_BLUE_COLOR_HEX, alpha: 0.5)]
            let str1 = NSAttributedString(string: "\(monthToString(entrance.entranceMonth!))", attributes: myAttribute)
            
            let str2 = NSAttributedString(string: " \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!)")
            
            let strFinal = NSMutableAttributedString(string: "")
            strFinal.appendAttributedString(str1)
            strFinal.appendAttributedString(str2)
            
            self.yearLabel.attributedText = strFinal
        } else {
            self.yearLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!
        }
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
//        }
        self.extraData.text = "\(entrance.entranceOrgTitle!)"
        
        self.bookletCount.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceBookletCounts!)! + " دفترچه"
        self.duration.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceDuration!)! + " دقیقه"
        self.downloadTimes.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(purchased.downloaded!)! + " بار دانلود شده است"
        
        // download Images
        self.downloadImage(esetId: entrance.entranceSetId!, indexPath: indexPath)
        self.progressView.hidden = true
        
        if purchased.isDataDownloaded! {
            self.downloadButton.setTitle("ادامه دانلود", forState: .Normal)
        } else {
            self.downloadButton.setTitle("دانلود", forState: .Normal)
        }
        
    }
    
    internal func addTargets(viewController viewController: FavoritesTableViewController, indexPath: NSIndexPath) {
        self.downloadButton.assicatedObject = "\(indexPath.section):\(indexPath.row)"
        
        self.downloadButton.addTarget(viewController, action: #selector(viewController.downloadTapped(_:)), forControlEvents: .TouchUpInside)
    }
        
    internal func changeProgressValue(value value: Int, totalCount: Int) {
        let delta = (Float(totalCount) - Float(value)) / Float(totalCount)
        self.progressView.setProgress(delta, animated: true)
    }
    
    internal func changeToDownloadState() {
        self.progressView.hidden = false
        self.progressView.setProgress(0.1, animated: true)
        self.downloadView.hidden = true
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
                            self.entranceImageView?.image = UIImage()
                            self.setNeedsLayout()
//                            print("error in downloaing image from \(fullPath!)")
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
