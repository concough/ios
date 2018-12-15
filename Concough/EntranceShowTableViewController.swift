//
//  EntranceShowTableViewController.swift
//  Concough
//
//  Created by Owner on 2017-01-18.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import BTNavigationDropdownMenu
import EHHorizontalSelectionView

protocol EntranceShowCommentDelegate {
    func addTextComment(questionId questionId: String, questionNo: Int, indexPath: NSIndexPath, commentData: String) -> Bool
    func cancelComment()
    func deleteComment(questionId questionId: String, questionNo: Int, commentId: String, indexPath: NSIndexPath)
}

protocol EntranceLessonExamDelegate {
    func startLessonExam()
    func cancelLessonExam(withLog withLog: Bool)
    func showLessonExamResult()
}

class EntranceShowTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EHHorizontalSelectionViewProtocol, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, EntranceShowCommentDelegate, EntranceLessonExamDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomTimerView: UIView!
    @IBOutlet weak var finishLessonExamButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerTextLabel: UILabel!
    @IBOutlet weak var bottomBackToDefaultView: UIView!
    @IBOutlet weak var examBackToDefaultButton: UIButton!
    
    private weak var screenshotObserver: NSObjectProtocol?

    private var hSelView: EHHorizontalSelectionView!
    private var menuView: BTNavigationDropdownMenu?
    private var cellHeightsDictionary: [NSIndexPath: CGFloat] = [:]

    internal var entranceUniqueId: String!
    internal var entrance: EntranceStructure!
    internal var showType: String = "Show"
    
    private var entranceDb: EntranceModel!
    private var bookletsDb: List<EntranceBookletModel>!
    private var lessonsDB: List<EntranceLessonModel>!
    private var questionsDB: List<EntranceQuestionModel>!
    
    private var bookletsString: [String] = []
    private var booklet: String?
    private var lessonsString: [String] = []

    private var selectedLesson: Int = -1
    private var selectedBooklet: Int = -1
    
    private var imagesRepo: [String: NSData] = [:]
    private var showedAnswer: [String: EntranceQuestionAnswerState] = [:]
    private var starred: [String] = []
    private var starredQuestions: [(lessonId: String, lessonTitle: String, count: Int, questions: [EntranceQuestionModel])] = []
    
    private var DefaultShowType: EntranceQuestionAnswerState = .NONE
    private var topSection: Int = -1
    
    private var lastTableState: EntranceLastVisitInfoModel?
    
    // lesson exam variables
    private var examTimer: NSTimer!
