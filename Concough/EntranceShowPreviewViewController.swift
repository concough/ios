//
//  EntranceShowPreviewViewController.swift
//  Concough
//
//  Created by Owner on 2018-04-12.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

class EntranceShowPreviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionAnswerLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    internal var question: EntranceQuestionModel?
    
    private var starred = false
    private weak var screenshotObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.containerView.layer.cornerRadius = 10.0
        self.containerView.layer.masksToBounds = true
        
        self.closeButton.layer.cornerRadius = 10.0
        self.closeButton.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400.0
        
        self.configreController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        self.addScreenshotObserver()
    }
    
    internal func configreController() {
        self.questionNumberLabel.text = "سوال \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.question!.number)!)"
        self.questionAnswerLabel.text = "گزینه " + questionAnswerToString(self.question!.answer) + " درست است"
        
        
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        if EntranceQuestionStarredModelHandler.get(entranceUniqueId: (self.question?.entrance?.uniqueId)!, questionId: (self.question?.uniqueId)! , username: username) != nil {
            self.starred = true
            self.changeStarState()
        }
        
    }
    
    // BTNavigationDropdownMenu
    private func addScreenshotObserver() {
        if self.screenshotObserver == nil {
            screenshotObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationUserDidTakeScreenshotNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
                
                let time = FormatterSingleton.sharedInstance.UTCShortDateFormatter.stringFromDate(NSDate())
                
                let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                let result = SnapshotCounterHandler.countUpAndCheck(username: username, productUniqueId: (self.question?.entrance?.uniqueId)!, productType: "Entrance", time: time)
                if result.0 {
                    if result.1 {
                        AlertClass.showAlertMessage(viewController: self, messageType: "ActionResult", messageSubType: "BlockedByScreenshot", type: "error", completion: nil)
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    } else {
                        AlertClass.showAlertMessage(viewController: self, messageType: "ActionResult", messageSubType: "ScreenshotTaken", type: "warning", completion: nil)
                    }
                } else {
                    AlertClass.showAlertMessage(viewController: self, messageType: "ActionResult", messageSubType: "ScreenshotTaken", type: "warning", completion: nil)
                }
            }
        }
    }
    
    private func removeScreenshotObserver() {
        if self.screenshotObserver != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self.screenshotObserver!)
            self.screenshotObserver = nil
        }
    }
    
    private func changeStarState() {
        if self.starred == true {
            self.starButton.setImage(UIImage(named: "BookmarkRibbonFilled"), forState: .Normal)
            self.starButton.tintColor = UIColor(netHex: RED_COLOR_HEX_2, alpha: 1.0)
        } else {
            self.starButton.setImage(UIImage(named: "BookmarkRibbon"), forState: .Normal)
            self.starButton.tintColor = UIColor.darkGrayColor()
        }
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        self.removeScreenshotObserver()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func startButtonPressed(sender: UIButton) {
        self.addStarQuestionId(questionId: (self.question?.uniqueId)!, questionNo: (self.question?.number)!)
        self.changeStarState()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.question != nil {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_QUESTION_PREVIEW", forIndexPath: indexPath) as? EntranceShowQuestionPreviewTableViewCell {
            
            
            let images = JSON(data: question!.images.dataUsingEncoding(NSUTF8StringEncoding)!).arrayValue.sort {
                $0["order"].intValue < $1["order"].intValue
            }
            
            let filemgr = NSFileManager.defaultManager()
            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            
            let docsDir = dirPaths[0] as NSString
            
            let username = UserDefaultsSingleton.sharedInstance.getUsername()
            var filePath = docsDir.stringByAppendingPathComponent("\(username!)_\(self.question!.entrance?.uniqueId)")
            
            var isDirectory = ObjCBool(true)
            let exist = filemgr.fileExistsAtPath(filePath, isDirectory: &isDirectory)
            if !exist {
                filePath = docsDir.stringByAppendingPathComponent((self.question!.entrance?.uniqueId)!)
            }
            
            var imagesData = [NSData]()
            for image in images {
                let imageId = image["unique_key"].stringValue
                let filePath = (filePath as NSString).stringByAppendingPathComponent(imageId)
                if filemgr.fileExistsAtPath(filePath) {
                    if let data = filemgr.contentsAtPath(filePath) {
                        imagesData.append(data)
                    }
                }
            }

            cell.configureCell(imagesData)
            return cell
        }
        
        return UITableViewCell()
    }

    internal func addStarQuestionId(questionId questionId: String, questionNo: Int)  {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        if self.starred {
            if let id = self.question!.entrance?.uniqueId {
                if EntranceQuestionStarredModelHandler.remove(entranceUniqueId: id, questionId: questionId, username: username) == true {
                    
                    let eData = JSON(["uniqueId": id, "questionNo": questionNo])
                    self.createLog(logType: LogTypeEnum.EntranceQuestionUnStar.rawValue, extraData: eData)
                    
                    self.starred = !self.starred
                }
            }
            
        } else {
            if let id = self.question!.entrance?.uniqueId {
                if EntranceQuestionStarredModelHandler.add(entranceUniqueId: id, questionId: questionId, username: username) == true {
                    
                    
                    let eData = JSON(["uniqueId": id, "questionNo": questionNo])
                    self.createLog(logType: LogTypeEnum.EntranceQuestionStar.rawValue, extraData: eData)
                    
                    self.starred = !self.starred
                }
            }
        }
    }
    
    private func createLog(logType logType: String, extraData: JSON) {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        let uniqueId = NSUUID().UUIDString
        let created = NSDate()
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            UserLogModelHandler.add(username: username, uniqueId: uniqueId, created: created, logType: logType, extraData: extraData)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
