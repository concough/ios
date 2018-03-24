//
//  EntranceDetailTableViewController.swift
//  Concough
//
//  Created by Owner on 2016-12-20.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON
import BBBadgeBarButtonItem
import RNCryptor
import MBProgressHUD

class EntranceDetailTableViewController: UITableViewController {

    internal var entranceUniqueId: String!
    
    private var rightBarButtonItem: BBBadgeBarButtonItem!
    
    private var loading: MBProgressHUD?
    private var state: EntranceVCStateEnum!
    private var queue: NSOperationQueue!
    private var selfBasketAdd: Bool = false
    
    private var entrance: EntranceStructure?
    private var entranceStat: EntranceStatStructure?
    private var entranceSale: EntranceSaleStructure?
    private var entrancePurchase: EntrancePrurchasedStructure?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "آزمون"
        self.queue = NSOperationQueue()
    }

    override func viewWillAppear(animated: Bool) {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید", attributes: [NSFontAttributeName: UIFont(name: "IRANSansMobile-UltraLight", size: 12)!])
        }
        self.refreshControl?.addTarget(self, action: #selector(self.refreshTableView(_:)), forControlEvents: .ValueChanged)
        self.refreshControl?.endRefreshing()

        self.resetView()
    }

    override func viewDidAppear(animated: Bool) {
        self.updateBasketBadge(count: BasketSingleton.sharedInstance.SalesCount)


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refreshTableView(refreshControl_: UIRefreshControl) {
//        self.refreshControl?.endRefreshing()
        self.resetView()
    }
    
    
    // MARK: - Functions
    private func resetView() {
        self.setupBarButton()
        
        self.state = EntranceVCStateEnum.Initialize
        self.selfBasketAdd = false
        
        self.entrance = nil
        self.entranceSale = nil
        self.entranceStat = nil
        self.entrancePurchase = nil
        
        self.stateMachine()
    }
    
    private func setupBarButton() {
        if BasketSingleton.sharedInstance.SalesCount > 0 {
            let b = UIButton(frame: CGRectMake(0, 0, 25, 25))
            b.setImage(UIImage(named: "Buy_Blue"), forState: .Normal)
            
            b.addTarget(self, action: #selector(self.basketButtonPressed(_:)), forControlEvents: .TouchUpInside)
            
            self.rightBarButtonItem = BBBadgeBarButtonItem(customUIButton: b)
            self.rightBarButtonItem.badgeValue = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(0)
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
    
    private func updateBasketBadge(count count: Int) {
        if self.rightBarButtonItem == nil {
            self.setupBarButton()
        }

        if self.rightBarButtonItem != nil {
            self.rightBarButtonItem.badgeValue = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(count)
        }
    }
    
    private func stateMachine() {
        // State Machine here
        switch self.state! {
        case .Initialize:
            // first check local db
            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
            if EntranceModelHandler.existById(id: self.entranceUniqueId, username: username) == true {
                self.refreshControl?.endRefreshing()
                self.localEntrance()
            }
            else {
                // check if exist in basket
                if let index = BasketSingleton.sharedInstance.findSaleByTargetId(targetId: self.entranceUniqueId, type: "Entrance") {
                    
                    self.refreshControl?.endRefreshing()

                    self.entrance = BasketSingleton.sharedInstance.getSaleById(saleId: index) as? EntranceStructure
                    
                    self.state! = .EntranceComplete
                    self.selfBasketAdd = true
                    self.stateMachine()
                    return
                } else {
                    let operation = NSBlockOperation(block: {
                        self.downloadEntrance()
                    })
                    self.queue.addOperation(operation)
                }
            }
            
        case .EntranceComplete:
            // check local data exist
            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
            if let purchased = PurchasedModelHandler.getByProductId(productType: "Entrance", productId: self.entranceUniqueId, username: username) {
                
                self.entrancePurchase = EntrancePrurchasedStructure(id: purchased.id, created: purchased.created, amount: 0, downloaded: purchased.downloadTimes, isDownloaded: purchased.isDownloaded, isDataDownloaded: purchased.isLocalDBCreated, isImagesDownloaded: purchased.isImageDownloaded)
                
                self.state! = .Purchased
                self.stateMachine()
                return
            } else {
                let operation = NSBlockOperation(block: {
                    self.downloadUserPurchaseData()
                })
                self.queue.addOperation(operation)
            }
        case .NotPurchased:
            let operation = NSBlockOperation(block: {
                self.downloadEntranceStat()
            })
            self.queue.addOperation(operation)

        case .Purchased:
            self.navigationItem.rightBarButtonItem = nil
            // also reload tableView
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
            })
            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
            if let localPurchased = PurchasedModelHandler.getByProductId(productType: "Entrance", productId: self.entrance!.entranceUniqueId!, username: username) {
                
                if localPurchased.isDownloaded == true {
                    // make state = Downloaded
                    self.state! = .Downloaded
                    self.stateMachine()
                    return
                } else if let state = DownloaderSingleton.sharedInstance.getDownloaderState(uniqueId: self.entranceUniqueId) {
                    if state == DownloaderSingleton.DownloaderState.Started {
                        (DownloaderSingleton.sharedInstance.getMeDownloader(type: "Entrance", uniqueId: self.entranceUniqueId) as? EntrancePackageDownloader)?.registerVC(viewController: self, vcType: "ED")
                        self.state! = .DownloadStarted
                        self.stateMachine()
                        return
                    }
                }
            }

        case .ShowSaleInfo:
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.tableView.reloadData()
            })
        case .DownloadStarted:
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDPurchasedSectionTableViewCell {
                    cell.changeToDownloadStartedState()
                    cell.setNeedsLayout()
                }
            })
        case .Downloaded:
            // update server with downloaded
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
            })
        }
    }
    
    private func localEntrance() {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        
        if let localEntrance = EntranceModelHandler.getByUsernameAndId(id: self.entranceUniqueId, username: username) {
            let extra = JSON(data: localEntrance.extraData.dataUsingEncoding(NSUTF8StringEncoding)!)
            
            self.entrance = EntranceStructure(entranceTypeTitle: localEntrance.type, entranceOrgTitle: localEntrance.organization, entranceGroupTitle: localEntrance.group, entranceSetTitle: localEntrance.set, entranceSetId: localEntrance.setId, entranceExtraData: extra, entranceBookletCounts: localEntrance.bookletsCount, entranceYear: localEntrance.year, entranceMonth: localEntrance.month, entranceDuration: localEntrance.duration, entranceUniqueId: localEntrance.uniqueId, entranceLastPublished: localEntrance.lastPublished)
            
            self.state! = .EntranceComplete
            self.stateMachine()
        }
    }
    
    private func downloadEntrance() {
//        NSOperationQueue.mainQueue().addOperationWithBlock { 
//            self.loading = AlertClass.showLoadingMessage(viewController: self)
//        }
        
        EntranceRestAPIClass.getEntranceWithBuyInfo(uniqueId: self.entranceUniqueId, completion: { (data, error) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.refreshControl?.endRefreshing()
//                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.downloadEntrance()
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
                            let record = localData["records"]
                            
                            let organization = record["organization"]["title"].stringValue
                            let entrance_type = record["entrance_type"]["title"].stringValue
                            let entrance_set = record["entrance_set"]["title"].stringValue
                            let entrance_set_id = record["entrance_set"]["id"].intValue
                            let entrance_group = record["entrance_set"]["group"]["title"].stringValue
                            let extra_data = JSON(data: record["extra_data"].stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
                            let booklet_count = record["booklets_count"].intValue
                            let duration = record["duration"].intValue
                            let year = record["year"].intValue
                            let month = record["month"].intValue
                            let last_published_str = record["last_published"].stringValue
                            
                            let last_published = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(last_published_str)
                            
                            self.entrance = EntranceStructure(entranceTypeTitle: entrance_type, entranceOrgTitle: organization, entranceGroupTitle: entrance_group, entranceSetTitle: entrance_set, entranceSetId: entrance_set_id, entranceExtraData: extra_data, entranceBookletCounts: booklet_count, entranceYear: year, entranceMonth: month, entranceDuration: duration, entranceUniqueId: self.entranceUniqueId, entranceLastPublished: last_published)
                            
                            self.state = EntranceVCStateEnum.EntranceComplete
                            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                self.tableView.reloadData()
                            })
                            
                            // get purchase data from local or remote
                            self.stateMachine()
                            return
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EntranceNotExist":
                                        fallthrough
                                case "EmptyArray":
                                    // No Entrance data exist --> pop this
                                    
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                        AlertClass.showAlertMessage(viewController: self, messageType: "EntranceResult", messageSubType: "EntranceNotExist", type: "error", completion: {
                                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                                self.dismissViewControllerAnimated(true, completion: nil)
                                            })
                                        })
                                    })