//    private var lessonExamStartTime: NSDate!
//    private var lessonExamAnswer: [String: Int] = [:]
    private var lessonExamStruct: EntranceLessonExamStructure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: .Plain, target: self, action: #selector(self.infoButtonPressed(_:)))
        
        self.bottomTimerView.hidden = true
        self.bottomBackToDefaultView.hidden = true

        self.initializeHorizontalView()

        self.finishLessonExamButton.layer.cornerRadius = 10.0
        self.finishLessonExamButton.layer.masksToBounds = true
        self.examBackToDefaultButton.layer.cornerRadius = 10.0
        self.examBackToDefaultButton.layer.masksToBounds = true
        
        self.loadLastTableState()
        self.loadEntranceDB()
        self.loadStarredQuestion()
        self.loadBooklets()
        self.loadStarredQuestionsRecord()
        
 
        // Add Entrance Opened record
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        EntranceOpenedCountModelHandler.update(entranceUniqueId: self.entranceUniqueId, type: self.showType, username: username)

        // Create Log
        let eData = JSON(["uniqueId": self.entranceUniqueId])
        if self.showType == "Show" {
            self.createLog(logType: LogTypeEnum.EntranceShowNormal.rawValue, extraData: eData)
        } else if self.showType == "Starred" {
            self.createLog(logType: LogTypeEnum.EntranceShowStarred.rawValue, extraData: eData)
        }
        

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .None
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        self.addScreenshotObserver()
        
        if self.showType == "Starred" {
            // load starredQuestions
            self.title = "سوالات نشان شده (" + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.starred.count)! + ")"
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        UIApplication.sharedApplication().idleTimerDisabled = false
        self.saveLastTableState()
    }

    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = false
        self.menuView?.hide()
        self.saveLastTableState()
    }
    
    deinit {
        self.removeScreenshotObserver()
    }
    // BTNavigationDropdownMenu
    private func addScreenshotObserver() {
        if self.screenshotObserver == nil {
        screenshotObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationUserDidTakeScreenshotNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
            
            let time = FormatterSingleton.sharedInstance.UTCShortDateFormatter.stringFromDate(NSDate())
            
            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
            let result = SnapshotCounterHandler.countUpAndCheck(username: username, productUniqueId: self.entranceUniqueId, productType: "Entrance", time: time)
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
    
    private func configureMenu() {
        if self.bookletsString.count > 0 {
            self.menuView = BTNavigationDropdownMenu(title: self.bookletsString[self.selectedBooklet], items: self.bookletsString)
            self.menuView?.didSelectItemAtIndexHandler = self.menuItemSelected
            
            // View Customizations
            self.menuView?.cellSeparatorColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.3)
            self.menuView?.cellTextLabelFont = UIFont(name: "IRANSansMobile", size: 13)
            self.menuView?.navigationBarTitleFont = UIFont(name: "IRANSansMobile-Medium", size: 14)
            self.menuView?.cellTextLabelAlignment = NSTextAlignment.Center
            self.menuView?.arrowTintColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
            self.menuView?.arrowTintColor = UIColor.blackColor()
            
            if self.showType == "Show" {
                self.navigationItem.titleView = self.menuView
                
            }
        }
        
    }
    
    private func menuItemSelected(indexPath indexPath: Int) {
        self.booklet = self.bookletsString[indexPath]
        //let bookletUniqueId = self.booklets[self.booklet!]
        self.selectedBooklet = indexPath
        self.loadLessons()
    }

    // EHHorizontalSelectionView methods
    private func initializeHorizontalView() {
        self.hSelView = EHHorizontalSelectionView(frame: CGRectMake(0.0, 0.0, self.tableView.layer.frame.width, 45.0))
        self.hSelView?.delegate = self
        
        let bottonView = UIView(frame:  CGRectMake(0.0, 45.0, self.tableView.layer.frame.width, 1.0))
        bottonView.backgroundColor = UIColor(netHex: 0xDDDDDD, alpha: 1.0)
        self.hSelView?.addSubview(bottonView)

        
        self.hSelView?.registerCellWithClass(EHHorizontalLineViewCell)
        EHHorizontalLineViewCell.updateColorHeight(0.8)
        
        self.hSelView?.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        //self.hSelView?.backgroundColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.95)
        self.hSelView?.textColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        self.hSelView?.tintColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
//        self.hSelView?.textColor = UIColor.whiteColor()
//        self.hSelView?.tintColor = UIColor.whiteColor()
        //self.hSelView?.textColor = UIColor(white: 0.0, alpha: 0.7)
        //self.hSelView?.tintColor = self.hSelView?.textColor
        
        
        self.hSelView?.font = UIFont(name: "IRANSansMobile-Medium", size: 13)
        self.hSelView?.fontMedium = UIFont(name: "IRANSansMobile-Bold", size: 13)
        
        self.hSelView?.semanticContentAttribute = UISemanticContentAttribute.ForceRightToLeft
        self.hSelView?.cellGap = 25.0
    }
    
    func numberOfItemsInHorizontalSelection(hSelView: EHHorizontalSelectionView) -> UInt {
        return UInt(self.lessonsString.count)
    }
    
    func titleForItemAtIndex(index: UInt, forHorisontalSelection hSelView: EHHorizontalSelectionView) -> String? {
        return self.lessonsString[Int(index)]
    }
    
    func horizontalSelection(hSelView: EHHorizontalSelectionView, didSelectObjectAtIndex index: UInt) {
        self.selectedLesson = Int(index)
        self.loadQuestions()
        self.showedAnswer.removeAll()
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            if self.showType == "Show" {
                self.tableView.reloadData()
                
                if let lte = self.lastTableState {
                    let splited = lte.index.characters.split(":").map(String.init)

                    if Int(splited[0])! < self.tableView.numberOfSections && Int(splited[1])! < self.tableView.numberOfRowsInSection(Int(splited[0])!) {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: Int(splited[1])!, inSection: Int(splited[0])!), atScrollPosition: UITableViewScrollPosition.Middle , animated: true)
                    } else {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
                    }
                    self.lastTableState = nil
                } else {
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
                    
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func infoButtonPressed(sender: UIBarButtonItem) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("EntranceShowInfoVCSegue", sender: self)
        }
    }
    
    @IBAction func showAllAnswerValueChanged(sender: UISwitch) {
//        self.ShowAllAnswer = !self.ShowAllAnswer
        // TODO
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.tableView.reloadData()
        }
    }
    
    @IBAction func showStarredQuestionPressed(sender: UIButton) {
        if self.showType == "Show" {
            // load starredQuestions
            
            self.navigationItem.titleView = nil
            self.navigationItem.title = "سوالات نشان شده (" + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.starred.count)! + ")"
            
            self.showType = "Starred"
            self.menuView?.hide()
        } else if self.showType == "Starred" {
            self.navigationItem.titleView = self.menuView
            self.showType = "Show"
        }

        // Add Entrance Opened record
