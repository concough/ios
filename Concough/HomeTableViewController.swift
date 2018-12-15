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
import BBBadgeBarButtonItem
import MBProgressHUD

class HomeTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var moreFeedExist = true
    var activityList = [ConcoughActivity]()
    var localImageStorage = Dictionary<String, Dictionary<Int, NSData>>()
    private var selectedActivityIndex: Int = -1
    private var rightBarButtonItem: BBBadgeBarButtonItem!
    private var loading: MBProgressHUD?
    private var retryCounter = 0
    
    let queue = NSOperationQueue()
    var oldOperation: NSBlockOperation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialization
        self.localImageStorage.updateValue(Dictionary<Int, NSData>(), forKey: "eset")
        self.queue.maxConcurrentOperationCount = 1  // make serial queue
        
        // tableView Initilization
        self.tableView.estimatedRowHeight = 200.0
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.tableFooterView = UIView()
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        loadFeeds(next: nil)
    }

    override func viewWillAppear(animated: Bool) {
        self.selectedActivityIndex = -1
    }
    
    override func viewDidAppear(animated: Bool) {
//        self.setupBarButton()
        
        // uitableview refresh control setup
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید", attributes: [NSFontAttributeName: UIFont(name: "IRANSansMobile-UltraLight", size: 12)!])
        }
        self.refreshControl?.addTarget(self, action: #selector(HomeTableViewController.refreshTableView(_:)), forControlEvents: .ValueChanged)
    
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
//        if self.moreFeedExist {
//            return 2
//        }
        
        return 1

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.moreFeedExist {
            return self.activityList.count + 1
        }
        return self.activityList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == self.activityList.count {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("ACTIVITY_UPDATE", forIndexPath: indexPath) as? ActivityUpdateTableViewCell {
                cell.cellConfigure()
                return cell
            }
            
        } else {
            let activity = activityList[indexPath.row] as ConcoughActivity
            
            switch activity.activityType {
            case "ENTRANCE_CREATE":
                let target = activity.target
                
                if let cell = self.tableView.dequeueReusableCellWithIdentifier(activity.activityType, forIndexPath: indexPath) as? EntranceCreateTableViewCell {
                    
                    cell.tag = indexPath.row
                    cell.cellConfigure(indexPath, target: target)
                    cell.downloadEsetImage(activity.target["entrance_set"]["id"].intValue, indexPath: indexPath)
                
                
                    return cell
                }
                
                
            case "ENTRANCE_UPDATE":
                let target = activity.target
                
                if let cell = self.tableView.dequeueReusableCellWithIdentifier(activity.activityType, forIndexPath: indexPath) as? EntranceUpdateTableViewCell {
                    
                    cell.tag = indexPath.row
                    cell.cellConfigure(indexPath, target: target)
                    cell.downloadEsetImage(activity.target["entrance_set"]["id"].intValue, indexPath: indexPath)
                    
                    return cell
                }

            case "ENTRANCE_MULTI":
                let target = activity.target
                
                if let cell = self.tableView.dequeueReusableCellWithIdentifier(activity.activityType, forIndexPath: indexPath) as? EntranceMultiTableViewCell {
                    
                    cell.tag = indexPath.row
                    cell.cellConfigure(indexPath, target: target)
                    cell.downloadEsetImage(activity.target["entrances"][0]["entrance_set"]["id"].intValue, indexPath: indexPath)
                    
                    return cell
                }
                
            default:
                break
            }
        }

        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
//        let activity = activityList[indexPath.row] as ConcoughActivity
//        //guard let activity = activityList[indexPath.row] as ConcoughActivity else {
//        //    return 0.0
//        //}
//
//        switch activity.activityType {
//            case "ENTRANCE_CREATE": return 270.0
//            case "ENTRANCE_UPDATE": return 150.0
//        default: return 0.0
//        }
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row < activityList.count {
                let lastSectionIndex = 0
                let lastRowIndex = tableView.numberOfRowsInSection(lastSectionIndex) - 6
                
                //            let activity = activityList[indexPath.row] as ConcoughActivity
                
                //            switch activity.activityType {
                //            case "ENTRANCE_CREATE":
                //                if let cell1 = cell as? EntranceCreateTableViewCell {
                //                    cell1.downloadEsetImage(activity.target["entrance_set"]["id"].intValue, indexPath: indexPath)
                //                }
                //            case "ENTRANCE_UPDATE":
                //                if let cell1 = cell as? EntranceUpdateTableViewCell {
                //                    cell1.downloadEsetImage(activity.target["entrance_set"]["id"].intValue, indexPath: indexPath)
                //                }
                //            default:
                //                break
                //            }
                
                if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
                    // must load more
                    if self.moreFeedExist == true {
                        // get last item of activity feed
                        let activity = self.activityList[lastRowIndex + 4]
                        let last_time = activity.createdStr
                        
                        loadFeeds(next: last_time)
                    }
                }
            }            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.activityList.count {
            
            let activity = self.activityList[indexPath.row] as ConcoughActivity
            if activity.activityType == "ENTRANCE_CREATE" {
                
                self.selectedActivityIndex = indexPath.row
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("EntranceDetailVCSegue", sender: self)
                }                
            } else if activity.activityType == "ENTRANCE_MULTI" {
                self.selectedActivityIndex = indexPath.row
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("EntranceMultiDetailVCSegue", sender: self)
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func basketButtonPressed(sender: AnyObject) {
//        NSOperationQueue.mainQueue().addOperationWithBlock {
//            self.performSegueWithIdentifier("BasketCheckoutVCSegue", sender: self)
//        }
    }

    @IBAction func ArchiveButtonPressed(sender: UIBarButtonItem) {
        self.tabBarController?.selectedIndex = 1
    }
    
    // MARK: Private Functions
    private func setupBarButton() {
        if BasketSingleton.sharedInstance.SalesCount > 0 {
            let b = UIButton(frame: CGRectMake(0, 0, 25, 25))
            b.setImage(UIImage(named: "Buy_Blue"), forState: .Normal)
            
            b.addTarget(self, action: #selector(self.basketButtonPressed(_:)), forControlEvents: .TouchUpInside)
            
            self.rightBarButtonItem = BBBadgeBarButtonItem(customUIButton: b)
            self.rightBarButtonItem.badgeValue = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(BasketSingleton.sharedInstance.SalesCount)!
            self.rightBarButtonItem.badgeBGColor = UIColor(netHex: RED_COLOR_HEX_2, alpha: 0.8)
            self.rightBarButtonItem.badgeTextColor = UIColor.whiteColor()
            self.rightBarButtonItem.badgeFont = UIFont(name: "IRANSansMobile-Medium", size: 12)
            self.rightBarButtonItem.shouldHideBadgeAtZero = true
            self.rightBarButtonItem.shouldAnimateBadge = true
            self.rightBarButtonItem.badgeOriginX = 15.0
            self.rightBarButtonItem.badgeOriginY = -5.0
            self.rightBarButtonItem.badgePadding = 2.0
            
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        } else {
            self.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
        
    }
    
    private func loadFeeds(next next: String?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
//        if next == nil {
//            NSOperationQueue.mainQueue().addOperationWithBlock {
//                self.loading = AlertClass.showLoadingMessage(viewController: self)
//            }            
//        }
        
        if next == nil {
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.navigationItem.title = "به روز رسانی ..."
            })
            
        }
        
        DataRestAPIClass.updateActivity(next: next, completion: {
            refresh, data, error in
            
            if let err = error {
                switch err {
                case .Success:
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.navigationItem.title = "کنکوق"
                        self.refreshControl?.endRefreshing()
                        AlertClass.hideLoaingMessage(progressHUD: self.loading)
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                    self.retryCounter = 0
                    var localActivityList = [ConcoughActivity]()
                    
                    if let jsonData = data where jsonData.count > 0 {
                        
                        for (_, item) in jsonData {
                            let cStr = item["created"].stringValue
                            let aType = item["activity_type"].stringValue
                            let t = item["target"]
                            let c:NSDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(cStr)!
                            
                            if SUPPORT_ACTIVITY_TYPES.contains(aType) {
                                let con = ConcoughActivity(created: c, createdStr: cStr, activityType: aType, target: t)
                                localActivityList.append(con)
                            }
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
                        self.tableView.reloadData()
                        
                    }
                case .Refresh:
                    let operation = NSBlockOperation() {
                        self.loadFeeds(next: next)
                    }
                    self.queue.addOperation(operation)
                    
                default:
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        self.loadFeeds(next: next)
                    } else {
                        self.retryCounter = 0
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.navigationItem.title = "کنکوق"
                            AlertClass.hideLoaingMessage(progressHUD: self.loading)
                            self.refreshControl?.endRefreshing()
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        }
                    }
                    break
                }
            }
        }, failure: { (error) in
            if let err = error {
                if self.retryCounter < CONNECTION_MAX_RETRY {
                    self.retryCounter += 1
                    self.loadFeeds(next: next)
                } else {
                    self.retryCounter = 0
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.navigationItem.title = "کنکوق"
                        AlertClass.hideLoaingMessage(progressHUD: self.loading)
                        self.refreshControl?.endRefreshing()
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                    
                    switch err {
                    case .NoInternetAccess:
                        fallthrough
                    case .HostUnreachable:
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
    //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
    //                    })
                    default:
                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                        })
                        break
                    }
                }
            }
        })
    }
    
    // MARK: - DZN
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "داده ای موجود نیست"
        let attributes = [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 16)!,
                          NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "Refresh")
        return image
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
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
        } else if segue.identifier == "EntranceMultiDetailVCSegue" {
            if let vc = segue.destinationViewController as? EntranceMultiDetailTableViewController {
                // get entrance unique id
                let activity = self.activityList[self.selectedActivityIndex]
                let uniqueId = activity.target["unique_key"].stringValue
                vc.uniqueId = uniqueId
                vc.target = activity.target
                vc.actType = activity.activityType
            }
        }
    }
    
    // MARK: - Unwind Segue Handlers
    @IBAction func unwindArchiveViewController(segue: UIStoryboardSegue) {
    }

}
