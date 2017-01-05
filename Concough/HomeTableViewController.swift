//
//  HomeTableViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-09.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DZNEmptyDataSet

class HomeTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var moreFeedExist = true
    var activityList = [ConcoughActivity]()
    var localImageStorage = Dictionary<String, Dictionary<Int, NSData>>()
    private var selectedActivityIndex: Int = -1
    
    let queue = NSOperationQueue()
    var oldOperation: NSBlockOperation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Initialization
        
        self.localImageStorage.updateValue(Dictionary<Int, NSData>(), forKey: "eset")
        self.queue.maxConcurrentOperationCount = 1  // make serial queue
        
        // tableView Initilization
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.tableFooterView = UIView()
        
        // uitableview refresh control setup
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید")
        }
        self.refreshControl?.addTarget(self, action: #selector(HomeTableViewController.refreshTableView(_:)), forControlEvents: .ValueChanged)
        
        loadFeeds(next: nil)
    }

    override func viewWillAppear(animated: Bool) {
        self.selectedActivityIndex = -1
    }
    
    func refreshTableView(refreshControl_: UIRefreshControl) {
        let operation = NSBlockOperation() {
            self.loadFeeds(next: nil)
        }
        
        queue.addOperation(operation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activityList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        NSLog("drawing tableview cell index: \(indexPath.row)")
        
        let activity = activityList[indexPath.row] as ConcoughActivity
        
        switch activity.activityType {
            case "ENTRANCE_CREATE":
                let target = activity.target

                if let cell = self.tableView.dequeueReusableCellWithIdentifier(activity.activityType, forIndexPath: indexPath) as? EntranceCreateTableViewCell {
                    
                    cell.cellConfigure(indexPath, target: target)
                    return cell
                }
            
            
            case "ENTRANCE_UPDATE":
                let target = activity.target

                if let cell = self.tableView.dequeueReusableCellWithIdentifier(activity.activityType, forIndexPath: indexPath) as? EntranceUpdateTableViewCell {
                    
                    cell.cellConfigure(indexPath, target: target)
                    return cell
                }
            
            default:
                break
        }

        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let activity = activityList[indexPath.row] as ConcoughActivity
        //guard let activity = activityList[indexPath.row] as ConcoughActivity else {
        //    return 0.0
        //}

        switch activity.activityType {
            case "ENTRANCE_CREATE": return 220.0
            case "ENTRANCE_UPDATE": return 115.0
        default: return 0.0
        }
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        print("HomeTableViewController --> willDisplayCell index: \(indexPath.row)")
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRowsInSection(lastSectionIndex) - 1
        
        if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
            // must load more
            if self.moreFeedExist == true {
                // get last item of activity feed
                let activity = self.activityList[lastRowIndex]
                let last_time = activity.createdStr
                //print("\(indexPath) - \(last_time)")
                
                //print("HomeTableViewController --> willDisplayCell cause loadFeeds")
                loadFeeds(next: last_time)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.activityList.count {
            
            let activity = self.activityList[indexPath.row]
            if activity.activityType == "ENTRANCE_CREATE" {
                
                self.selectedActivityIndex = indexPath.row
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("EntranceDetailVCSegue", sender: self)
                }                
            }
        }
    }

    // MARK: Private Functions
    
    private func loadFeeds(next next: String?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        DataRestAPIClass.updateActivity(next: next, completion: {
            refresh, data, error in
                        
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.refreshControl?.endRefreshing()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            if let err = error {
                switch err {
                case .Success:
                    /*
                    if refresh {
                        self.activityList.removeAll()
                        self.moreFeedExist = true
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                            self.tableView.reloadData()
                        }
                    } */

                    var localActivityList = [ConcoughActivity]()
                    
                    if let jsonData = data where jsonData.count > 0 {
                        
                        for (_, item) in jsonData {
                            let cStr = item["created"].stringValue
                            let aType = item["activity_type"].stringValue
                            let t = item["target"]
                            
                            let c:NSDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(cStr)!
                            
                            let con = ConcoughActivity(created: c, createdStr: cStr, activityType: aType, target: t)
                            localActivityList.append(con)
                        }
                        
                        if refresh {
                            self.activityList = localActivityList
                            self.moreFeedExist = true
                        } else {
                            self.activityList = self.activityList + localActivityList
                        }
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                            self.tableView.reloadData()
                        }
                        
                    } else { // no more feeds
                        self.moreFeedExist = false
                        
                    }
                default:
                    print("HomeTableViewController --> loadFeeds: error = \(err)")
                }
            }
        }, failure: { (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.refreshControl?.endRefreshing()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: { 
                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
                            self.loadFeeds(next: next)
                        })
                    })
                case .HostUnreachable:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.refreshControl?.endRefreshing()
                            })
                    })
                default:
                    break
                }
            }
        })
    }
    
    // MARK: - DZN
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "داده ای موجود نیست"
        let attributes = [NSFontAttributeName: UIFont(name: "IRANYekanMobile-Bold", size: 16)!,
                          NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "Timer")
        return image
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        let operation = NSBlockOperation { 
            self.loadFeeds(next: nil)
        }
        self.queue.addOperation(operation)
    }
    
    // MARK: - Navigations
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EntranceDetailVCSegue" {
            if let vc = segue.destinationViewController as? EntranceDetailTableViewController {
                // get entrance unique id
                let activity = self.activityList[self.selectedActivityIndex]
                let uniqueId = activity.target["unique_key"].stringValue
                vc.entranceUniqueId = uniqueId
            }
        }
    }
    
    // MARK: - Unwind Segue Handlers
    @IBAction func unwindArchiveViewController(segue: UIStoryboardSegue) {
        print("Unwind: ArchiveViewController")
    }
}