//        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
//        EntranceOpenedCountModelHandler.update(entranceUniqueId: self.entranceUniqueId, type: self.showType, username: username)
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.tableView.reloadData()
        }
    }

    @IBAction func defaultShowSegmentValueChanged(sender: UISegmentedControl) {
        let selected = sender.selectedSegmentIndex
        
        switch selected {
        case 0:
            self.DefaultShowType = .STATS
        case 1:
            self.DefaultShowType = .COMMENTS
        case 2:
            self.DefaultShowType = .ANSWER
        default:
            self.DefaultShowType = .NONE
        }
        
        self.tableView.reloadData()
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func finishExamPressed(sender: UIButton) {
        let msg = AlertClass.convertMessage(messageType: "ExamAction", messageSubType: "FinishEntranceExam")
        if msg.showMsg {
            AlertClass.showAlertMessageCustom(viewController: self, title: msg.title, message: msg.message, yesButtonTitle: "اتمام سنجش", noButtonTitle: "دستم خورد", completion: {
                    let msg2 = AlertClass.convertMessage(messageType: "ExamAction", messageSubType: "FinishEntranceExamResult")
                
                    AlertClass.showSuccessMessageCustom(viewController: self, title: msg2.title, message: msg2.message, yesButtonTitle: "محاسبه نتیجه", noButtonTitle: "انصراف از سنجش", completion: {
                        self.finishExam()

                        }, noCompletion: { 
                            self.cancelLessonExam(withLog: true)
                    })
                
                }, noCompletion: nil)
        }
        
    }
    
    @IBAction func lessonExamBackToDefaultPressed(sender: UIButton) {
        self.cancelLessonExam(withLog: false)
    }

    // MARK: - Functions    
    private func finishExam() {
        self.examTimer?.invalidate()
        self.examTimer = nil
        
        if self.lessonExamStruct != nil {
            self.lessonExamStruct!.finished = NSDate()
            
            if self.lessonExamStruct!.answers.count > 0 {
                
                var trueCount = 0
                var falseCount = 0
                
                for answer in self.lessonExamStruct!.answers {
                    let item = self.questionsDB[answer.0]
                    if item.answer == answer.1 {
                        trueCount += 1
                    } else {
                        falseCount += 1
                    }
                }
                
                self.lessonExamStruct!.trueAnswer = trueCount
                self.lessonExamStruct!.falseAnswer = falseCount
                self.lessonExamStruct!.noAnswer = self.lessonExamStruct!.qCount! - self.lessonExamStruct!.answers.count
                
                self.lessonExamStruct!.percentage = Double((trueCount * 3) + (falseCount * -1)) / Double(self.lessonExamStruct!.qCount! * 3)
                
                // save data in database
                let loading = AlertClass.showLoadingMessage(viewController: self)
                
                var answersLocal: [String: Int] = [:]
                for item in self.lessonExamStruct!.answers {
                    answersLocal.updateValue(item.1, forKey: "\(self.questionsDB[item.0].number)")
                }
                let answersJson = JSON(answersLocal)
                
                let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                EntranceLessonExamModelHandler.add(username: username, entrancedUniqueId: self.entranceUniqueId, examStruct: self.lessonExamStruct!, created: NSDate(), data: answersJson.rawString()!)
                
                for i in 0..<self.questionsDB.count {
                    if let ans = self.lessonExamStruct!.answers[i] {
                        if self.translateAnswer(answer: self.questionsDB[i].answer).contains(ans) {
                            EntranceQuestionExamStatModelHandler.update(username: username, entranceUniqueId: self.entranceUniqueId, questionNo: self.questionsDB[i].number, answerState: 1)
                            
                        } else {
                            EntranceQuestionExamStatModelHandler.update(username: username, entranceUniqueId: self.entranceUniqueId, questionNo: self.questionsDB[i].number, answerState: -1)
                            
                        }
                    } else {
                        EntranceQuestionExamStatModelHandler.update(username: username, entranceUniqueId: self.entranceUniqueId, questionNo: self.questionsDB[i].number, answerState: 0)
                    }
                }
                
                // create log
                let eData = JSON(["uniqueId": self.entranceUniqueId, "bookletOrder": self.bookletsDb[self.selectedBooklet].order , "lessonOrder": self.lessonsDB[self.selectedLesson].order, "lessonString": self.lessonsDB[self.selectedLesson].fullTitle, "started": FormatterSingleton.sharedInstance.UTCDateFormatter.stringFromDate(self.lessonExamStruct!.started!), "finished": FormatterSingleton.sharedInstance.UTCDateFormatter.stringFromDate(self.lessonExamStruct!.finished!), "qCount": self.lessonExamStruct!.qCount!, "trueAnswer": trueCount, "falseAnswer": falseCount, "duration": self.lessonExamStruct!.duration!, "percentage": self.lessonExamStruct!.percentage, "answers": answersLocal])
                self.createLog(logType: LogTypeEnum.EntranceLessonExamFinished.rawValue, extraData: eData)
                
                
                AlertClass.hideLoaingMessage(progressHUD: loading)
                
                if let modalViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ENTRANCE_LESSON_EXAM_RESULT") as? EntranceLessonExamResultViewController {
                    
                    modalViewController.examDelegate = self
                    modalViewController.entranceLessonExamStruct = self.lessonExamStruct!
                    modalViewController.modalPresentationStyle = .Custom
                    modalViewController.modalTransitionStyle = .CrossDissolve
                    self.presentViewController(modalViewController, animated: true, completion: nil)
                }
                
            } else {
                self.cancelLessonExam(withLog: true)
            }
        } else {
            self.cancelLessonExam(withLog: false)
        }
    }
    
    private func translateAnswer(answer answer: Int) -> [Int] {
        switch answer {
        case 0: fallthrough
        case 1: fallthrough
        case 2: fallthrough
        case 3: fallthrough
        case 4:
            return [answer]
        case 5:
            return [1, 2]
        case 6:
            return [1, 3]
        case 7:
            return [1, 4]
        case 8:
            return [2, 3]
        case 9:
            return [2, 4]
        case 10:
            return [3, 4]
        default:
            return []
        }
    }
    
    func cancelLessonExam(withLog withLog: Bool) {
        if self.examTimer != nil {
            self.examTimer.invalidate()
            self.examTimer = nil
        }
        if withLog {
            if self.lessonExamStruct != nil {
                self.lessonExamStruct!.finished = NSDate()
            
                var trueCount = 0
                var falseCount = 0

                if self.lessonExamStruct!.answers.count > 0 {
                    for answer in self.lessonExamStruct!.answers {
                        let item = self.questionsDB[answer.0]
                        if item.answer == answer.1 {
                            trueCount += 1
                        } else {
                            falseCount += 1
                        }
                    }
                }
                
                let eData = JSON(["uniqueId": self.entranceUniqueId, "bookletOrder": self.bookletsDb[self.selectedBooklet].order , "lessonOrder": self.lessonsDB[self.selectedLesson].order, "lessonString": self.lessonsDB[self.selectedLesson].fullTitle, "started": FormatterSingleton.sharedInstance.UTCDateFormatter.stringFromDate(self.lessonExamStruct!.started!), "finished": FormatterSingleton.sharedInstance.UTCDateFormatter.stringFromDate(self.lessonExamStruct!.finished!), "qCount": self.lessonExamStruct!.qCount!, "trueAnswer": trueCount, "falseAnswer": falseCount, "duration": self.lessonExamStruct!.duration!])
                self.createLog(logType: LogTypeEnum.EntranceLessonExamCancel.rawValue, extraData: eData)
                
            }
        }
        
        self.lessonExamStruct = nil
        self.timerTextLabel.text = " "
        self.timerLabel.text = " "
        
        self.tableView.tableFooterView = UIView()
        self.bottomTimerView.hidden = true
        self.bottomBackToDefaultView.hidden = true
        self.navigationItem.titleView = self.menuView
        self.showType = "Show"
        self.tableView.reloadData()
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        self.navigationItem.hidesBackButton = false
        
    }
    
    func showLessonExamResult() {
        if self.examTimer != nil {
            self.examTimer.invalidate()
            self.examTimer = nil
        }

        self.timerTextLabel.text = " "
        self.timerLabel.text = " "

        self.bottomBackToDefaultView.hidden = false
        self.bottomTimerView.hidden = true
        
        self.showType = "LessonExamResult"
        self.tableView.reloadData()
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        self.navigationItem.hidesBackButton = false
    }
    
    private func loadLastTableState() {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        
        self.lastTableState = EntranceLastVisitInfoModelHandler.get(username: username, uniqueId: self.entranceUniqueId, showType: self.showType)
    }
    
    private func saveLastTableState() {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        
        // get current position of table
        if self.selectedBooklet >= 0 && self.selectedLesson >= 0 {
            if self.showType == "Show" {
                var index = "0:0"
                var row = 0
                if let indexes = self.tableView.indexPathsForVisibleRows {
                    if indexes.count >= 2 {
                        if indexes[1].row >= 2 {
                            index = "\(indexes[1].section):\(indexes[1].row)"
                            row = indexes[1].row
                            if row >= self.questionsDB.count {
                                row = self.questionsDB.count - 1
                            }
                        }
                    } else if indexes.count >= 1 {
                        if indexes[0].row >= 2 {
                            index = "\(indexes[0].section):\(indexes[0].row)"
                            row = indexes[0].row
                            if row >= self.questionsDB.count {
                                row = self.questionsDB.count - 1
                            }
                        }
                    }
                    
                }
                
                let updated = EntranceLastVisitInfoModelHandler.update(username: username, uniqueId: self.entranceUniqueId, bookletIndex: self.selectedBooklet, lessonIndex: self.selectedLesson, index: index, updated: NSDate(), showType: self.showType)
                
                if updated {
                    let eData = JSON(["uniqueId": self.entranceUniqueId, "bookletIndex": self.selectedBooklet, "bookletString": self.bookletsString[self.selectedBooklet], "lessonIndex": self.selectedLesson, "lessonString": self.lessonsString[self.selectedLesson], "question": self.questionsDB[row].number])
                    self.createLog(logType: LogTypeEnum.EntranceLastVisitInfo.rawValue, extraData: eData)
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
    
    private func loadEntranceDB() {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        if let item = EntranceModelHandler.getByUsernameAndId(id: self.entranceUniqueId, username: username) {
            self.entranceDb = item
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func loadStarredQuestion() {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        let items = EntranceQuestionStarredModelHandler.getStarredQuestions(entranceUniqueId: self.entranceUniqueId, username: username)
        self.starred.removeAll()
        
        if items.count > 0 {
            for item in items {
                self.starred.append(item.question!.uniqueId)
            }
        }
    }
    
    private func loadStarredQuestionsRecord() {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        let items = EntranceQuestionModelHandler.getStarredQuestions(entranceId: self.entranceUniqueId, questions: self.starred, username: username)
        
        self.starredQuestions.removeAll()
        for item in items {
            if let index = self.starredQuestions.indexOf({(id, lesson, count, questions) -> Bool in
                if item.lesson.first?.uniqueId == id {
                    return true
                }
                return false
            }) {
                
                let record = self.starredQuestions[index]
                var questions = record.questions
                questions.append(item)
                
                let question = (lessonId: record.lessonId, lessonTitle: record.lessonTitle , count: record.count + 1, questions: questions)
                
                self.starredQuestions[index] = question
            } else {
                self.starredQuestions.append((lessonId: (item.lesson.first?.uniqueId)!, lessonTitle: (item.lesson.first?.title)!, count: 1, questions: [item]))
            }
        }
    }
    
    private func loadBooklets() {
        self.bookletsDb = self.entranceDb.booklets
        
        for item in self.bookletsDb {
            self.bookletsString.append(item.title)
            //self.booklets.updateValue(item.uniqueId, forKey: item.title)
        }

        if self.bookletsString.count > 0 {
            self.selectedBooklet = 0
            
            if let lte = self.lastTableState {
                self.selectedBooklet = lte.bookletIndex
            }            
            self.configureMenu()
            self.loadLessons()
        }
    }
    
    private func loadLessons() {
        if self.selectedBooklet >= 0 {
            self.lessonsDB = List(self.bookletsDb[self.selectedBooklet].lessons.sorted("order", ascending: false))
         
            self.lessonsString.removeAll()
            for item in self.lessonsDB {
                self.lessonsString.append(item.title)
            }
            //self.lessonsString = self.lessonsString.reverse()
            
            // update horizontal Menu
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.hSelView?.reloadData()
                
                if self.lessonsString.count > 0 {
                    if let lte = self.lastTableState {
                        self.hSelView?.selectIndex(UInt(lte.lessonIndex))
                    } else {
                        self.hSelView?.selectIndex(UInt(self.lessonsString.count - 1))
                    }
                    
                }
            })
            
        }
    }
    
    private func loadQuestions() {
        if self.selectedLesson >= 0 {
            self.questionsDB = List(self.lessonsDB[self.selectedLesson].questions.sorted("number", ascending: true))
            self.cellHeightsDictionary = [:]
        }
    }
    
    internal func changeQuestionAnswerContainerState(indexPath indexPath: NSIndexPath, questionId: String, state: EntranceQuestionAnswerState) {
        self.showedAnswer.updateValue(state, forKey: questionId)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    internal func scrollTableViewToComment(indexPath indexPath: NSIndexPath) {
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    internal func newCommentOnQuestionClicked(indexPath indexPath: NSIndexPath, questionId: String) {
        self.removeScreenshotObserver()
    }
    
    internal func lessonExamQuestionAnswered(indexPath indexPath: NSIndexPath, questionId: String, answer: Int) {
        if self.showType == "LessonExam" {
            if self.lessonExamStruct != nil {
                self.lessonExamStruct!.answers.updateValue(answer, forKey: indexPath.row)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    self.timerTextLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.lessonExamStruct!.answers.count)!)/\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.lessonExamStruct!.qCount!)!)"
                })
            }
        }
    }

    internal func lessonExamQuestionCleared(indexPath indexPath: NSIndexPath, questionId: String) {
        if self.showType == "LessonExam" {
            if self.lessonExamStruct != nil {
                self.lessonExamStruct!.answers.removeValueForKey(indexPath.row)

                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.timerTextLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.lessonExamStruct!.answers.count)!)/\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.lessonExamStruct!.qCount!)!)"
                })
            }
        }
    }
    
    
    
