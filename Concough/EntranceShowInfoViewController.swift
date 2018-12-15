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
    private let imageBasePath: String = ("images" as NSString).stringByAppendingPathComponent("eset")
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var extraDataLabel: UILabel!
    @IBOutlet weak var starredCountLabel: UILabel!
    @IBOutlet weak var entranceYearLabel: UILabel!
    @IBOutlet weak var totalQuestionsLabel: UILabel!
    @IBOutlet weak var entranceImageView: UIImageView!
    @IBOutlet weak var showStarredQuestionButton: UIButton!
    @IBOutlet weak var defaultShowSegment: UISegmentedControl!
    
    @IBOutlet weak var markedQuestionsStackView: UIStackView!
    
    @IBOutlet weak var defaultShowStackView: UIView!
    @IBOutlet weak var examBriefLabel: UILabel!
    @IBOutlet weak var examBriefStackView: UIStackView!
    @IBOutlet weak var lessonExamTimeLabel: UILabel!
    
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var timerImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.questionImageView.tintImageColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0))
        self.timerImageView.tintImageColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0))
        
        // Do any additional setup after loading the view.
        let font = UIFont(name: "IRANSansMobile", size: 12)!
        self.defaultShowSegment.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        
        self.showStarredQuestionButton.layer.cornerRadius = 5.0
        self.showStarredQuestionButton.layer.masksToBounds = true
        self.showStarredQuestionButton.layer.borderColor = self.showStarredQuestionButton.titleColorForState(.Normal)?.CGColor
        self.showStarredQuestionButton.layer.borderWidth = 0.7
        
        self.entranceImageView.layer.cornerRadius = 35.0
        self.entranceImageView.layer.masksToBounds = true
        self.entranceImageView.layer.borderColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.3).CGColor
        self.entranceImageView.layer.borderWidth = 0.5
        
    }

    internal func configureController(entrance entrance: EntranceStructure, starredCount: Int, segmentState: Int, showType: String, totalQuestions: Int, answeredQuestions: Int, lessonTitle: String, lessonExamTime: Int) {
        if entrance.entranceMonth > 0 {
            self.entranceYearLabel.text = "\(monthToString(entrance.entranceMonth!)) \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!)"
        } else {
            self.entranceYearLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(entrance.entranceYear!)!)"
        }

        if showType == "Show" || showType == "Starred" {
            self.titleLabel.text = "آزمون \(entrance.entranceTypeTitle!)"
            self.subTitleLabel.text = "\(entrance.entranceSetTitle!) (\(entrance.entranceGroupTitle!))"
            
            self.extraDataLabel.text = "\(entrance.entranceOrgTitle!)"
            self.defaultShowSegment.selectedSegmentIndex = segmentState
            
        } else if showType == "LessonExam" || showType == "LessonExamResult" {
            self.totalQuestionsLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(totalQuestions)!)"
            self.lessonExamTimeLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(lessonExamTime)!) '"
            self.subTitleLabel.text = lessonTitle
            self.titleLabel.text = "\(entrance.entranceSetTitle!) (\(entrance.entranceGroupTitle!))"
            self.extraDataLabel.hidden = true
        } else if showType == "LessonExamHistory" {
            self.totalQuestionsLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(totalQuestions)!)"
            self.lessonExamTimeLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(lessonExamTime)!) '"
            self.subTitleLabel.text = lessonTitle
            self.titleLabel.text = "\(entrance.entranceSetTitle!) (\(entrance.entranceGroupTitle!))"
            self.extraDataLabel.hidden = true
            
        }
        self.downloadImage(esetId: entrance.entranceSetId!, indexPath: NSIndexPath(forRow: 0, inSection: 0))

        //        if let extraData = entrance.entranceExtraData {
        //            var s = ""
        //            for (key, item) in extraData {
        //                s += "\(key): \(item.stringValue)" + " - "
        //            }
        //
        //            if s.characters.count > 3 {
        //                s = s.substringToIndex(s.endIndex.advancedBy(-3))
        //            }
        //            self.extraDataLabel.text = s
        //        }

        if showType == "Show" || showType == "Starred" {
            self.defaultShowStackView.hidden = false
            self.examBriefStackView.hidden = true
            self.showStarredQuestionButton.hidden = false
            self.markedQuestionsStackView.hidden = false
            
            if showType == "Show" {
                self.starredCountLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(starredCount)!
                self.showStarredQuestionButton.setTitle("سوالات نشان شده", forState: .Normal)
            } else if showType == "Starred" {
                self.showStarredQuestionButton.setTitle("کل سوالات", forState: .Normal)
            }
        } else if showType == "LessonExam" || showType == "LessonExamResult" {
            self.examBriefLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(answeredQuestions)!) " + "سوال از " + "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(totalQuestions)!) " + "جواب داده اید"
            
            self.defaultShowStackView.hidden = true
            self.examBriefStackView.hidden = false
            self.showStarredQuestionButton.hidden = true
            self.markedQuestionsStackView.hidden = true
            
        } else if showType == "LessonExamHistory" {
            self.examBriefLabel.hidden = true
            self.defaultShowStackView.hidden = true
            self.examBriefStackView.hidden = false
            self.showStarredQuestionButton.hidden = true
            self.markedQuestionsStackView.hidden = true
        }
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
//                            print("error in downloaing image from \(fullPath!)")
                        }
                        
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
    
    @IBAction func defaultShowSegmentValueChanged(sender: UISegmentedControl) {
    }
}
