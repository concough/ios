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
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var extraData: UILabel!
    @IBOutlet weak var bookletCount: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var downloadTimes: UILabel!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var entranceImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
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
    }
    
    // MARK: - Functions
    internal func configureCell(entrance entrance: EntranceStructure, purchased: EntrancePrurchasedStructure, indexPath: NSIndexPath) {
        self.title.text = "کنکور \(entrance.entranceTypeTitle!) \(entrance.entranceOrgTitle!) " + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!
        self.subTitle.text = "\(entrance.entranceSetTitle!) (\(entrance.entranceGroupTitle!))"
        
        if let extraData = entrance.entranceExtraData {
            var s = ""
            for (key, item) in extraData {
                s += "\(key): \(item.stringValue)" + " - "
            }
            
            if s.characters.count > 3 {
                s = s.substringToIndex(s.endIndex.advancedBy(-3))
            }
            self.extraData.text = s
        }
        
        self.bookletCount.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceBookletCounts!)! + " دفترچه"
        self.duration.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceDuration!)! + " دقیقه"
        self.downloadTimes.text = "(" + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(purchased.downloaded!)! + " بار دانلود شده است)"
        
        // download Images
        self.downloadImage(esetId: entrance.entranceSetId!, indexPath: indexPath)
        self.progressView.hidden = true
        
    }
    
    internal func addGestures(viewController viewController: FavoritesTableViewController, indexPath: NSIndexPath) {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: viewController, action: #selector(viewController.downloadTapped(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.assicatedObject = "\(indexPath.section):\(indexPath.row)"
        
        self.downloadView.userInteractionEnabled = true
        self.downloadView.addGestureRecognizer(singleTapGestureRecognizer)

    }
    
    internal func changeProgressValue(value value: Int, totalCount: Int) {
        let delta = (Float(totalCount) - Float(value)) / Float(totalCount)
        self.progressView.setProgress(delta, animated: true)
    }
    
    internal func changeToDownloadState() {
        self.progressView.hidden = false
        self.progressView.setProgress(0.0, animated: true)
        self.downloadView.hidden = true
    }
    private func downloadImage(esetId esetId: Int, indexPath: NSIndexPath) {
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
                        // print the error for now
                        self.entranceImageView?.image = UIImage()
                        self.setNeedsLayout()
                        print("error in downloaing image from \(fullPath!)")
                        
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