//    internal func addAnsweredQuestionId(questionId questionId: String) {
//        if self.showedAnswer.contains(questionId) == false {
//            self.showedAnswer.append(questionId)
//        }
//    }

    internal func addStarQuestionId(questionId questionId: String, questionNo: Int, state: Bool) -> Bool {
        var flag = false
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        if state == true {
            if self.starred.contains(questionId) == false {
                if EntranceQuestionStarredModelHandler.add(entranceUniqueId: self.entranceUniqueId, questionId: questionId, username: username) == true {
                    
                    self.starred.append(questionId)
                    flag = true
                    
                    let eData = JSON(["uniqueId": self.entranceUniqueId, "questionNo": questionNo])
                    self.createLog(logType: LogTypeEnum.EntranceQuestionStar.rawValue, extraData: eData)
                }
            }
        } else {
            if self.starred.contains(questionId) == true {
                if EntranceQuestionStarredModelHandler.remove(entranceUniqueId: self.entranceUniqueId, questionId: questionId, username: username) == true {
                    
                    let index = self.starred.indexOf(questionId)!
                    self.starred.removeAtIndex(index)
                    flag = true

                    let eData = JSON(["uniqueId": self.entranceUniqueId, "questionNo": questionNo])
                    self.createLog(logType: LogTypeEnum.EntranceQuestionUnStar.rawValue, extraData: eData)
                }
            }
        }
        
        self.loadStarredQuestionsRecord()

        if self.showType == "Starred" {            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.navigationItem.title = "سوالات نشان شده (" + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.starred.count)! + ")"
                self.tableView.reloadData()
            })
        }
        
        return flag
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.showType == "Show" || self.showType == "LessonExam" || self.showType == "LessonExamResult" {
            return 1
        } else if self.showType == "Starred" {
            return self.starredQuestions.count
        }
        
        return 0
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showType == "Show" {
            if self.selectedLesson >= 0 {
                return self.questionsDB.count + 1
            }
        } else if self.showType == "Starred" {
            return self.starredQuestions[section].questions.count
        } else if self.showType == "LessonExam" || self.showType == "LessonExamResult" {
            return self.questionsDB.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.cellHeightsDictionary.updateValue(cell.frame.size.height, forKey: indexPath)
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? EntranceShowQuestionTableViewCell {
                cell.setNeedsUpdateConstraints()
                cell.setNeedsLayout()
            } else if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? EntranceShowQuestionExamTableViewCell {
                cell.setNeedsUpdateConstraints()
                cell.setNeedsLayout()
                
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var mustShowHeaderInfo = false
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if self.showType == "Show" {
                    mustShowHeaderInfo = true
                }
            }
        }

        if mustShowHeaderInfo {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_LESSON_HEADER_TEST", forIndexPath: indexPath) as? EntranceLessonHeaderTestTableViewCell {
                let username = UserDefaultsSingleton.sharedInstance.getUsername()!

                let count = EntranceLessonExamModelHandler.getExamsCount(username: username, entranceUniqueId: self.entranceUniqueId, lessonTitle: self.lessonsDB[self.selectedLesson].fullTitle , lessonOrder: self.lessonsDB[self.selectedLesson].order, bookletOrder: self.bookletsDb[self.selectedBooklet].order)

                let sum = EntranceLessonExamModelHandler.getPercentageSum(username: username, entranceUniqueId: self.entranceUniqueId, lessonTitle: self.lessonsDB[self.selectedLesson].fullTitle , lessonOrder: self.lessonsDB[self.selectedLesson].order, bookletOrder: self.bookletsDb[self.selectedBooklet].order)
                
                var average: Double = 0.0
                if count > 0 {
                    average = sum / Double(count)
                }
                
                let lastExam = EntranceLessonExamModelHandler.getLastExam(username: username, entranceUniqueId: self.entranceUniqueId, lessonTitle: self.lessonsDB[self.selectedLesson].fullTitle , lessonOrder: self.lessonsDB[self.selectedLesson].order, bookletOrder: self.bookletsDb[self.selectedBooklet].order)
                
                cell.configureCell(viewController: self, vcType: "E", examCount: count, examAverage: average, lastExam: lastExam, lessonTitle: self.lessonsDB[self.selectedLesson].fullTitle, lessonOrder: self.lessonsDB[self.selectedLesson].order, bookletOrder: self.bookletsDb[self.selectedBooklet].order)
                return cell
            }
        } else {
            if self.showType == "Show" || self.showType == "Starred" {
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_QUESTION", forIndexPath: indexPath) as? EntranceShowQuestionTableViewCell {
                    
                    
                    var ind = indexPath.row - 1
                    if self.showType == "Starred" {
                        ind += 1
                    }
                    
                    var question: EntranceQuestionModel? = nil
                    if self.showType == "Show" {
                        question = self.questionsDB[ind]
                    } else if self.showType == "Starred" {
                        question = self.starredQuestions[indexPath.section].questions[ind]
                    }
                    
                    let images = JSON(data: question!.images.dataUsingEncoding(NSUTF8StringEncoding)!).arrayValue.sort {
                        $0["order"].intValue < $1["order"].intValue
                    }
                    
                    let filemgr = NSFileManager.defaultManager()
                    let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                    
                    let docsDir = dirPaths[0] as NSString
                    
                    let username = UserDefaultsSingleton.sharedInstance.getUsername()
                    var filePath = docsDir.stringByAppendingPathComponent("\(username!)_\(self.entranceUniqueId)")
                    
                    var isDirectory = ObjCBool(true)
                    let exist = filemgr.fileExistsAtPath(filePath, isDirectory: &isDirectory)
                    if !exist {
                        filePath = docsDir.stringByAppendingPathComponent(self.entranceUniqueId)
                    }
                    
                    var imagesData = [NSData]()
                    for image in images {
                        let imageId = image["unique_key"].stringValue
                        if self.imagesRepo.keys.contains(imageId) == true {
                            imagesData.append(self.imagesRepo[imageId]!)
                        } else {
                            // open it from file
                            
                            let filePath = (filePath as NSString).stringByAppendingPathComponent(imageId)
                            if filemgr.fileExistsAtPath(filePath) {
                                if let data = filemgr.contentsAtPath(filePath) {
                                    self.imagesRepo[imageId] = data
                                    imagesData.append(data)
                                }
                            }
                            
                        }
                    }
                    
                    var showAnswer = EntranceQuestionAnswerState.NONE
                    
                    if self.showedAnswer.keys.contains(question!.uniqueId) {
                        showAnswer = self.showedAnswer[question!.uniqueId]!
                    }
                    
                    if self.DefaultShowType != .NONE {
                        showAnswer = self.DefaultShowType
                    }
                    
                    var starredFlag = false
                    if self.starred.contains(question!.uniqueId) {
                        starredFlag = true
                    }
                    
                    // get comment count and last data
                    let commentCount = EntranceQuestionCommentModelHandler.getCommentsCount(entranceUniqueId: self.entranceUniqueId, questionId: question!.uniqueId, username: username!)
                    let lastComment = EntranceQuestionCommentModelHandler.getLastComment(entranceUniqueId: self.entranceUniqueId, questionId: question!.uniqueId, username: username!)
                    
                    cell.configureCell(viewController: self, vcType: "E", indexPath: indexPath, question: question!.number, questionId: question!.uniqueId, answer: question!.answer, starred: starredFlag, images: imagesData, showAnswer: showAnswer, commentsCount: commentCount, lastComment: lastComment)
                    return cell
                }

            } else if self.showType == "LessonExam" || self.showType == "LessonExamResult" {
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_QUESTION_EXAM", forIndexPath: indexPath) as? EntranceShowQuestionExamTableViewCell {
                    
                    let ind = indexPath.row
                    var question: EntranceQuestionModel? = nil
                    question = self.questionsDB[ind]
                    
                    let images = JSON(data: question!.images.dataUsingEncoding(NSUTF8StringEncoding)!).arrayValue.sort {
                        $0["order"].intValue < $1["order"].intValue
                    }
                    
                    let filemgr = NSFileManager.defaultManager()
                    let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                    
                    let docsDir = dirPaths[0] as NSString
                    
                    let username = UserDefaultsSingleton.sharedInstance.getUsername()
                    var filePath = docsDir.stringByAppendingPathComponent("\(username!)_\(self.entranceUniqueId)")
                    
                    var isDirectory = ObjCBool(true)
                    let exist = filemgr.fileExistsAtPath(filePath, isDirectory: &isDirectory)
                    if !exist {
                        filePath = docsDir.stringByAppendingPathComponent(self.entranceUniqueId)
                    }
                    
                    var imagesData = [NSData]()
                    for image in images {
                        let imageId = image["unique_key"].stringValue
                        if self.imagesRepo.keys.contains(imageId) == true {
                            imagesData.append(self.imagesRepo[imageId]!)
                        } else {
                            // open it from file
                            
                            let filePath = (filePath as NSString).stringByAppendingPathComponent(imageId)
                            if filemgr.fileExistsAtPath(filePath) {
                                if let data = filemgr.contentsAtPath(filePath) {
                                    self.imagesRepo[imageId] = data
                                    imagesData.append(data)
                                }
                            }
                            
                        }
                    }
                    
                    var st = "Exam"
                    var lqn = 0
                    
                    if self.showType == "LessonExam" {
                        st = "Exam"
                    } else if self.showType == "LessonExamResult" {
                        st = "ExamResult"
                    }
                    
                    if self.lessonExamStruct != nil {
                        if self.lessonExamStruct!.answers.keys.contains(ind) {
                            lqn = self.lessonExamStruct!.answers[ind]!
                        }
                    }
                    
                    cell.configureCell(viewController: self, vcType: "E", indexPath: indexPath, question: question!.number, questionId: question!.uniqueId, images: imagesData, lastQuestionNo: self.lessonsDB[self.selectedLesson].qEnd, answered: lqn, correctAnswer: self.questionsDB[ind].answer, showType: st)
                    return cell
                }
            }
        }        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.showType == "Show" {
            if section == 0 {
                let view1 = UIView(frame: CGRectMake(0.0, 0.0, self.tableView.layer.frame.width, 45.0))
                view1.addSubview(self.hSelView)
                return view1
            }
        } else if self.showType == "Starred" {
            if let view1 = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_STARRED_QUESTION") as? StarredQuestionHeaderCell  {
                
                view1.configureHeader(title: self.starredQuestions[section].lessonTitle, count: FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.starredQuestions[section].count)!)
                
                return view1.contentView
