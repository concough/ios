//
//  FavoriteEntranceNotDownloadedTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-01-17.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class FavoriteEntranceDownloadedTableViewCell: UITableViewCell {
    private let localName: String = "FavoriteVC"
    private let imageBasePath: String = ("images" as NSString).stringByAppendingPathComponent("eset")
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var extraData: UILabel!
    @IBOutlet weak var bookletCount: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var entranceImageView: UIImageView!
    @IBOutlet weak var observeEntranceView: UIView!
    @IBOutlet weak var observeCountLabel: UILabel!
    @IBOutlet weak var startQuestionsCountLabel: UILabel!
    @IBOutlet weak var questionsCount: UILabel!
    
    @IBOutlet weak var observerEntranceButton: UIButton!
    @IBOutlet weak var observerStarQuestionsButton: UIButton!
    @IBOutlet weak var bookmarkImageView: UIImageView!
    @IBOutlet weak var viewImageView: UIImageView!
    @IBOutlet weak var yearLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    override func drawRect(rect: CGRect) {
//        self.entranceImageView.layer.cornerRadius = self.entranceImageView.layer.frame.size.height / 2.0
//        self.entranceImageView.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 1.0).CGColor
//        self.entranceImageView.layer.borderWidth = 0.7
        
//        self.yearLabel.layer.borderWidth = 0.5
//        self.yearLabel.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.5).CGColor
//        self.yearLabel.layer.cornerRadius = 7.0
//        self.yearLabel.layer.masksToBounds = true
        
        self.observerEntranceButton.layer.borderWidth = 1.0
        self.observerEntranceButton.layer.borderColor = self.observerEntranceButton.titleColorForState(.Normal)?.CGColor
        self.observerEntranceButton.layer.cornerRadius = 5.0

        self.observerStarQuestionsButton.layer.borderWidth = 1.0
        self.observerStarQuestionsButton.layer.borderColor = self.observerStarQuestionsButton.titleColorForState(.Normal)?.CGColor
        self.observerStarQuestionsButton.layer.cornerRadius = 5.0
        
//        self.viewImageView.tintImageColor(UIColor.lightGrayColor())
//        self.bookmarkImageView.tintImageColor(UIColor.lightGrayColor())
    }
    
    // MARK: - Functions
    internal func configureCell(entrance entrance: EntranceStructure, purchased: EntrancePrurchasedStructure, indexPath: NSIndexPath, starCount: Int, openedCount: Int, qCount: Int) {
        self.title.text = "آزمون \(entrance.entranceTypeTitle!)"
        
        if entrance.entranceMonth > 0 {
            let myAttribute = [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 14)!,
                               NSForegroundColorAttributeName: UIColor(netHex: GRAY_BLUE_COLOR_HEX, alpha: 0.5)]
            let str1 = NSAttributedString(string: "\(monthToString(entrance.entranceMonth!))", attributes: myAttribute)
            
            let str2 = NSAttributedString(string: " \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!)")
            
            let strFinal = NSMutableAttributedString(string: "")
            strFinal.appendAttributedString(str1)
            strFinal.appendAttributedString(str2)
            
            
//            self.yearLabel.text = "\(monthToString(entrance.entranceMonth!)) " + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!
            
            self.yearLabel.attributedText = strFinal
        } else {
            self.yearLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!
        }
        
        
        self.subTitle.text = "\(entrance.entranceSetTitle!) (\(entrance.entranceGroupTitle!))"
        self.startQuestionsCountLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(starCount)!
        self.observeCountLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(openedCount)!
        
        if starCount > 0 {
            self.bookmarkImageView.image = UIImage(named: "bookmark2")
            
            self.observerStarQuestionsButton.setTitleColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
            self.observerStarQuestionsButton.layer.borderColor = self.observerStarQuestionsButton.titleColorForState(.Normal)?.CGColor
            self.observerStarQuestionsButton.setNeedsLayout()
            self.setNeedsLayout()
            
        } else {
            self.bookmarkImageView.image = UIImage(named: "bookmark4")
            
            self.observerStarQuestionsButton.setTitleColor(UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 1.0), forState: .Normal)
            self.observerStarQuestionsButton.layer.borderColor = self.observerStarQuestionsButton.titleColorForState(.Normal)?.CGColor
            self.observerStarQuestionsButton.setNeedsLayout()
            self.setNeedsLayout()
        }
        
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
        self.questionsCount.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(qCount)! + " سوال"
        
        // download Images
        self.downloadImage(esetId: entrance.entranceSetId!, indexPath: indexPath)
        
        
    }
    
    internal func changeBackground(color color: UIColor) {
        self.containerView.backgroundColor = color
        
        self.setNeedsLayout()
    }
    
    internal func addTargets(viewController viewController: FavoritesTableViewController, indexPath: NSIndexPath) {
        self.observerEntranceButton.assicatedObject = "\(indexPath.section):\(indexPath.row)"
        self.observerEntranceButton.addTarget(viewController, action: #selector(viewController.showEntranceTapped(_:)), forControlEvents: .TouchUpInside)
        
        self.observerStarQuestionsButton.assicatedObject = "\(indexPath.section):\(indexPath.row)"
        self.observerStarQuestionsButton.addTarget(viewController, action: #selector(viewController.showStarredQuestionTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
//    internal func addGestures(viewController viewController: FavoritesTableViewController, indexPath: NSIndexPath) {
//        let singleTapGestureRecognizer = UITapGestureRecognizer(target: viewController, action: #selector(viewController.showEntranceTapped(_:)))
//        singleTapGestureRecognizer.numberOfTapsRequired = 1
//        singleTapGestureRecognizer.numberOfTouchesRequired = 1
//        singleTapGestureRecognizer.enabled = true
//        singleTapGestureRecognizer.assicatedObject = "\(indexPath.section):\(indexPath.row)"
//        
//        self.observeEntranceView.userInteractionEnabled = true
//        self.observeEntranceView.addGestureRecognizer(singleTapGestureRecognizer)
//
//        let singleTapGestureRecognizer2 = UITapGestureRecognizer(target: viewController, action: #selector(viewController.showStarredQuestionTapped(_:)))
//        singleTapGestureRecognizer2.numberOfTapsRequired = 1
//        singleTapGestureRecognizer2.numberOfTouchesRequired = 1
//        singleTapGestureRecognizer2.enabled = true
//        singleTapGestureRecognizer2.assicatedObject = "\(indexPath.section):\(indexPath.row)"
//        
//        self.starsQuestionsView.userInteractionEnabled = true
//        self.starsQuestionsView.addGestureRecognizer(singleTapGestureRecognizer2)
//    
//    }
    
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
                self.entranceImageView?.assicatedObject = esetUrl
                
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
                            
                            if self.entranceImageView?.assicatedObject == esetUrl {
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
