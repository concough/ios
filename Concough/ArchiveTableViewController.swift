//
//  ArchiveTableViewController.swift
//  Concough
//
//  Created by Owner on 2016-12-21.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON
import BTNavigationDropdownMenu
//import CarbonKit
import EHHorizontalSelectionView
import DZNEmptyDataSet
import BBBadgeBarButtonItem
import MBProgressHUD

class ArchiveTableViewController: UITableViewController, EHHorizontalSelectionViewProtocol, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    //@IBOutlet weak var hSelView: EHHorizontalSelectionView!
    private var hSelView: EHHorizontalSelectionView!
    private var menuView: BTNavigationDropdownMenu?
    private var queue: NSOperationQueue!
    private var rightBarButtonItem: BBBadgeBarButtonItem!
    private var loading: MBProgressHUD?
    private var isRotating = false
   
    private var typeTitle: String?
    private var selectedTableIndex: Int = -1
    private var selectedEntranceTypeIndex: Int = -1
    private var selectedEntranceGroupIndex: Int = -1
    
    private var types: [String: Int]! = [:]
    private var typesString: [String]! = []
    private var groupsString: [String]! = []
    private var groups: [String: Int]! = [:]
    private var sets: [ArchiveEsetStructure]! = []
    
    //private var groupsRepo: [Int: [String: Int]] = [:]
    //private var setsRepo: [String: [ArchiveEsetStructure]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Initialization
        self.queue = NSOperationQueue()
        self.queue.maxConcurrentOperationCount = 1
        
        self.tableView.tableFooterView = UIView()
        self.initializeHorizontalView()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید", attributes: [NSFontAttributeName: UIFont(name: "IRANSansMobile-UltraLight", size: 12)!])
        }
        self.refreshControl?.addTarget(self, action: #selector(self.refreshTableView(_:)), forControlEvents: .ValueChanged)

        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl!)
        }
        self.refreshControl?.endRefreshing()
        
        // create operation and call it
        let operation = NSBlockOperation(block: {
            self.getEntranceTypes()
        })
        self.queue.addOperation(operation)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setupBarButton()
        
        let b = UIButton(frame: CGRectMake(0, 0, 25, 25))
        b.setImage(UIImage(named: "Recurring"), forState: .Normal)
        
        b.addTarget(self, action: #selector(self.refreshButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: b)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTableView(refreshControl_: UIRefreshControl) {
        if self.types.count > 0 {
            if self.groups.count > 0 {
                self.getEntranceSets(entranceGroupId: self.selectedEntranceGroupIndex)
            } else {
                self.getEntranceGroups(entranceTypeId: self.selectedEntranceTypeIndex)
            }
        } else {
            self.getEntranceTypes()
        }
    }
    
    
    // MARK: - Functions
    
    // BTNavigationDropdownMenu
    private func configureMenu() {
        if self.typesString.count > 0 {
            self.menuView = BTNavigationDropdownMenu(title: self.typesString[0], items: self.typesString)
            self.navigationItem.titleView = self.menuView
            self.menuView?.didSelectItemAtIndexHandler = self.menuItemSelected
            
            // View Customizations
            self.menuView?.cellSeparatorColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.3)
            self.menuView?.cellTextLabelFont = UIFont(name: "IRANSansMobile", size: 14)
            self.menuView?.navigationBarTitleFont = UIFont(name: "IRANSansMobile-Medium", size: 16)
            self.menuView?.cellTextLabelAlignment = NSTextAlignment.Center
            self.menuView?.arrowTintColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
            self.menuView?.arrowTintColor = UIColor.blackColor()
        }
        
    }
    
    private func menuItemSelected(indexPath indexPath: Int) {
        self.typeTitle = self.typesString[indexPath]
        self.selectedEntranceTypeIndex = self.types[self.typesString[indexPath]]!

        let operation = NSBlockOperation(block: {
            self.getEntranceGroups(entranceTypeId: self.types[self.typesString[indexPath]]!)
        })
        self.queue.addOperation(operation)
    }
    
    // EHHorizontalSelectionView methods
    private func initializeHorizontalView() {
        self.hSelView = EHHorizontalSelectionView(frame: CGRectMake(0.0, 0.0, self.tableView.layer.frame.width, 45.0))
        self.hSelView?.delegate = self

        let bottonView = UIView(frame:  CGRectMake(0.0, 45.0, self.tableView.layer.frame.width, 1.0))
        bottonView.backgroundColor = UIColor(netHex: 0xDDDDDD, alpha: 1.0)
        self.hSelView?.addSubview(bottonView)
        
        //self.hSelView.backgroundColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        self.hSelView?.backgroundColor = UIColor(white: 0.98, alpha: 0.95)
        
        self.hSelView?.registerCellWithClass(EHHorizontalLineViewCell)
        EHHorizontalLineViewCell.updateColorHeight(0.5)
        
        self.hSelView?.textColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        self.hSelView?.tintColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        
        self.hSelView?.font = UIFont(name: "IRANSansMobile", size: 14)!
        self.hSelView?.fontMedium = UIFont(name: "IRANSansMobile-Medium", size: 14)!
        
        self.hSelView?.semanticContentAttribute = UISemanticContentAttribute.ForceRightToLeft
        self.hSelView?.cellGap = 25.0
    }
    
    func numberOfItemsInHorizontalSelection(hSelView: EHHorizontalSelectionView) -> UInt {
        return UInt(self.groupsString.count)
    }
    
    func titleForItemAtIndex(index: UInt, forHorisontalSelection hSelView: EHHorizontalSelectionView) -> String? {
        return self.groupsString[Int(index)]
    }
    
    func horizontalSelection(hSelView: EHHorizontalSelectionView, didSelectObjectAtIndex index: UInt) {
        self.selectedEntranceGroupIndex = self.groups[self.groupsString[Int(index)]]!
        
        let operation = NSBlockOperation(block: {
            self.getEntranceSets(entranceGroupId: self.groups[self.groupsString[Int(index)]]!)
        })
        self.queue.addOperation(operation)
    }
    
    // MARK: -Actions
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        print(isRotating)
        if !isRotating {
            let layer = (self.navigationItem.leftBarButtonItem!.customView as? UIButton)?.imageView?.layer
            
            // create a spin animation
            let spinAnimation = CABasicAnimation()
            // starts from 0
            spinAnimation.fromValue = 0
            // goes to 360 ( 2 * π )
            spinAnimation.toValue = M_PI*2
            // define how long it will take to complete a 360
            spinAnimation.duration = 0.8
            // make it spin infinitely
            spinAnimation.repeatCount = 5
            // do not remove when completed
            spinAnimation.removedOnCompletion = false
            // specify the fill mode
            spinAnimation.fillMode = kCAFillModeForwards
            // and the animation acceleration
            spinAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            // add the animation to the button layer
            layer?.addAnimation(spinAnimation, forKey: "transform.rotation.z")
            
            self.isRotating = true
            
            self.selectedEntranceTypeIndex = -1
            self.selectedEntranceGroupIndex = -1
            self.selectedTableIndex = -1
            
            self.menuView?.hide()
            
            self.types.removeAll()
            self.typesString.removeAll()
            self.groups.removeAll()
            self.groupsString.removeAll()
            self.sets.removeAll()
            //self.setsRepo.removeAll()
            
            let operation = NSBlockOperation(block: {
                self.getEntranceTypes()
            })
            self.queue.addOperation(operation)

        }
    }
    
    private func removeRefreshAnimation() {
        // remove the animation
        let layer = (self.navigationItem.leftBarButtonItem!.customView as? UIButton)?.imageView?.layer
        layer?.removeAllAnimations()
        self.isRotating = false
        
    }
    
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
            self.rightBarButtonItem.badgePadding = 2.0
            self.rightBarButtonItem.badgeBGColor = UIColor(netHex: RED_COLOR_HEX_2, alpha: 0.8)
            self.rightBarButtonItem.badgeTextColor = UIColor.whiteColor()
            self.rightBarButtonItem.badgeFont = UIFont(name: "IRANSansMobile-Medium", size: 11)
            self.rightBarButtonItem.shouldHideBadgeAtZero = true
            self.rightBarButtonItem.shouldAnimateBadge = true
            self.rightBarButtonItem.badgeOriginX = 15.0
            self.rightBarButtonItem.badgeOriginY = -5.0
            
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        } else {
            self.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
        
    }
    
    private func getEntranceTypes() {
//        NSOperationQueue.mainQueue().addOperationWithBlock { 
//            self.loading = AlertClass.showLoadingMessage(viewController: self)
//        }
        
        ArchiveRestAPIClass.getEntranceTypes({ (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                        self.refreshControl?.endRefreshing()
//                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            self.removeRefreshAnimation()
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.getEntranceTypes()
                    })
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
                            for (_, item) in record {
                                let itemTitle = item["title"].stringValue
                                let itemId = item["id"].intValue
                                
                                self.types.updateValue(itemId, forKey: itemTitle)
                                self.typesString.append(itemTitle)
                            }
                            
                            self.configureMenu()
                            if self.types.count > 0 {
                                self.typeTitle = self.typesString[0]
                                self.selectedEntranceTypeIndex = self.types[self.typesString[0]]!
                                
                                let operation = NSBlockOperation(block: { 
                                    self.getEntranceGroups(entranceTypeId: self.types[self.typesString[0]]!)
                                })
                                self.queue.addOperation(operation)
                            }
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                    case "EmptyArray":
                                        // must choise appropriate action
                                        AlertClass.showTopMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, type: "", completion: nil)
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
            
        }) { (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
            self.refreshControl?.endRefreshing()
//                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            self.removeRefreshAnimation()

            if let err = error {
                switch err {
                case .NoInternetAccess:
                    fallthrough
                case .HostUnreachable:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    })
                    
//                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: { 
//                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
//                            self.performSegueWithIdentifier("HomeVCUnSegue", sender: self)
//                        })
//                    })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
//                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                }
            }
        }
    }
    
    private func getEntranceGroups(entranceTypeId etypeId: Int) {
//        NSOperationQueue.mainQueue().addOperationWithBlock {
//            self.refreshControl?.endRefreshing()
//        }
        
//        if self.groupsRepo.keys.contains(etypeId) == true {
//            self.groups = self.groupsRepo[etypeId]
//            self.groupsString = self.groups.keys.reverse()
//            
//            // update horizontal Menu
//            NSOperationQueue.mainQueue().addOperationWithBlock({
//                self.hSelView?.reloadData()
//                
//                if self.groups.count > 0 {
//                    self.hSelView?.selectIndex(UInt(self.groupsString.count - 1))
//                    // get first item sets from server
//                    //self.getEntranceSets(entranceGroupId: self.groups[self.groupsString.last!]!)
//                }
//            })
//            
//            print("groups repo fetched: etype=\(etypeId)")
//            return
//        }
        
//        NSOperationQueue.mainQueue().addOperationWithBlock { 
//            self.loading = AlertClass.showLoadingMessage(viewController: self)
//        }
        
        ArchiveRestAPIClass.getEntranceGroups(entranceTypeId: etypeId, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.refreshControl?.endRefreshing()
                //                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            self.removeRefreshAnimation()
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.getEntranceGroups(entranceTypeId: etypeId)
                    })
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
                            
                            var localGroups: [String: Int] = [:]
                            var localGroupsString: [String] = []
                            for (_, item) in record {
                                let groupTitle = item["title"].stringValue
                                let groupId = item["id"].intValue
                                
                                localGroups[groupTitle] = groupId
                                localGroupsString.append(groupTitle)
                            }

                            self.groups = localGroups
                            self.groupsString = localGroupsString.reverse()
                            
                            // make repo
                            // self.groupsRepo.updateValue(localGroups, forKey: etypeId)
                            
                            // update horizontal Menu
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.hSelView?.reloadData()

                                if self.groups.count > 0 {
                                    self.hSelView?.selectIndex(UInt(self.groupsString.count - 1))
                                }
                            })
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    // must choise appropriate action
                                    self.groups.removeAll()
                                    self.groupsString.removeAll()
                                    self.sets.removeAll()
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        self.hSelView?.reloadData()
                                        self.tableView.reloadData()
                                    })
                                    
                                    break
                                default:
                                    break
