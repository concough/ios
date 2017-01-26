//
//  EntranceShowInfoViewController.swift
//  Concough
//
//  Created by Owner on 2017-01-20.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class EntranceShowInfoViewController: UIViewController {

    private let localName: String = "FavoriteVC"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var extraDataLabel: UILabel!
    @IBOutlet weak var starredCountLabel: UILabel!
    @IBOutlet weak var entranceImageView: UIImageView!
    @IBOutlet weak var showStarredQuestionButton: UIButton!
    @IBOutlet weak var showAnswerSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.starredCountLabel.layer.cornerRadius = self.starredCountLabel.layer.frame.width / 2.0
        self.starredCountLabel.layer.masksToBounds = true
    }

    internal func configureController(entrance entrance: EntranceStructure, starredCount: Int, switchState: Bool, showType: String) {
        self.titleLabel.text = "کنکور \(entrance.entranceTypeTitle!) \(entrance.entranceOrgTitle!) \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!)"
        self.subTitleLabel.text = "\(entrance.entranceSetTitle!) (\(entrance.entranceGroupTitle!))"
        
        if let extraData = entrance.entranceExtraData {
            var s = ""
            for (key, item) in extraData {
                s += "\(key): \(item.stringValue)" + " - "
            }
            
            if s.characters.count > 3 {
                s = s.substringToIndex(s.endIndex.advancedBy(-3))
            }
            self.extraDataLabel.text = s
        }
        self.downloadImage(esetId: entrance.entranceSetId!, indexPath: NSIndexPath(forRow: 0, inSection: 0))
        self.showAnswerSwitch.on = switchState

        if showType == "Show" {
            self.starredCountLabel.hidden = false
            self.starredCountLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(starredCount)!
            self.showStarredQuestionButton.setTitle("سوالات نشان شده", forState: .Normal)
        } else if showType == "Starred" {
            self.starredCountLabel.hidden = true
            self.showStarredQuestionButton.setTitle("کل سوالات", forState: .Normal)
        }
    }
    
    private func downloadImage(esetId esetId: Int, indexPath: NSIndexPath) {
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
                        // print the error for now
                        self.entranceImageView?.image = UIImage()
                        print("error in downloaing image from \(fullPath!)")
                        
                    } else {
                        if let myData = data {
                            MediaCacheSingleton.sharedInstance[fullPath!] = myData
                            
                            if self.entranceImageView?.assicatedObject == esetUrl {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.entranceImageView?.image = UIImage(data: myData)
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
    
    // MARK: - Actions
    @IBAction func actionPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