//                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "EntranceResult", messageSubType: "EntranceNotExist", completion: {
//                                        
//                                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                                            self.dismissViewControllerAnimated(true, completion: nil)
//                                        })                                        
//                                    })
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
            
        }, failure: { (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.refreshControl?.endRefreshing()
//                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
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
//                            self.downloadEntrance()
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
            
        })
    }
    
    private func downloadUserPurchaseData() {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        PurchasedRestAPIClass.getEntrancePurchasedData(uniqueId: self.entranceUniqueId, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.refreshControl?.endRefreshing()
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
                
            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.downloadUserPurchaseData()
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
                            let purchase = localData["purchase"]
                            if let purchaseStatus = purchase["status"].bool {
                                if purchaseStatus == false {
                                    self.state = EntranceVCStateEnum.NotPurchased
                                } else {
                                    // get purchase record
                                    if purchase["purchase_record"] != nil {
                                        let purchase_record = purchase["purchase_record"]
                                        let id = purchase_record["id"].intValue
                                        let amount = purchase_record["payed_amount"].intValue
                                        let downloaded = purchase_record["downloaded"].intValue
                                        
                                        let created_str = purchase_record["created"].stringValue
                                        let created = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(created_str)
                                        
                                        self.entrancePurchase = EntrancePrurchasedStructure(id: id, created: created, amount: amount, downloaded: downloaded, isDownloaded: false, isDataDownloaded: false, isImagesDownloaded: false)
                                        
                                        // Save it to db for future to not fetch
                                        let username = UserDefaultsSingleton.sharedInstance.getUsername()
                                        if EntranceModelHandler.add(entrance: self.entrance!, username: username!) == true {
                                            if PurchasedModelHandler.add(id: id, username: username!, isDownloaded: false, downloadTimes: downloaded, isImageDownlaoded: false, purchaseType: "Entrance", purchaseUniqueId: self.entrance!.entranceUniqueId!, created: created!) == false {
                                                
                                                // rollback entrance insert
                                                EntranceModelHandler.removeById(id: self.entrance!.entranceUniqueId!, username: username!)
                                            }
                                        }
                                        
                                    }
                                    
                                    self.state = EntranceVCStateEnum.Purchased
                                }
                                self.stateMachine()
                                return
                            }
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    fallthrough
                                case "EntranceNotExist":
                                    // No Entrance data exist --> pop this
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        AlertClass.showAlertMessage(viewController: self, messageType: "EntranceResult", messageSubType: "EntranceNotExist", type: "error", completion: {
                                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                                self.dismissViewControllerAnimated(true, completion: nil)
                                            })
                                        })
                                    })
                                    
