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

class ArchiveTableViewController: UITableViewController, EHHorizontalSelectionViewProtocol, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    //@IBOutlet weak var hSelView: EHHorizontalSelectionView!
    private var hSelView: EHHorizontalSelectionView!
    private var menuView: BTNavigationDropdownMenu?
    private var queue: NSOperationQueue!
    
    private var typeTitle: String?
    private var selectedTableIndex: Int = -1
    private var selectedEntranceTypeIndex: Int = -1
    private var selectedEntranceGroupIndex: Int = -1
    
    private var types: [String: Int]! = [:]
    private var typesString: [String]! = []
    private var groupsString: [String]! = []
    private var groups: [String: Int]! = [:]
    private var sets: [ArchiveEsetStructure]! = []
    
    private var groupsRepo: [Int: [String: Int]] = [:]
    private var setsRepo: [String: [ArchiveEsetStructure]] = [:]
    
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
        
        // create operation and call it
        let operation = NSBlockOperation(block: { 
            self.getEntranceTypes()
        })
        self.queue.addOperation(operation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.menuView?.cellTextLabelFont = UIFont(name: "IRANYekanMobile-Bold", size: 14)
            self.menuView?.navigationBarTitleFont = UIFont(name: "IRANYekanMobile-Bold", size: 17)
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

        self.hSelView?.registerCellWithClass(EHHorizontalLineViewCell)
        EHHorizontalLineViewCell.updateColorHeight(0.5)
        
        self.hSelView?.textColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        self.hSelView?.tintColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        
        //self.hSelView.backgroundColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        self.hSelView?.backgroundColor = UIColor(white: 0.0, alpha: 0.00)
        
        self.hSelView?.font = UIFont(name: "IRANYekanMobile-Bold", size: 14)
        self.hSelView?.fontMedium = UIFont(name: "IRANYekanMobile-Bold", size: 16)
        
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
    
    private func getEntranceTypes() {
        ArchiveRestAPIClass.getEntranceTypes({ (data, error) in
            if error != HTTPErrorType.Success {
                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
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
                                        break
                                    default:
                                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
            
        }) { (error) in
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: { 
                        let operation = NSBlockOperation(block: {
                            self.getEntranceTypes()
                        })
                        self.queue.addOperation(operation)
                    })
                case .HostUnreachable:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: { 
                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
                            self.performSegueWithIdentifier("HomeVCUnSegue", sender: self)
                        })
                    })
                default:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                }
            }
        }
    }
    
    private func getEntranceGroups(entranceTypeId etypeId: Int) {
        if self.groupsRepo.keys.contains(etypeId) == true {
            self.groups = self.groupsRepo[etypeId]
            self.groupsString = self.groups.keys.reverse()
            
            // update horizontal Menu
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.hSelView?.reloadData()
                
                if self.groups.count > 0 {
                    self.hSelView?.selectIndex(UInt(self.groupsString.count - 1))
                    // get first item sets from server
                    //self.getEntranceSets(entranceGroupId: self.groups[self.groupsString.last!]!)
                }
            })
            
            print("groups repo fetched: etype=\(etypeId)")
            return
        }
        
        ArchiveRestAPIClass.getEntranceGroups(entranceTypeId: etypeId, completion: { (data, error) in
            if error != HTTPErrorType.Success {
                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
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
                            self.groupsRepo.updateValue(localGroups, forKey: etypeId)
                            
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
                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }) { (error) in
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        let operation = NSBlockOperation(block: {
                            self.getEntranceGroups(entranceTypeId: etypeId)
                        })
                        self.queue.addOperation(operation)
                    })
                default:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                }
            }
        }
    }
    
    private func getEntranceSets(entranceGroupId groupId: Int) {
        if self.setsRepo.keys.contains("\(self.selectedEntranceTypeIndex):\(groupId)") {
            self.sets = self.setsRepo["\(self.selectedEntranceTypeIndex):\(groupId)"]
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
            })
            
            print("sets repo fetched: group=\(self.selectedEntranceTypeIndex):\(groupId)")
            
            return
        }
        
        ArchiveRestAPIClass.getEntranceSets(entranceGroupId: groupId, completion: { (data, error) in
            if error != HTTPErrorType.Success {
                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
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
                            self.setsRepo.updateValue(self.sets, forKey: "\(self.selectedEntranceTypeIndex):\(groupId)")
                            
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
                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }) { (error) in
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        let operation = NSBlockOperation(block: {
                            self.getEntranceSets(entranceGroupId: groupId)
                        })
                        self.queue.addOperation(operation)
                    })
                default:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
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
            let view = UIView(frame: CGRectMake(0.0, 0.0, self.tableView.layer.frame.width, 70.0))
            view.addSubview(self.hSelView)
            return view
        }
        return UIView()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 70.0
        }
        return 0.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56.0;
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
        let title = "مجموعه ای ثبت نشده است."
        let attributes = [NSFontAttributeName: UIFont(name: "IRANYekanMobile-Bold", size: 14)!,
                          NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
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
        }
    }
}
