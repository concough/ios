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

class EntranceShowTableViewController: UITableViewController, EHHorizontalSelectionViewProtocol, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {

    internal var entranceUniqueId: String!
    internal var entrance: EntranceStructure!
    internal var showType: String = "Show"
    
    private var entranceDb: EntranceModel!
    private var bookletsDb: List<EntranceBookletModel>!
    private var lessonsDB: List<EntranceLessonModel>!
    private var questionsDB: List<EntranceQuestionModel>!
    
    private var hSelView: EHHorizontalSelectionView!
    private var menuView: BTNavigationDropdownMenu?
    
    private var bookletsString: [String] = []
    private var booklet: String?
    private var selectedBooklet: Int = -1

    private var lessonsString: [String] = []
    private var selectedLesson: Int = -1
    
    private var imagesRepo: [String: NSData] = [:]
    private var showedAnswer: [String] = []
    private var starred: [String] = []
    private var starredQuestions: [(lessonId: String, lessonTitle: String, count: Int, questions: [EntranceQuestionModel])] = []
    
    private var ShowAllAnswer: Bool = false
    private var topSection: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tabBarController?.tabBar.hidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: .Plain, target: self, action: #selector(self.infoButtonPressed(_:)))
        
        self.initializeHorizontalView()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .None
        
        self.loadEntranceDB()
        self.loadStarredQuestion()
        self.loadBooklets()
        self.loadStarredQuestionsRecord()
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
 
        // Add Entrance Opened record
        EntranceOpenedCountModelHandler.update(entranceUniqueId: self.entranceUniqueId, type: self.showType)

