//
//  EntranceShowAllCommentViewController.swift
//  Concough
//
//  Created by Owner on 2018-04-06.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class EntranceShowAllCommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var commmnetTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    internal var questionId: String!
    internal var entranceUniqueId: String!
    internal var questionNo: Int!
    internal var questionIndexPath: NSIndexPath!
    
    internal var commentDelegate: EntranceShowCommentDelegate?
    
    private var comments: [EntranceQuestionCommentModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.headerLabel.text = "یادداشت های سوال \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.questionNo)!)"
        
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.layer.masksToBounds = true
//        self.containerView.layer.borderColor = self.questionNumberLabel.textColor.CGColor
//        self.containerView.layer.borderWidth = 2.0

        self.cancelButton.layer.cornerRadius = 5.0
        self.cancelButton.layer.masksToBounds = true
        
        self.commmnetTableView.delegate = self
        self.commmnetTableView.dataSource = self
        self.commmnetTableView.tableFooterView = UIView()
        self.commmnetTableView.estimatedRowHeight = 48.0
    
        self.importComments()
        self.commmnetTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func importComments() {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        self.comments = Array(EntranceQuestionCommentModelHandler.getAllComments(entranceUniqueId: self.entranceUniqueId, questionId: self.questionId, username: username))
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let comment = self.comments[indexPath.row]
        let commentType = EntranceCommentType.toType(comment.commentType)
        
        switch commentType {
        case .TEXT:
            if let cell = self.commmnetTableView.dequeueReusableCellWithIdentifier("QUESTION_TEXT_COMMENT", forIndexPath: indexPath) as? EntranceQuestionTextCommentTableViewCell {
                cell.configureCell(self.questionId, comment: comment)
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
            let commentId = self.comments[indexPath.row].uniqueId
            
            if EntranceQuestionCommentModelHandler.removeOneComment(username: username, commentId: commentId) {
                self.comments.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                if let delegate = self.commentDelegate {
                    delegate.deleteComment(questionId: self.questionId, questionNo: self.questionNo, commentId: commentId, indexPath: self.questionIndexPath)
                }
            }
        }
    }
    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "خذف") { (action, indexPath) in
//            
//        }
//        return [deleteAction]
//    }
    
    @IBAction func dismissMe(sender: UIButton) {
        if let delegate = self.commentDelegate {
            delegate.cancelComment()
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
