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

class ArchiveDetailTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIPopoverPresentationControllerDelegate, ProductBuyDelegate {

    internal var esetDetail: ArchiveEsetDetailStructure!
    
    private var loading: MBProgressHUD?
    private var rightBarButtonItem: BBBadgeBarButtonItem!
    private var entrances: [ArchiveEntranceStructure] = []
    private var entranceSaleData: [(entranceType: Int, entranceYear: Int, entranceMonth: Int, cost: Int, costBon: Int)] = []
    private var queue: NSOperationQueue!
    private var selectedIndex = -1
    private var username: String!
    private var retryCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = self.esetDetail.entranceTypeTitle
        self.username = UserDefaultsSingleton.sharedInstance.getUsername()!
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self

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
//        self.setupBarButton()
        // uitableview refresh control setup
        
        if (self.entrances.count > 0) {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.tableView.reloadData()
            }            
        }
    }
    
    // MARK: -Actions
    @IBAction func basketButtonPressed(sender: AnyObject) {
//        NSOperationQueue.mainQueue().addOperationWithBlock {
//            self.performSegueWithIdentifier("BasketCheckoutVCSegue", sender: self)
//        }
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
            self.rightBarButtonItem.badgeFont = UIFont(name: "IRANSansMobile-Medium", size: 12)
//            self.rightBarButtonItem.shouldHideBadgeAtZero = true
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

    func refreshTableView(refreshControl_: UIRefreshControl) {
        // refresh control triggered
        let operation = NSBlockOperation() {
            self.getEntrances()
        }
        queue.addOperation(operation)
    }
    
    private func updateBasketBadge(count count: Int) {
        if self.rightBarButtonItem == nil {
            self.setupBarButton()
        }
        
        if self.rightBarButtonItem != nil {
            self.rightBarButtonItem.badgeValue = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(count)
        }
    }
    
    
    private func getEntrances() {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        if let setId = self.esetDetail.entranceEset?.id {
            ArchiveRestAPIClass.getEntrances(entranceSetId: setId, completion: { (data, error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.refreshControl?.endRefreshing()
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
                        if self.retryCounter < CONNECTION_MAX_RETRY {
                            self.retryCounter += 1
                            let operation = NSBlockOperation() {
                                self.getEntrances()
                            }
                            self.queue.addOperation(operation)
                        } else {
                            self.retryCounter = 0
                            AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                            
                        }
                    }
                } else {
                    self.retryCounter = 0
                    
                    if let localData = data {
                        if let status = localData["status"].string {
                            switch status {
                            case "OK":
                                // get record
                                let record = localData["record"]
                                let type_record = localData["entrance_type"]
                                
                                let type_id = type_record["id"].intValue
                                for item in type_record["sale_data"].arrayValue {
                                    let year = item["year"].intValue
                                    let month = item["month"].intValue
                                    let cost = item["cost"].intValue
                                    let costBon = item["cost_bon"].intValue
                                    
                                    self.entranceSaleData.append((entranceType: type_id, entranceYear: year, entranceMonth: month, cost: cost, costBon: costBon))
                                }
                                
                                let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                                var localArray: [ArchiveEntranceStructure] = []
                                for (_, item) in record {
                                    let organization_title = item["organization"]["title"].stringValue
                                    let entrance_year = item["year"].intValue
                                    let entrance_month = item["month"].intValue
                                    let last_published_str = item["last_published"].stringValue
                                    let unique_id = item["unique_key"].stringValue
                                    let extra_data = JSON(data: item["extra_data"].stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
                                    let duration = item["duration"].intValue
                                    let booklets_count = item["booklets_count"].intValue
                                    let entrance_type_id = item["entrance_type"]["id"].intValue
                                    let buy_count = item["stats"][0]["purchased"].intValue
                                    
                                    var index = -1
                                    if let i = self.entranceSaleData.indexOf({ (item) -> Bool in
                                        if item.entranceMonth == entrance_month && item.entranceYear == entrance_year && item.entranceType == entrance_type_id {
                                            return true
                                        }
                                        
                                        return false
                                    }) {
                                        index = i
                                    }
                                    
                                    if index >= 0 {
                                        let cost = self.entranceSaleData[index].costBon
                                        
                                        var entrance = ArchiveEntranceStructure()
                                        entrance.year = entrance_year
                                        entrance.month = entrance_month
                                        entrance.organization = organization_title
                                        entrance.extraData = extra_data
                                        entrance.buyCount = buy_count
                                        entrance.costBon = cost
                                        entrance.lastPablished = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(last_published_str)
                                        entrance.uniqueId = unique_id
                                        entrance.bookletCount = booklets_count
                                        entrance.entranceDuration = duration
                                        
                                        localArray.append(entrance)
                                    }
                                    
                                    
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
                    self.refreshControl?.endRefreshing()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                }
                
                if self.retryCounter < CONNECTION_MAX_RETRY {
                    self.retryCounter += 1
                    let operation = NSBlockOperation() {
                        self.getEntrances()
                    }
                    self.queue.addOperation(operation)
                } else {
                    self.retryCounter = 0
                    
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
                }
                
            })
        }
    }
    
    private func showBuyDialog(balance balance: Int, cost: Int, canBuy: Bool, index: Int) {
        if let rect = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 1)) as? AEDAdvanceTableViewCell {
            
            let popover = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ENTRANCE_BUY_VC") as! EntranceBuyViewController
            popover.modalPresentationStyle = .Popover
            popover.popoverPresentationController?.delegate = self
            popover.popoverPresentationController?.sourceView = rect.addToBasketButton
            popover.popoverPresentationController?.sourceRect = rect.addToBasketButton.bounds
            popover.popoverPresentationController?.permittedArrowDirections = .Any
            popover.preferredContentSize = CGSize(width: self.view.layer.bounds.width, height: 210)
            
            popover.balance = balance
            popover.cost = cost
            popover.canBuy = canBuy
            popover.productType = "Entrance"
            popover.uniqueId = self.entrances[index].uniqueId!
            popover.productBuyDelegate = self
            
            
            self.presentViewController(popover, animated: true, completion: nil)
        }
    }
    
    
    private func createWallet(indexPath indexPath: NSIndexPath, index: Int) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        WalletRestAPIClass.info(completion: { (data, error) in
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.createWallet(indexPath: indexPath, index: index)
                    })
                    self.queue.addOperation(operation)
                    
                } else {
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        let operation = NSBlockOperation(block: {
                            self.createWallet(indexPath: indexPath, index: index)
                        })
                        self.queue.addOperation(operation)
                    } else {
                        self.retryCounter = 0
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            AlertClass.hideLoaingMessage(progressHUD: self.loading)
                        }
                        AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                        
                        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? AEDAdvanceTableViewCell {
                            cell.changeBuyButtonState(state: false)
                        }
                        
                    }
                }
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                }
                
                self.retryCounter = 0
                
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? AEDAdvanceTableViewCell {
                    cell.changeBuyButtonState(state: false)
                }
                
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            let wallet_record = localData["record"]
                            let cash = wallet_record["cash"].intValue
                            
                            var updated = NSDate()
                            if let m = wallet_record["updated"].string {
                                updated = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(m)!
                            }
                            
                            UserDefaultsSingleton.sharedInstance.setWalletInfo(cash: cash, updated: updated)
                            
                            if UserDefaultsSingleton.sharedInstance.hasWallet() {
                                let walletInfo = UserDefaultsSingleton.sharedInstance.getWalletInfo()!
                                let cost: Int = self.entrances[index].costBon!
                                
                                var canBuy = true
                                if cost > walletInfo.cash {
                                    canBuy = false
                                }
                                
                                self.showBuyDialog(balance: walletInfo.cash, cost: cost, canBuy: canBuy, index: index)
                            }
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    break
                                default:
                                    break
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        AlertClass.showTopMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, type: "", completion: nil)
                                    })
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
            
            if self.retryCounter < CONNECTION_MAX_RETRY {
                self.retryCounter += 1
                let operation = NSBlockOperation(block: {
                    self.createWallet(indexPath: indexPath, index: index)
                })
                self.queue.addOperation(operation)
            } else {
                self.retryCounter = 0
                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                }
                
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? AEDAdvanceTableViewCell {
                    cell.changeBuyButtonState(state: false)
                }
                
                if let err = error {
                    switch err {
                    case .HostUnreachable:
                        fallthrough
                    case .NoInternetAccess:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                        })
                        
                        //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        //                        let operation = NSBlockOperation(block: {
                        //                            self.downloadUserPurchaseData()
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
    }
    
    private func downloadImages(ids: [Int]) {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        let newDir = docsDir.stringByAppendingPathComponent("images")
        
        let username: String = UserDefaultsSingleton.sharedInstance.getUsername()!
        let purchased = PurchasedModelHandler.getAllPurchasedIn(username: username, ids: ids)
        for p in purchased {
            if p.productType == "Entrance" {
                if let entrance = EntranceModelHandler.getByUsernameAndId(id: p.productUniqueId, username: username) {
                    downloadEsetImage(esetId: entrance.setId, rootDirectory: newDir, filemgr: filemgr)
                }
            }
        }
    }
    
    private func downloadEsetImage(esetId esetId: Int, rootDirectory: String, filemgr: NSFileManager) {
        
        MediaRestAPIClass.downloadEsetImageLocal(esetId, completion: {
            fullPath, data, error in
            
            if error != .Success {
                if error == HTTPErrorType.Refresh {
                    self.downloadEsetImage(esetId: esetId, rootDirectory: rootDirectory, filemgr: filemgr)
                } else {
                    //                    print("error in downloaing image from \(fullPath!)")
                }
            } else {
                if let myData = data {
                    let esetDir = (rootDirectory as NSString).stringByAppendingPathComponent("eset")
                    
                    do {
                        if filemgr.fileExistsAtPath(esetDir) == false {
                            try filemgr.createDirectoryAtPath(esetDir, withIntermediateDirectories: true, attributes: nil)
                        }
                        
                        let filePath = (esetDir as NSString).stringByAppendingPathComponent(String(esetId))
                        
                        if filemgr.fileExistsAtPath(filePath) == true {
                            try filemgr.removeItemAtPath(filePath)
                        }
                        filemgr.createFileAtPath(filePath, contents: myData, attributes: nil)
                        
                        
                    } catch {
                        
                    }
                }
            }
            }, failure: { (error) in
        })
        
    }
    
    
    @IBAction func buyButtonPressed(sender: UIButton) {
        //        self.showBuyDialog(balance: 500, cost: 100, canBuy: false)
        //        return
        
        let index = sender.tag
        let entranceRow = self.entrances[index]
        let uniqueId: String = entranceRow.uniqueId!
        
        if UserDefaultsSingleton.sharedInstance.hasWallet() {
            let walletInfo = UserDefaultsSingleton.sharedInstance.getWalletInfo()!
            let cost: Int = (self.entrances[index].costBon)!
            
            var canBuy = true
            if cost > walletInfo.cash {
                canBuy = false
            }
            
            self.showBuyDialog(balance: walletInfo.cash, cost: cost, canBuy: canBuy, index: index)
            
        } else {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 1)) as? AEDAdvanceTableViewCell {
                cell.disableBuyButton()
            }
            
            let operation = NSBlockOperation(block: {
                self.createWallet(indexPath: NSIndexPath(forRow: index, inSection: 1), index: index)
            })
            self.queue.addOperation(operation)
        }
        
    }
    
    // MARK: - Delegates
    func ProductBuyedResult(data data: JSON, productId: String, productType: String) {
        let cash = data["wallet_cash"].intValue
        var updated = NSDate()
        if let m = data["wallet_updated"].string {
            updated = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(m)!
        }
        
        UserDefaultsSingleton.sharedInstance.setWalletInfo(cash: cash, updated: updated)
        
        var index = -1
        index = self.entrances.indexOf({ (ent) -> Bool in
            return ent.uniqueId! == productId
        })!
        if index >= 0 {
            let entranceRow = self.entrances[index]

            let entranceStruct = EntranceStructure(entranceTypeTitle: self.esetDetail.entranceTypeTitle!, entranceOrgTitle: entranceRow.organization!, entranceGroupTitle: self.esetDetail.entranceGroupTitle!, entranceSetTitle: self.esetDetail.entranceEset!.title!, entranceSetId: self.esetDetail.entranceEset!.id!, entranceExtraData: entranceRow.extraData, entranceBookletCounts: entranceRow.bookletCount!, entranceYear: entranceRow.year!, entranceMonth: entranceRow.month!, entranceDuration: entranceRow.entranceDuration!, entranceUniqueId: entranceRow.uniqueId!, entranceLastPublished: entranceRow.lastPablished!)
            
            var purchasedTemp: [Int] = []
            let username = UserDefaultsSingleton.sharedInstance.getUsername()
            
            if let purchased = data["purchased"].array {
                for item in purchased {
                    let purchaseId = item["purchase_id"].intValue
                    let downloaded = item["downloaded"].intValue
                    
                    let purchased_time_str = item["purchase_time"].stringValue
                    let purchasedTime = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(purchased_time_str)!
                    
                    if EntranceModelHandler.add(entrance: entranceStruct, username: username!) == true {
                        if PurchasedModelHandler.add(id: purchaseId, username: username!, isDownloaded: false, downloadTimes: downloaded, isImageDownlaoded: false, purchaseType: "Entrance", purchaseUniqueId: entranceStruct.entranceUniqueId!, created: purchasedTime) == false {
                            
                            // rollback entrance insert
                            EntranceModelHandler.removeById(id: entranceStruct.entranceUniqueId!, username: username!)
                        } else {
                            purchasedTemp.append(purchaseId)
                        }
                    }
                    
                }
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.tableView.reloadData()
            }
            
            self.downloadImages(purchasedTemp)
            
            AlertClass.showAlertMessage(viewController: self, messageType: "ActionResult", messageSubType: "PurchasedSuccess", type: "success", completion: {
                self.tabBarController?.tabBar.items?[2].badgeValue = "\(purchasedTemp.count)"
            })

        }
        
        
    }
    
    