        if self.showType == "Starred" {
            // load starredQuestions
            self.title = "سوالات نشان شده (" + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.starred.count)! + ")"
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // BTNavigationDropdownMenu
    private func configureMenu() {
        if self.bookletsString.count > 0 {
            self.menuView = BTNavigationDropdownMenu(title: self.bookletsString[0], items: self.bookletsString)
            self.menuView?.didSelectItemAtIndexHandler = self.menuItemSelected
            
            // View Customizations
            self.menuView?.cellSeparatorColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.3)
            self.menuView?.cellTextLabelFont = UIFont(name: "IRANYekanMobile-Bold", size: 12)
            self.menuView?.navigationBarTitleFont = UIFont(name: "IRANYekanMobile-Bold", size: 13)
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

        //self.hSelView.backgroundColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        self.hSelView?.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        
        self.hSelView?.registerCellWithClass(EHHorizontalLineViewCell)
        EHHorizontalLineViewCell.updateColorHeight(0.8)
        
        self.hSelView?.textColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        self.hSelView?.tintColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        //self.hSelView?.textColor = UIColor(white: 0.0, alpha: 0.7)
        //self.hSelView?.tintColor = self.hSelView?.textColor
        
        
        self.hSelView?.font = UIFont(name: "IRANYekanMobile-Bold", size: 12)
        self.hSelView?.fontMedium = UIFont(name: "IRANYekanMobile-Bold", size: 14)
        
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
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            if self.showType == "Show" {
                self.tableView.reloadData()
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
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
        self.ShowAllAnswer = !self.ShowAllAnswer
        
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
        } else if self.showType == "Starred" {
            self.navigationItem.titleView = self.menuView
            self.showType = "Show"
        }

        // Add Entrance Opened record
        EntranceOpenedCountModelHandler.update(entranceUniqueId: self.entranceUniqueId, type: self.showType)

        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Functions
    private func loadEntranceDB() {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        if let item = EntranceModelHandler.getByUsernameAndId(id: self.entranceUniqueId, username: username) {
            self.entranceDb = item
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func loadStarredQuestion() {
        let items = EntranceQuestionStarredModelHandler.getStarredQuestions(entranceUniqueId: self.entranceUniqueId)
        self.starred.removeAll()
        
        if items.count > 0 {
            for item in items {
                self.starred.append(item.question!.uniqueId)
            }
        }
    }
    
    private func loadStarredQuestionsRecord() {
        let items = EntranceQuestionModelHandler.getStarredQuestions(entranceId: self.entranceUniqueId, questions: self.starred)
        
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
            self.configureMenu()
            self.selectedBooklet = 0
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
                    self.hSelView?.selectIndex(UInt(self.lessonsString.count - 1))
                }
            })
            
        }
    }
    
    private func loadQuestions() {
        if self.selectedLesson >= 0 {
            self.questionsDB = List(self.lessonsDB[self.selectedLesson].questions.sorted("number", ascending: true))
        }
    }
    
    internal func addAnsweredQuestionId(questionId questionId: String) {
        if self.showedAnswer.contains(questionId) == false {
            self.showedAnswer.append(questionId)
        }
    }

    internal func addStarQuestionId(questionId questionId: String, state: Bool) -> Bool {
        var flag = false
        if state == true {
            if self.starred.contains(questionId) == false {
                if EntranceQuestionStarredModelHandler.add(entranceUniqueId: self.entranceUniqueId, questionId: questionId) == true {
                    self.starred.append(questionId)
                    flag = true
                }
            }
        } else {
            if self.starred.contains(questionId) == true {
                if EntranceQuestionStarredModelHandler.remove(entranceUniqueId: self.entranceUniqueId, questionId: questionId) == true {
                    let index = self.starred.indexOf(questionId)!
                    self.starred.removeAtIndex(index)
                    flag = true
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
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.showType == "Show" {
            return 1
        } else if self.showType == "Starred" {
            return self.starredQuestions.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showType == "Show" {
            if self.selectedLesson >= 0 && section == 0 {
                return self.questionsDB.count
            }
        } else if self.showType == "Starred" {
            return self.starredQuestions[section].questions.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_QUESTION", forIndexPath: indexPath) as? EntranceShowQuestionTableViewCell {
            
            var question: EntranceQuestionModel? = nil
            if self.showType == "Show" {
                question = self.questionsDB[indexPath.row]
            } else if self.showType == "Starred" {
                question = self.starredQuestions[indexPath.section].questions[indexPath.row]
            }
            
            let images = JSON(data: question!.images.dataUsingEncoding(NSUTF8StringEncoding)!).arrayValue.sort {
                $0["order"].intValue < $1["order"].intValue
            }
            
            var imagesData = [NSData]()
            for image in images {
                let imageId = image["unique_key"].stringValue
                if self.imagesRepo.keys.contains(imageId) == true {
                    imagesData.append(self.imagesRepo[imageId]!)
                } else {
                    // open it from file
                    let filemgr = NSFileManager.defaultManager()
                    let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                    
                    let docsDir = dirPaths[0] as NSString
                    let filePath = (docsDir.stringByAppendingPathComponent(self.entranceUniqueId) as NSString).stringByAppendingPathComponent(imageId)
                    if filemgr.fileExistsAtPath(filePath) {
                        if let data = filemgr.contentsAtPath(filePath) {
                            self.imagesRepo[imageId] = data
                            imagesData.append(data)
                        }
                    }
                    
                }
            }

            var showAnswer = false
            if self.showedAnswer.contains(question!.uniqueId) {
                showAnswer = true
            }
            if self.ShowAllAnswer == true {
                showAnswer = true
            }
            
            var starredFlag = false
            if self.starred.contains(question!.uniqueId) {
                starredFlag = true
            }

            cell.configureCell(viewController: self, vcType: "E", question: question!.number, questionId: question!.uniqueId, answer: question!.answer, starred: starredFlag, images: imagesData, showAnswer: showAnswer)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        }
        return UIView()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.showType == "Show" {
            if section == 0 {
                return 45.0
            }
        } else if self.showType == "Starred" {
            return 40.0
        }
        return 0.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 112.0
    }
    
    // MARK: - Delegates
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if viewController is FavoritesTableViewController {
            viewController.tabBarController?.tabBar.hidden = false
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        if let controller = popoverPresentationController.presentedViewController as? EntranceShowInfoViewController {
            controller.configureController(entrance: self.entrance, starredCount: self.starred.count, switchState: self.ShowAllAnswer, showType: self.showType)
            controller.showStarredQuestionButton.addTarget(self, action: #selector(self.showStarredQuestionPressed(_:)), forControlEvents: .TouchUpInside)
            controller.showAnswerSwitch.addTarget(self, action: #selector(self.showAllAnswerValueChanged(_:)), forControlEvents: .ValueChanged)
            
        }
    }

    /*
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.showType == "Starred" {
            if let path = self.tableView.indexPathsForVisibleRows?.first {
                let section = path.section
                self.topSection = section
                
                if let v = self.tableView.headerViewForSection(section) {
                    v.contentView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
                    v.setNeedsLayout()
                }
            }
        }
    }
    */
 
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.showType == "Starred" {
            if let path = self.tableView.indexPathsForVisibleRows?.first {
                let section = path.section
                self.topSection = section
                
                /*
                if let v = self.tableView.headerViewForSection(section) {
                    v.contentView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)

                    let view2 = UIView(frame: CGRectMake(0.0, v.contentView.layer.bounds.height - 1, v.contentView.layer.bounds.width, 1.0))
                    view2.backgroundColor = UIColor(netHex: 0xEEEEEE, alpha: 1.0)
                    
                    
                    v.addSubview(view2)
                    v.setNeedsLayout()
                }
 */
            }
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EntranceShowInfoVCSegue" {
            if let controller = segue.destinationViewController as? EntranceShowInfoViewController {
                controller.popoverPresentationController?.delegate = self
                controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
                controller.preferredContentSize = CGSize(width: self.view.layer.bounds.width, height: 180)
                
            }
        }
    }
    
}