//                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "EntranceResult", messageSubType: "EntranceNotExist", completion: {
//                                        
//                                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                                            self.dismissViewControllerAnimated(true, completion: nil)
//                                        })
//                                    })
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
        }, failure: { (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
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
        })
    }

    private func refreshUserPurchaseData() {
//        NSOperationQueue.mainQueue().addOperationWithBlock { 
//            self.loading = AlertClass.showLoadingMessage(viewController: self)
//        }
        
        PurchasedRestAPIClass.getEntrancePurchasedData(uniqueId: self.entranceUniqueId, completion: { (data, error) in
//            NSOperationQueue.mainQueue().addOperationWithBlock({ 
//                AlertClass.hideLoaingMessage(progressHUD: self.loading)
//            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.refreshUserPurchaseData()
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
                            let purchase = localData["purchase"]
                            // get purchase record
                            if purchase["purchase_record"] != nil {
                                let purchase_record = purchase["purchase_record"]
                                let id = purchase_record["id"].intValue
                                let downloaded = purchase_record["downloaded"].intValue
                                
                                let username = UserDefaultsSingleton.sharedInstance.getUsername()

                                self.entrancePurchase?.downloaded = downloaded
                                PurchasedModelHandler.updateDownloadTimes(username: username!, id: id, newDownloadTimes: downloaded)
                                
                                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDPurchasedSectionTableViewCell {
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                        cell.updateDownloadedLabel(count: downloaded)
                                        cell.showLoading(flag: false)
                                    })
                                }
                            }
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    fallthrough
                                case "EntranceNotExist":
                                    // No Entrance data exist --> pop this
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
            }, failure: { (error) in
//                NSOperationQueue.mainQueue().addOperationWithBlock({
//                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
//                })
                
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
        })
    }
    
    private func updateUserPurchaseData() {
//        NSOperationQueue.mainQueue().addOperationWithBlock { 
//            self.loading = AlertClass.showUpdatingMessage(viewController: self)
//        }
        
        PurchasedRestAPIClass.putEntrancePurchasedDownload(uniqueId: self.entranceUniqueId, completion: { (data, error) in
//            NSOperationQueue.mainQueue().addOperationWithBlock({ 
//                AlertClass.hideLoaingMessage(progressHUD: self.loading)
//            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.updateUserPurchaseData()
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
                            let purchase = localData["purchase"]
                            // get purchase record
                            if purchase["purchase_record"] != nil {
                                let purchase_record = purchase["purchase_record"]
                                let id = purchase_record["id"].intValue
                                let downloaded = purchase_record["downloaded"].intValue
                                
                                let username = UserDefaultsSingleton.sharedInstance.getUsername()
                                
                                self.entrancePurchase?.downloaded = downloaded
                                PurchasedModelHandler.updateDownloadTimes(username: username!, id: id, newDownloadTimes: downloaded)
                                
                                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDPurchasedSectionTableViewCell {
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        cell.updateDownloadedLabel(count: downloaded)
                                        cell.showLoading(flag: false)
                                    })
                                }
                            }
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    fallthrough
                                case "EntranceNotExist":
                                    // No Entrance data exist --> pop this
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
            }, failure: { (error) in
//                NSOperationQueue.mainQueue().addOperationWithBlock({
//                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
//                })
                
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
        })
    }
    
    private func downloadEntranceStat() {
//        NSOperationQueue.mainQueue().addOperationWithBlock { 
//            self.loading = AlertClass.showLoadingMessage(viewController: self)
//        }
        
        ProductRestAPIClass.getEntranceStatData(uniqueId: self.entranceUniqueId, completion: { (data, error) in
//            NSOperationQueue.mainQueue().addOperationWithBlock({ 
//                AlertClass.hideLoaingMessage(progressHUD: self.loading)
//            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.downloadEntranceStat()
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
                            let stat = localData["stat_data"]
                            let purchased = stat["purchased"].intValue
                            let updated_str = stat["updated"].stringValue
                            let updated = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(updated_str)
                            
                            self.entranceStat = EntranceStatStructure(purchased: purchased, updated: updated)
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    break
                                case "EntranceNotExist":
                                    // No Entrance data exist --> pop this
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        AlertClass.showAlertMessage(viewController: self, messageType: "EntranceResult", messageSubType: "EntranceNotExist", type: "error", completion: {
                                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                                self.dismissViewControllerAnimated(true, completion: nil)
                                            })
                                        })
                                    })
                                    