//                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }) { (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.refreshControl?.endRefreshing()
                //                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            self.removeRefreshAnimation()

            if let err = error {
                switch err {
                case .NoInternetAccess:
                    fallthrough
                case .HostUnreachable:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    })
                    
//                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                        let operation = NSBlockOperation(block: {
//                            self.getEntranceGroups(entranceTypeId: etypeId)
//                        })
//                        self.queue.addOperation(operation)
//                    })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
                    
//                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                }
            }
        }
    }
    
    private func getEntranceSets(entranceGroupId groupId: Int) {
//        NSOperationQueue.mainQueue().addOperationWithBlock {
//            self.refreshControl?.endRefreshing()
//        }

//        if self.setsRepo.keys.contains("\(self.selectedEntranceTypeIndex):\(groupId)") {
//            self.sets = self.setsRepo["\(self.selectedEntranceTypeIndex):\(groupId)"]
//            
//            NSOperationQueue.mainQueue().addOperationWithBlock({
//                self.tableView.reloadData()
//            })
//            
//            print("sets repo fetched: group=\(self.selectedEntranceTypeIndex):\(groupId)")
//            return
//        }

        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        ArchiveRestAPIClass.getEntranceSets(entranceGroupId: groupId, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
                self.refreshControl?.endRefreshing()
            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.getEntranceSets(entranceGroupId: groupId)
                    })
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
                            
                            var localSets = [ArchiveEsetStructure]()
                            for (_, item) in record {
                                let esetId = item["id"].intValue
                                let esetTitle = item["title"].stringValue
                                let entranceCount = item["entrance_count"].intValue
                                let entranceCode = item["code"].intValue
                                
                                let updatedStr = item["updated"].stringValue
                                let updated = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(updatedStr)
                                
                                var archiveSet = ArchiveEsetStructure()
                                archiveSet.id = esetId
                                archiveSet.title = esetTitle
                                archiveSet.code = entranceCode
                                archiveSet.entranceCount = entranceCount
                                archiveSet.updated = updated
                                
                                localSets.append(archiveSet)
                            }
                            self.sets = localSets
