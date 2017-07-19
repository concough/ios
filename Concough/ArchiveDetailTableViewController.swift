//
//  ArchiveDetailTableViewController.swift
//  Concough
//
//  Created by Owner on 2016-12-26.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON
import BBBadgeBarButtonItem
import MBProgressHUD
import DZNEmptyDataSet

class ArchiveDetailTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    internal var esetDetail: ArchiveEsetDetailStructure!
    
    private var loading: MBProgressHUD?
    private var rightBarButtonItem: BBBadgeBarButtonItem!
    private var entrances: [ArchiveEntranceStructure] = []
    private var queue: NSOperationQueue!
    private var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = self.esetDetail.entranceTypeTitle
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        // uitableview refresh control setup
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید")
        }
        self.refreshControl?.addTarget(self, action: #selector(self.refreshTableView(_:)), forControlEvents: .ValueChanged)

        // configure queue and add operation of loading entrances to it
        self.queue = NSOperationQueue()
        let operation = NSBlockOperation() {
            self.getEntrances()
        }
        queue.addOperation(operation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        self.setupBarButton()
    }
    
    // MARK: -Actions
    @IBAction func basketButtonPressed(sender: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("BasketCheckoutVCSegue", sender: self)
        }
    }
    
    // MARK: - Functions
    private func setupBarButton() {
        if BasketSingleton.sharedInstance.SalesCount > 0 {
            let b = UIButton(frame: CGRectMake(0, 0, 25, 25))
            b.setImage(UIImage(named: "Buy_Blue"), forState: .Normal)
            
            b.addTarget(self, action: #selector(self.basketButtonPressed(_:)), forControlEvents: .TouchUpInside)
            
            self.rightBarButtonItem = BBBadgeBarButtonItem(customUIButton: b)
            self.rightBarButtonItem.badgeValue = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(BasketSingleton.sharedInstance.SalesCount)!
            self.rightBarButtonItem.badgeBGColor = UIColor(netHex: RED_COLOR_HEX_2, alpha: 0.8)
            self.rightBarButtonItem.badgeTextColor = UIColor.whiteColor()
            self.rightBarButtonItem.badgeFont = UIFont(name: "IRANYekanMobile-Bold", size: 12)
            self.rightBarButtonItem.shouldHideBadgeAtZero = true
            self.rightBarButtonItem.shouldAnimateBadge = true
            self.rightBarButtonItem.badgeOriginX = 15.0
            self.rightBarButtonItem.badgeOriginY = -5.0
            
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        }
        
    }

    func refreshTableView(refreshControl_: UIRefreshControl) {
        // refresh control triggered
        let operation = NSBlockOperation() {
            self.getEntrances()
        }
        queue.addOperation(operation)
    }
    
    private func getEntrances() {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.loading = AlertClass.showLoadingMessage(viewController: self)
            self.refreshControl?.endRefreshing()
        }
        
        if let setId = self.esetDetail.entranceEset?.id {
            ArchiveRestAPIClass.getEntrances(entranceSetId: setId, completion: { (data, error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                }

                if error != HTTPErrorType.Success {
                    if error == HTTPErrorType.Refresh {
                        let operation = NSBlockOperation() {
                            self.getEntrances()
                        }
                        self.queue.addOperation(operation)
                    } else {
                        AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                    }
                } else {
                    if let localData = data {
                        if let status = localData["status"].string {
                            switch status {
                            case "OK":
                                // get record
                                let record = localData["record"]
                                
                                
                                var localArray: [ArchiveEntranceStructure] = []
                                for (_, item) in record {
                                    let organization_title = item["organization"]["title"].stringValue
                                    let entrance_year = item["year"].intValue
                                    let last_published_str = item["last_published"].stringValue
                                    let unique_id = item["unique_key"].stringValue
                                    let extra_data = JSON(data: item["extra_data"].stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
                                    
                                    let buy_count = item["stats"][0]["purchased"].intValue
                                    
                                    var entrance = ArchiveEntranceStructure()
                                    entrance.year = entrance_year
                                    entrance.organization = organization_title
                                    entrance.extraData = extra_data
                                    entrance.buyCount = buy_count
                                    entrance.lastPablished = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(last_published_str)
                                    entrance.uniqueId = unique_id
                                    
                                    localArray.append(entrance)
                                }
                                
                                self.entrances = localArray
                                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                    self.tableView.reloadData()
                                })
                                
                            case "Error":
                                if let errorType = localData["error_type"].string {
                                    switch errorType {
                                    case "EmptyArray":
                                        // must choise appropriate action
                                        self.entrances.removeAll()
                                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                            self.tableView.reloadData()
                                        })
                                        break
                                    default:
                                        break
//                                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                    }
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            }, failure:  { (error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                }
                
                if let err = error {
                    switch err {
                    case .NoInternetAccess:
                        fallthrough
                    case .HostUnreachable:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                        })
                        
//                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                            NSOperationQueue.mainQueue().addOperationWithBlock({
//                                self.getEntrances()
//                            })
//                        })
                    default:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                        })
                        
//                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                    }
                }
            })
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.entrances.count
        default:
            break
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return ""
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100.0
        case 1:
            return 80.0
        default:
            break
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("HEADER_SECTION", forIndexPath: indexPath) as? AEDHeaderTableViewCell {
                
                let setTitle: String = (self.esetDetail.entranceEset?.title)!
                let groupTitle: String = self.esetDetail.entranceGroupTitle!
                
                cell.configureCell(indexPath: indexPath, esetId: (self.esetDetail.entranceEset?.id)!, esetTitle: "\(setTitle) (\(groupTitle))", entranceCount: (self.esetDetail.entranceEset?.entranceCount)!, entranceSetCode: (self.esetDetail.entranceEset?.code)!)
                return cell
            }
        case 1:
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("ADVANCE_SECTION", forIndexPath: indexPath) as? AEDAdvanceTableViewCell {
                cell.configureCell(indexPath: indexPath, esetId: (self.esetDetail.entranceEset?.id)!, entrance: self.entrances[indexPath.row])
                return cell
            }
            /*
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("BASIC_SECTION", forIndexPath: indexPath) as? AEDBasicTableViewCell {
                
                let setTitle: String = (self.esetDetail.entranceEset?.title)!
                
                if indexPath.row == self.entrances.count - 1 {
                    cell.configureCell(indexPath: indexPath, esetTitle: setTitle,  entrance: self.entrances[indexPath.row], hiddenLine: true)
                } else {
                    cell.configureCell(indexPath: indexPath, esetTitle: setTitle, entrance: self.entrances[indexPath.row])
                }
                return cell
            }
             */
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 1:
            // perform segue
            self.selectedIndex = indexPath.row
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.performSegueWithIdentifier("EntranceDetailVCSegue", sender: self)
            })
            
        case 0:
            fallthrough
        default:
            break
        }
    }
    
    // MARK: - DZN
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "داده ای موجود نیست"
        let attributes = [NSFontAttributeName: UIFont(name: "IRANYekanMobile-Bold", size: 16)!,
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
    
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        let operation = NSBlockOperation {
            self.getEntrances()
        }
        self.queue.addOperation(operation)
    }
    
    
    // MARK: - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "EntranceDetailVCSegue" {
            if self.selectedIndex < 0 {
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EntranceDetailVCSegue" {
            if let vc = segue.destinationViewController as? EntranceDetailTableViewController {
                let entrance = self.entrances[self.selectedIndex]
                let uniqueId = entrance.uniqueId!
                
                vc.entranceUniqueId = uniqueId
                
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "آرشیو", style: .Plain, target: self, action: nil)
                
            }
        } else if segue.identifier == "BasketCheckoutVCSegue" {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "آرشیو", style: .Plain, target: self, action: nil)
            
        }
    }
}