//                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "EntranceResult", messageSubType: "EntranceNotExist", completion: {
//                                        
//                                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                                            self.dismissViewControllerAnimated(true, completion: nil)
//                                        })
//                                    })
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
                
                // download sale data
                let operation = NSBlockOperation(block: {
                    self.downloadEntranceSale()
                })
                self.queue.addOperation(operation)
                
            }
            
        }) { (error) in
//            NSOperationQueue.mainQueue().addOperationWithBlock({
//                AlertClass.hideLoaingMessage(progressHUD: self.loading)
//            })
            
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
    
    private func downloadEntranceSale() {
//        NSOperationQueue.mainQueue().addOperationWithBlock { 
//            self.loading = AlertClass.showLoadingMessage(viewController: self)
//        }
        
        ProductRestAPIClass.getEntranceSaleData(uniqueId: self.entranceUniqueId, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.refreshControl?.endRefreshing()
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
                
            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.downloadEntranceSale()
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
                            let sale = localData["sale_data"]
                            let discount = sale["discount"].intValue
                            let cost = sale["sale_record"]["cost"].intValue
                            
                            self.entranceSale = EntranceSaleStructure(discount: discount, cost: cost)
                            self.state = EntranceVCStateEnum.ShowSaleInfo
                            self.stateMachine()
                            return
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    break
                                case "EntranceNotExist":
                                    // No Entrance data exist --> pop this
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        AlertClass.showAlertMessage(viewController: self, messageType: "EntranceResult", messageSubType: "EntranceNotExist", type: "error", completion: {
                                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                                self.dismissViewControllerAnimated(true, completion: nil)
                                            })
                                        })
                                    })
                                    