//                            self.setsRepo.updateValue(self.sets, forKey: "\(self.selectedEntranceTypeIndex):\(groupId)")
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                self.tableView.reloadData()
                            })
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    // must choise appropriate action
                                    self.sets.removeAll()
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        self.tableView.reloadData()
                                    })
                                default:
                                    break
//                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }) { (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
                self.refreshControl?.endRefreshing()

            })
            
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    fallthrough
                case .HostUnreachable:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    })
//                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                        let operation = NSBlockOperation(block: {
//                            self.getEntranceSets(entranceGroupId: groupId)
//                        })
//                        self.queue.addOperation(operation)
//                    })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
//                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                }
            }
        }
        
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView(frame: CGRectMake(0.0, 0.0, self.tableView.layer.frame.width, 45.0))
            view.addSubview(self.hSelView)
            return view
        }
        return UIView()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 45.0
        }
        return 0.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ARCHIVE_ADVANCE", forIndexPath: indexPath) as? ArchiveAdvanceTableViewCell {
            cell.configureCell(indexPath: indexPath, set: self.sets[indexPath.row])
            return cell
        }
        else if let cell = tableView.dequeueReusableCellWithIdentifier("ARCHIVE_BASIC", forIndexPath: indexPath) as? ArchiveBasicTableViewCell {
            cell.configureCell(indexPath: indexPath, set: self.sets[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.sets.count {
            
            self.selectedTableIndex = indexPath.row
            if self.sets[indexPath.row].entranceCount > 0 {
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    self.performSegueWithIdentifier("ArchiveDetailVCSegue", sender: self)
                    
                })
            }
        }
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
            if self.types.count > 0 {
                if self.groups.count > 0 {
                    self.getEntranceSets(entranceGroupId: self.selectedEntranceGroupIndex)
                } else {
                    self.getEntranceGroups(entranceTypeId: self.selectedEntranceTypeIndex)
                }
            } else {
                self.getEntranceTypes()
            }            
        }
        self.queue.addOperation(operation)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ArchiveDetailVCSegue" {
            if self.selectedTableIndex > -1 {
                if let vc = segue.destinationViewController as? ArchiveDetailTableViewController {
                    var esetDetail = ArchiveEsetDetailStructure()
                    esetDetail.entranceEset = self.sets[self.selectedTableIndex]
                    esetDetail.entranceGroupTitle = self.groupsString[Int(self.hSelView.selectedIndex())]
                    esetDetail.entranceTypeTitle = self.typeTitle
                    
                    print(esetDetail)
                    vc.esetDetail = esetDetail
                    
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "بازگشت", style: .Plain, target: self, action: nil)
                }
            }
        } else if segue.identifier == "BasketCheckoutVCSegue" {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "محصولات", style: .Plain, target: self, action: nil)
            
        }
    }
}