//    @IBAction func addToBasketPressed(sender: UIButton) {
//        let index = sender.tag
//        let entranceRow = self.entrances[index]
//        let uniqueId: String = entranceRow.uniqueId!
//        
//        let entranceStruct = EntranceStructure(entranceTypeTitle: self.esetDetail.entranceTypeTitle!, entranceOrgTitle: entranceRow.organization!, entranceGroupTitle: self.esetDetail.entranceGroupTitle!, entranceSetTitle: self.esetDetail.entranceEset!.title!, entranceSetId: self.esetDetail.entranceEset!.id!, entranceExtraData: entranceRow.extraData, entranceBookletCounts: entranceRow.bookletCount!, entranceYear: entranceRow.year!, entranceMonth: entranceRow.month!, entranceDuration: entranceRow.entranceDuration!, entranceUniqueId: entranceRow.uniqueId!, entranceLastPublished: entranceRow.lastPablished!)
//        
//        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 1)) as? AEDAdvanceTableViewCell {
//            cell.disableBuyButton()
//        }
//
//        if BasketSingleton.sharedInstance.BasketId == nil {
//            BasketSingleton.sharedInstance.createBasket(viewController: self, completion: {
//                if let id = BasketSingleton.sharedInstance.findSaleByTargetId(targetId: uniqueId, type: "Entrance") {
//                    // sale object exist --> remove it
//                    BasketSingleton.sharedInstance.removeSaleById(viewController: self, saleId: id, completion: { (count) in
//                        
//                        self.updateBasketBadge(count: count)
//                        self.changeBuyButtonStateForIndex(index)
//                        
//                        }, failure: {
//                            self.changeBuyButtonStateForIndex(index)
//                    
//                    })
//                } else {
//                    BasketSingleton.sharedInstance.addSale(viewController: self, target: entranceStruct as Any, type: "Entrance", completion: { (count) in
//                        self.updateBasketBadge(count: count)
//                        
//                        self.changeBuyButtonStateForIndex(index)
//                        }, failure: {
//                            self.changeBuyButtonStateForIndex(index)
//                    })
//                }
//                
//                }, failure: {
//                    self.changeBuyButtonStateForIndex(index)
//            })
//        } else {
//            if let id = BasketSingleton.sharedInstance.findSaleByTargetId(targetId: uniqueId, type: "Entrance") {
//                // sale object exist --> remove it
//                BasketSingleton.sharedInstance.removeSaleById(viewController: self, saleId: id, completion: { (count) in
//                    self.updateBasketBadge(count: count)
//                    
//                    self.changeBuyButtonStateForIndex(index)
//                    }, failure: {
//                        self.changeBuyButtonStateForIndex(index)
//                
//                })
//            } else {
//                BasketSingleton.sharedInstance.addSale(viewController: self, target: entranceStruct as Any, type: "Entrance", completion: { (count) in
//                    self.updateBasketBadge(count: count)
//                    
//                        self.changeBuyButtonStateForIndex(index)
//                    }, failure: {
//                        self.changeBuyButtonStateForIndex(index)
//                
//                })
//            }
//        }
//        
//    }
    
