//
//  EntranceLessonExamHistoryTableViewController.swift
//  Concough
//
//  Created by Owner on 2018-04-10.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import RealmSwift

class EntranceLessonExamHistoryTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    internal var entranceUniqueId: String!
    internal var entrance: EntranceStructure!
    internal var lessonTitle: String!
    internal var lessonOrder: Int!
    internal var lessonExamDuration: Int!
    internal var lessonQuestionCount: Int!
    internal var bookletOrder: Int!
    
    private var examsList: Results<EntranceLessonExamModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        let count = EntranceLessonExamModelHandler.getExamsCount(username: username, entranceUniqueId: self.entranceUniqueId, lessonTitle: self.lessonTitle, lessonOrder: self.lessonOrder, bookletOrder: self.bookletOrder)

        if count <= 0 {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self.examsList = EntranceLessonExamModelHandler.getAllExam(username: username, entranceUniqueId: self.entranceUniqueId, lessonTitle: self.lessonTitle, lessonOrder: self.lessonOrder, bookletOrder: self.bookletOrder, limit: nil)
        
        
        self.title = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(count)!) سنجش"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: .Plain, target: self, action: #selector(self.infoButtonPressed(_:)))
        
        
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions
    @IBAction func infoButtonPressed(sender: UIBarButtonItem) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("EntranceShowInfoVCSegue", sender: self)
        }
    }    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.examsList?.count)! + 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_LESSON_EXAM_HISTORY_CHART", forIndexPath: indexPath) as? EntranceLessonExamHistoryChartTableViewCell {
                cell.configureCell(entranceUniqueId: self.entranceUniqueId, lessonTitle: self.lessonTitle, lessonOrder: self.lessonOrder, bookletOrder: self.bookletOrder)
                return cell
            }
        } else if indexPath.row == 1 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_LESSON_EXAM_HISTORY_ITEMS_HEADER", forIndexPath: indexPath)
                return cell
            
        } else {
            if indexPath.row - 2 < self.examsList?.count {
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_LESSON_EXAM_HISTORY_ITEM", forIndexPath: indexPath) as? EntranceLessonExamHistoryItemTableViewCell {
                    
                    let item = self.examsList?[indexPath.row - 2]
                    cell.configureCell(percentage: item!.percentage, trueAnswer: item!.trueAnswer, falseAnswer: item!.falseAnswer, noAnswer: item!.noAnswer, examDate: item!.created, started: item!.startedDate, finished: item!.finishedDate)
                    
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 248.0
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row >= 2 {
            if let modalViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ENTRANCE_LESSON_LAST_EXAM_CHART") as? EntranceLessonLastExamChartViewController {
                
                modalViewController.entranceUniqueId = self.entranceUniqueId
                modalViewController.lessonTitle = self.lessonTitle
                modalViewController.lessonOrder = self.lessonOrder
                modalViewController.bookletOrder = self.bookletOrder
                modalViewController.whoCalled = "ExamHistory"
                modalViewController.examRecord = self.examsList[indexPath.row - 2]
                
                modalViewController.modalPresentationStyle = .Custom
                modalViewController.modalTransitionStyle = .CrossDissolve
                self.presentViewController(modalViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Navigation
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        if let controller = popoverPresentationController.presentedViewController as? EntranceShowInfoViewController {
            
            controller.configureController(entrance: self.entrance, starredCount: 0, segmentState: 0, showType: "LessonExamHistory", totalQuestions: self.lessonQuestionCount, answeredQuestions: 0, lessonTitle: self.lessonTitle, lessonExamTime: self.lessonExamDuration)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EntranceShowInfoVCSegue" {
            if let controller = segue.destinationViewController as? EntranceShowInfoViewController {
                controller.popoverPresentationController?.delegate = self
                controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
                
                controller.preferredContentSize = CGSize(width: self.view.layer.bounds.width, height: 230)
            }
        }
    }

}