//                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "EntranceResult", messageSubType: "EntranceNotExist", completion: {
//                                        
//                                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                                            self.dismissViewControllerAnimated(true, completion: nil)
//                                        })
//                                    })
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
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.refreshControl?.endRefreshing()
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
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
    
    internal func downloadProgress(value value: Int) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDPurchasedSectionTableViewCell {
                cell.changeProgressValue(value: value)
                cell.setNeedsLayout()
            }
        }
    }
    
    internal func downloadPaused() {
        DownloaderSingleton.sharedInstance.removeDownloader(uniqueId: self.entranceUniqueId)
        self.navigationItem.hidesBackButton = false
        
        self.state! = EntranceVCStateEnum.Purchased
        self.stateMachine()
        return        
    }
    
    internal func downloadImagesFinished(result result: Bool) {
        if result == true {
            DownloaderSingleton.sharedInstance.removeDownloader(uniqueId: self.entranceUniqueId)
            self.navigationItem.hidesBackButton = false
            
            self.updateUserPurchaseData()
            
            let eData = JSON(["uniqueId": self.entranceUniqueId])
            self.createLog(logType: LogTypeEnum.EnranceDownload.rawValue, extraData: eData)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.showTopMessage(viewController: self, messageType: "ActionResult", messageSubType: "DownloadSuccess", type: "success", completion: nil)
            })
            
            self.state! = EntranceVCStateEnum.Downloaded
            self.stateMachine()
            return
        } else {
            DownloaderSingleton.sharedInstance.removeDownloader(uniqueId: self.entranceUniqueId)

            AlertClass.showTopMessage(viewController: self, messageType: "ActionResult", messageSubType: "DownloadFailed", type: "error", completion: nil)
            
            self.state! = EntranceVCStateEnum.Purchased
            self.stateMachine()
            return

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
    
    
    
    // MARK: - Actions
    @IBAction func buyButtonPressed(sender: UIButton) {
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDSaleSectionTableViewCell {
            cell.disableBuyButton()
        }
        
        if BasketSingleton.sharedInstance.BasketId == nil {
            BasketSingleton.sharedInstance.createBasket(viewController: self, completion: { 
                if let id = BasketSingleton.sharedInstance.findSaleByTargetId(targetId: self.entranceUniqueId, type: "Entrance") {
                    // sale object exist --> remove it
                    BasketSingleton.sharedInstance.removeSaleById(viewController: self, saleId: id, completion: { (count) in
                        self.selfBasketAdd = !self.selfBasketAdd
                        self.updateBasketBadge(count: count)
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.tableView.reloadData()
                        }
                        }, failure: {
                            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDSaleSectionTableViewCell {
                                cell.changeButtonState(state: self.selfBasketAdd)
                            }
                    })
                } else {
                    BasketSingleton.sharedInstance.addSale(viewController: self, target: self.entrance! as Any, type: "Entrance", completion: { (count) in
                        self.selfBasketAdd = !self.selfBasketAdd
                        self.updateBasketBadge(count: count)

                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.tableView.reloadData()
                        }
                        }, failure: {
                            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDSaleSectionTableViewCell {
                                cell.changeButtonState(state: self.selfBasketAdd)
                            }
                    })
                }
                
                }, failure: {
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDSaleSectionTableViewCell {
                        cell.changeButtonState(state: self.selfBasketAdd)
                    }
            })
        } else {
            if let id = BasketSingleton.sharedInstance.findSaleByTargetId(targetId: self.entranceUniqueId, type: "Entrance") {
                // sale object exist --> remove it
                BasketSingleton.sharedInstance.removeSaleById(viewController: self, saleId: id, completion: { (count) in
                    self.selfBasketAdd = !self.selfBasketAdd
                    self.updateBasketBadge(count: count)
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.tableView.reloadData()
                    }
                    }, failure: {
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDSaleSectionTableViewCell {
                            cell.changeButtonState(state: self.selfBasketAdd)
                        }
                })
            } else {
                BasketSingleton.sharedInstance.addSale(viewController: self, target: self.entrance! as Any, type: "Entrance", completion: { (count) in
                    self.selfBasketAdd = !self.selfBasketAdd
                    self.updateBasketBadge(count: count)
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.tableView.reloadData()
                    }
                    }, failure: {
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDSaleSectionTableViewCell {
                            cell.changeButtonState(state: self.selfBasketAdd)
                        }
                
                })
            }
        }
    }
    
    @IBAction func basketButtonPressed(sender: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.performSegueWithIdentifier("BasketCheckoutVCSegue", sender: self)
        }
    }
    
    @IBAction func downloadButtonPressed(sender: UIButton) {
        //self.navigationItem.setHidesBackButton(true, animated: true)
        NSOperationQueue.mainQueue().addOperationWithBlock({
            AlertClass.showTopMessage(viewController: self, messageType: "ActionResult", messageSubType: "DownloadStarted", type: "warning", completion: nil)
        })
        
        // Get from db if download initial data
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        if PurchasedModelHandler.isInitialDataDownloaded(productType: "Entrance", productId: self.entranceUniqueId!, username: username) == true {
            let operation = NSBlockOperation(block: {
                let downloader = DownloaderSingleton.sharedInstance.getMeDownloader(type: "Entrance", uniqueId: self.entranceUniqueId) as! EntrancePackageDownloader
                downloader.initialize(entranceUniqueId: self.entranceUniqueId!, viewController: self, vcType: "ED", username: username)
                downloader.fillImagesArray({ (result) in
                    if result == true {
                        let filemgr = NSFileManager.defaultManager()
                        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                        
                        let docsDir = dirPaths[0] as NSString
                        let newDir = docsDir.stringByAppendingPathComponent(self.entranceUniqueId!)
                        
                        var isDir: ObjCBool = false
                        if filemgr.fileExistsAtPath(newDir, isDirectory: &isDir) == true {
                            if isDir {
                                let count = downloader.DownloadCount
                                
                                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDPurchasedSectionTableViewCell {
                                    cell.changeToDownloadState(total: count)
                                    cell.setNeedsLayout()
                                }
                                
                                DownloaderSingleton.sharedInstance.setDownloaderStarted(uniqueId: self.entranceUniqueId)
                                
                                downloader.downloadPackageImages(saveDirectory: newDir)
                            }
                        }
                    }
                })
                
            })
            self.queue.addOperation(operation)
            
        } else {
            let operation = NSBlockOperation(block: {
                let downloader = DownloaderSingleton.sharedInstance.getMeDownloader(type: "Entrance", uniqueId: self.entranceUniqueId) as! EntrancePackageDownloader
                downloader.initialize(entranceUniqueId: self.entranceUniqueId!, viewController: self, vcType: "ED", username: username)
                
                downloader.downloadInitialData(self.queue, completion: { (result, indexPath) in
                    if result == true {
                        let valid2 = PurchasedModelHandler.setIsLocalDBCreatedTrue(productType: "Entrance", productId: self.entranceUniqueId!, username: username)
                        
                        if valid2 == true {
                            let filemgr = NSFileManager.defaultManager()
                            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                            
                            let docsDir = dirPaths[0] as NSString
                            let newDir = docsDir.stringByAppendingPathComponent(self.entranceUniqueId!)
                            
                            do {
                                try filemgr.removeItemAtPath(newDir)
                            } catch {}
                            
                            do {
                                try filemgr.createDirectoryAtPath(newDir, withIntermediateDirectories: true, attributes: nil)

                                let count = downloader.DownloadCount

                                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDPurchasedSectionTableViewCell {
                                    cell.changeToDownloadState(total: count)
                                    cell.setNeedsLayout()
                                }
                                
                                DownloaderSingleton.sharedInstance.setDownloaderStarted(uniqueId: self.entranceUniqueId)
                                
                                downloader.downloadPackageImages(saveDirectory: newDir)
                                
                            } catch {}
                            
                        }
                    }
                })
            })
            self.queue.addOperation(operation)
        }
    }
    
    @IBAction func refreshPurchaseButtonPressed(sender: UIButton) {
        if self.state! == .Purchased {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EDPurchasedSectionTableViewCell {
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    cell.showLoading(flag: true)
                })
                // download purchase item
                self.refreshUserPurchaseData()
            }
        }
    }
    
    @IBAction func showEntranceButtonPressed(sender: UIButton) {
        var canShow = true
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        if let counter = SnapshotCounterHandler.getByUsernameAndProductId(username: username, productUniqueId: self.entranceUniqueId, productType: "Entrance") {
            if let blockTime = counter.blockTo {
                if blockTime.compare(NSDate()) == .OrderedDescending {
                    canShow = false
                    let date = FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(blockTime)
                    AlertClass.showAlertMessageWithParams(viewController: self, messageType: "ActionResult", messageSubType: "BlockedByScreenshotTime", params: [date], type: "error", completion: nil)

                }
            }
        }

        if canShow {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("EntranceShowVCSegue", sender: self)
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch self.state! {
        case .Initialize:
            return 0
        case .EntranceComplete:
            return 1
        case .DownloadStarted:
            fallthrough
        case .Downloaded:
            fallthrough
        case .ShowSaleInfo:
            fallthrough
        case .Purchased:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.state! {
        case .Initialize:
            return 0
        case .EntranceComplete:
            return 3
        case .DownloadStarted:
            fallthrough
        case .Downloaded:
            fallthrough
        case .Purchased:
            fallthrough
        case .ShowSaleInfo:
            switch section {
            case 0:
                return 3
            default:
                return 1
            }
            
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("INITIAL_SECTION", forIndexPath: indexPath) as? EDInitialSectionTableViewCell {
                    cell.configureCell(title: "\(self.entrance!.entranceTypeTitle!)", subTitle: "\(self.entrance!.entranceSetTitle!) (\(self.entrance!.entranceGroupTitle!))", imageId: self.entrance!.entranceSetId!, indexPath: indexPath)
                    return cell
                }
            case 1:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("HEADER_SECTION", forIndexPath: indexPath) as? EDHeaderSectionTableViewCell {
                    cell.configureCell(title: "اطلاعات آزمون", extraData: self.entrance!.entranceOrgTitle!)
                    return cell
                }
            case 2:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("INFORMATION_SECTION", forIndexPath: indexPath) as? EDInformationSectionTableViewCell {
                    
                    cell.configureCell(bookletCount: self.entrance!.entranceBookletCounts!, duration: self.entrance!.entranceDuration!, year: self.entrance!.entranceYear!, month: self.entrance!.entranceMonth!)
                    return cell
                }
            default:
                break
            }
        case 1:
            if self.state! == .ShowSaleInfo {
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SALE_SECTION", forIndexPath: indexPath) as? EDSaleSectionTableViewCell {
                    
                    cell.configureCell(saleData: self.entranceSale, statData: self.entranceStat, buttonState: self.selfBasketAdd, basketItemCount: BasketSingleton.sharedInstance.SalesCount)
                    // Add Target to Button
                    cell.buyButton.addTarget(self, action: #selector(self.buyButtonPressed(_:)), forControlEvents: .TouchUpInside)
                    cell.basketFinishButton.addTarget(self, action: #selector(self.basketButtonPressed(_:)), forControlEvents: .TouchUpInside)
                    return cell
                }
            } else if self.state! == .Purchased {
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("PURCHASED_SECTION", forIndexPath: indexPath) as? EDPurchasedSectionTableViewCell {
                    
                    cell.configureCell(purchased: self.entrancePurchase!)
                    cell.downloadButton.addTarget(self, action: #selector(self.downloadButtonPressed(_:)), forControlEvents: .TouchUpInside)
                    cell.refreshPurchaseButton.addTarget(self, action: #selector(self.refreshPurchaseButtonPressed(_:)), forControlEvents: .TouchUpInside)
                    
                    return cell
                }
            } else if self.state! == .DownloadStarted {
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("PURCHASED_SECTION", forIndexPath: indexPath) as? EDPurchasedSectionTableViewCell {
                    
                    cell.configureCell(purchased: self.entrancePurchase!)
                    cell.downloadButton.addTarget(self, action: #selector(self.downloadButtonPressed(_:)), forControlEvents: .TouchUpInside)
                    return cell
                }
            } else if self.state! == .Downloaded {
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("DOWNLOADED_SECTION", forIndexPath: indexPath) as? EDDownloadedTableViewCell {
                    
                    cell.jumpToFavoritesButton.addTarget(self, action: #selector(self.showEntranceButtonPressed(_:)), forControlEvents: .TouchUpInside)
                    return cell
                }
            }
        default:
            break
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 180.0
            case 1:
                return 70.0
            case 2:
                return 80.0
            default:
                break
            }
        case 1:
            if self.state! == .ShowSaleInfo {
                if self.selfBasketAdd == true {
                    return 185.0
                } else {
                    return 90.0
                }
            } else if self.state! == .Purchased || self.state! == .Downloaded || self.state! == .DownloadStarted {
                return 100.0
            }
        default:
            break
        }
        return 0.0
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BasketCheckoutVCSegue" {
            if segue.destinationViewController is BasketCheckoutTableViewController {
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "ادامه خرید", style: .Plain, target: self, action: nil)

            }
        } else if segue.identifier == "EntranceShowVCSegue" {
            if let vc = segue.destinationViewController as? EntranceShowTableViewController {
                vc.entrance = self.entrance
                vc.entranceUniqueId = self.entranceUniqueId
                vc.hidesBottomBarWhenPushed = true
                vc.showType = "Show"
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
            }
        }
    }

}