//    private func changeBuyButtonStateForIndex(index: Int) {
//        var saled = false
//        if let index = BasketSingleton.sharedInstance.findSaleByTargetId(targetId: self.entrances[index].uniqueId!, type: "Entrance") {
//            if index >= 0 {
//                saled = true
//            }
//            
//        }
//        self.entrances[index].saled = saled
//        
//        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .Automatic)
//
////        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 1)) as? AEDAdvanceTableViewCell {
////            
////            cell.changeBuyButtonState(state: saled)
////        }
//    }
    
    
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
            return 120.0
        case 1:
            return 85.0
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
                
                var buyed = false
                var date: NSDate? = nil
                if EntranceModelHandler.existById(id: self.entrances[indexPath.row].uniqueId!, username: self.username) {
                    buyed = true
                    
                    if let purc = PurchasedModelHandler.getByProductId(productType: "Entrance", productId: self.entrances[indexPath.row].uniqueId!, username: self.username) {
                        date = purc.created
                    }
                }
                
                cell.configureCell(indexPath: indexPath, esetId: (self.esetDetail.entranceEset?.id)!, entrance: self.entrances[indexPath.row], buyed: buyed, buyedTime: date)
                
                cell.addToBasketButton.tag = indexPath.row
                cell.addToBasketButton.addTarget(self, action: #selector(self.buyButtonPressed(_:)), forControlEvents: .TouchUpInside)
                return cell
            }
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
            self.getEntrances()
        }
        self.queue.addOperation(operation)
    }
    
    
    // MARK: - Navigation
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
    
    
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
                
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "محصولات", style: .Plain, target: self, action: nil)
                
            }
        } else if segue.identifier == "BasketCheckoutVCSegue" {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "محصولات", style: .Plain, target: self, action: nil)
            
        }
    }
}