//                if let header = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") {
//                    header.backgroundColor = UIColor.clearColor()
//                    header.contentView.backgroundColor = UIColor(netHex: 0xEEEEEE, alpha: 1.0)
//
//                    header.addSubview(view1.contentView)
//                    return header
//                }
            } /*else {
                let view1 = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! StarredQuestionHeaderView
                view1.configure(title: self.starredQuestions[section].lessonTitle, count: FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.starredQuestions[section].count)!)
                return view1
            }*/
        } else {
            return nil
        }
        
        return UIView()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.showType == "Show" {
            if section == 0 {
                return 45.0
            }
        } else if self.showType == "Starred" {
            return 40.0
        }
        return 0.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = self.cellHeightsDictionary[indexPath] {
            return height
        }
        
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Delegates
    func addTextComment(questionId questionId: String, questionNo: Int, indexPath: NSIndexPath, commentData: String) -> Bool {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        let result = EntranceQuestionCommentModelHandler.add(entranceUniqueId: self.entranceUniqueId, username: username, questionId: questionId, commentType: EntranceCommentType.TEXT.rawValue, commentData: commentData)
        
        if result != nil {
            let comment = JSON.parse(commentData)
            
            let eData = JSON(["uniqueId": self.entranceUniqueId, "questionNo": questionNo, "commentType": "TEXT", "data": ["text": comment["text"].stringValue], "commentId": result!.uniqueId])

            createLog(logType: LogTypeEnum.EntranceCommentCreate.rawValue, extraData: eData)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.addScreenshotObserver()
            
            return true
        }
        return false
    }
    
    func cancelComment() {
        self.addScreenshotObserver()
    }

    func deleteComment(questionId questionId: String, questionNo: Int, commentId: String, indexPath: NSIndexPath) {
        let eData = JSON(["uniqueId": self.entranceUniqueId, "questionNo": questionNo, "commentId": commentId])
        createLog(logType: LogTypeEnum.EntranceCommentDelete.rawValue, extraData: eData)
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func startLessonExam() {
        let loading = AlertClass.showMakeExamMessage(viewController: self)
        
        self.navigationItem.titleView = nil
        self.navigationItem.title = "سنجش درس"
        
        self.showType = "LessonExam"
        
        self.bottomTimerView.hidden = false
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 44.0))
        self.navigationItem.hidesBackButton = true
        
        self.cellHeightsDictionary.removeAll()
        self.lessonExamStruct = EntranceLessonExamStructure()
        self.lessonExamStruct?.qCount = self.lessonsDB[self.selectedLesson].qCount
        self.lessonExamStruct?.duration = self.lessonsDB[self.selectedLesson].duration
        self.lessonExamStruct?.started = NSDate()
        self.lessonExamStruct?.order = self.lessonsDB[self.selectedLesson].order
        self.lessonExamStruct?.title = self.lessonsDB[self.selectedLesson].fullTitle
        self.lessonExamStruct?.withTime = false
        self.lessonExamStruct?.bookletOrder = self.bookletsDb[self.selectedBooklet].order
        
        self.tableView.reloadData()
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            
            AlertClass.hideLoaingMessage(progressHUD: loading)
            
            self.examTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.examTimerTick), userInfo: nil, repeats: true)
            
            NSRunLoop.mainRunLoop().addTimer(self.examTimer, forMode: NSRunLoopCommonModes)
        }
    }
    
    @objc private func examTimerTick() {
        let currentTime = NSDate()
        let hourMinuteSecond: NSCalendarUnit = [.Hour, .Minute, .Second]
        
        let diff = NSCalendar.currentCalendar().components(hourMinuteSecond, fromDate: self.lessonExamStruct!.started!, toDate: currentTime, options: [])
        
        var str = ""
        
        if diff.hour > 0 {
            let h = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(diff.hour)!
            str += "\(h) : "
        }
        
        var m = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(diff.minute)!
        if m.characters.count == 1 {
            m = "۰\(m)"
        }
        str += "\(m) : "
        
        var s = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(diff.second)!
        if s.characters.count == 1 {
            s = "۰\(s)"
        }
        str += "\(s)"
        
        let factor = (diff.hour * 60) + diff.minute
        if factor >= self.lessonsDB[self.selectedLesson].duration {
            self.timerLabel.textColor = UIColor(netHex: ORANGE_COLOR_HEX, alpha: 1.0)
        }
        
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.timerLabel.text = str
        }
    }
    
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
//        if viewController is FavoritesTableViewController {
//            //viewController.tabBarController?.tabBar.hidden = false
//        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        if let controller = popoverPresentationController.presentedViewController as? EntranceShowInfoViewController {
            var state = 3
            switch self.DefaultShowType {
            case .STATS:
                state = 0
            case .COMMENTS:
                state = 1
            case .ANSWER:
                state = 2
            default:
                state = 3
            }
            
            var aq = 0
            if self.lessonExamStruct != nil {
                aq = self.lessonExamStruct!.answers.count
            }
            
            controller.configureController(entrance: self.entrance, starredCount: self.starred.count, segmentState: state, showType: self.showType, totalQuestions: self.lessonsDB[self.selectedLesson].qCount, answeredQuestions: aq, lessonTitle: self.lessonsDB[self.selectedLesson].fullTitle, lessonExamTime: self.lessonsDB[self.selectedLesson].duration)
            controller.showStarredQuestionButton.addTarget(self, action: #selector(self.showStarredQuestionPressed(_:)), forControlEvents: .TouchUpInside)
            controller.defaultShowSegment.addTarget(self, action: #selector(self.defaultShowSegmentValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
 
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.showType == "Starred" {
            if let path = self.tableView.indexPathsForVisibleRows?.first {
                let section = path.section
                self.topSection = section
                
            }
        }
    }
    
    @IBAction func backButtonPressed(sender: Object) {
        self.navigationController?.popViewControllerAnimated(true)
        self.loadStarredQuestion()
        self.loadStarredQuestionsRecord()
        
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EntranceShowInfoVCSegue" {
            if let controller = segue.destinationViewController as? EntranceShowInfoViewController {
                controller.popoverPresentationController?.delegate = self
                controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
                
                if self.showType == "LessonExam" || self.showType == "LessonExamResult" {
                    controller.preferredContentSize = CGSize(width: self.view.layer.bounds.width, height: 260)
                } else {
                    controller.preferredContentSize = CGSize(width: self.view.layer.bounds.width, height: 320)
                }
                
            }
        } else if segue.identifier == "EntranceLessonExamHistoryVCSegue" {
            if let controller = segue.destinationViewController as? EntranceLessonExamHistoryTableViewController {
                controller.entranceUniqueId = self.entranceUniqueId
                controller.lessonTitle = self.lessonsDB[self.selectedLesson].fullTitle
                controller.lessonOrder = self.lessonsDB[self.selectedLesson].order
                controller.lessonExamDuration = self.lessonsDB[self.selectedLesson].duration
                controller.lessonQuestionCount = self.lessonsDB[self.selectedLesson].qCount
                controller.entrance = self.entrance
                controller.bookletOrder = self.bookletsDb[self.selectedBooklet].order
                
//                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "بازگشت", style: .Plain, target: self, action: #selector(self.backButtonPressed(_:)))
                
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "بازگشت", style: .Plain, target: self, action: #selector(self.backButtonPressed(_:)))
            }
        }
    }
    
}
