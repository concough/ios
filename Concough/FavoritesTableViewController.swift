//
//  FavoritesTableViewController.swift
//  Concough
//
//  Created by Owner on 2017-01-17.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD

class FavoritesTableViewController: UITableViewController {

    private var purchased: [(uniqueId: String ,type: String, object: Any, purchased: Any, starred: Int, opened: Int, questionsCount: Int)] = []
    private var queue: NSOperationQueue!
    
    private var selectedIndex: NSIndexPath?
    private var selectedShowType: String = "Show"
    private var showType: String = "Normal"
    private var DownloadedCount: [Int] = []
    private var loading: MBProgressHUD?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.queue = NSOperationQueue()
        
        // uitableview refresh control setup
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید")
        }
        self.refreshControl?.addTarget(self, action: #selector(self.refreshTableView(_:)), forControlEvents: .ValueChanged)
        self.tableView.tableFooterView = UIView()
        
        self.title = "آرشیو"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }

    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.items?[2].badgeValue = nil
        self.loadData()        
    }
    
    // MARK: - Actions
    @IBAction func refreshTableView(refreshControl_: UIRefreshControl) {
        self.loadData()
    }
    
    @IBAction func downloadTapped(sender: UITapGestureRecognizer) {
        let indexPathStr = sender.assicatedObject.componentsSeparatedByString(":")
        let section = Int(indexPathStr[0])
        let row = Int(indexPathStr[1])
        
        let indexPath = NSIndexPath(forRow: row!, inSection: section!)
        if row! < self.purchased.count {
            let item = self.purchased[row!]
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.showTopMessage(viewController: self, messageType: "ActionResult", messageSubType: "DownloadStarted", type: "warning", completion: nil)
            })
            self.downloadPackage(productId: item.uniqueId, productType: item.type, indexPath: indexPath)
        }
    }
    
    @IBAction func showEntranceTapped(sender: UITapGestureRecognizer) {
        let indexPathStr = sender.assicatedObject.componentsSeparatedByString(":")
        let section = Int(indexPathStr[0])
        let row = Int(indexPathStr[1])
        
        let indexPath = NSIndexPath(forRow: row!, inSection: section!)
        self.selectedShowType = "Show"
        
        if row! < self.purchased.count {
            self.selectedIndex = indexPath
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.performSegueWithIdentifier("EntranceShowVCSegue", sender: self)
            })
        }
    }

    @IBAction func showStarredQuestionTapped(sender: UITapGestureRecognizer) {
        let indexPathStr = sender.assicatedObject.componentsSeparatedByString(":")
        let section = Int(indexPathStr[0])
        let row = Int(indexPathStr[1])
        
        let indexPath = NSIndexPath(forRow: row!, inSection: section!)
        self.selectedShowType = "Starred"
        
        if row! < self.purchased.count {
            self.selectedIndex = indexPath
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.performSegueWithIdentifier("EntranceShowVCSegue", sender: self)
            })
        }
    }
    
    @IBAction func syncWithServerPressed(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.syncWithServer()
    }
    
    @IBAction func deleteButtonPressed(sender: UIButton) {
        // create alert controller
        
        AlertClass.showAlertMessageCustom(viewController: self, title: "آیا مطمینید؟", message: "تنها اطلاعات کنکور حذف خواهد شد و مجددا قابل بارگذاری است", yesButtonTitle: "بله", noButtonTitle: "خیر") {
        
            let indexPathStr = sender.assicatedObject.componentsSeparatedByString(":")
            let section = Int(indexPathStr[0])
            let row = Int(indexPathStr[1])
            
            let indexPath = NSIndexPath(forRow: row!, inSection: section!)
            
            let i = self.DownloadedCount[indexPath.row]
            let purchased = self.purchased[i]
            self.deletePurchaseData(uniqueId: purchased.uniqueId)
            
            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
            if PurchasedModelHandler.resetDownloadFlags(username: username, id: (purchased.purchased as! EntrancePrurchasedStructure).id! ) == true {
                
                EntrancePackageHandler.removePackage(username: username, entranceUniqueId: purchased.uniqueId)
                EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: purchased.uniqueId)
                EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: purchased.uniqueId)
                
                self.DownloadedCount.removeAtIndex(indexPath.row)
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    @IBAction func editButtonPressed(sender: UIBarButtonItem) {
        if self.showType == "Normal" {
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clearColor()
            self.navigationItem.rightBarButtonItem?.enabled = false
            self.showType = "Edit"
            
            self.title = "ویرایش"
            self.navigationItem.leftBarButtonItem?.title = "انجام شد"
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.tableView.reloadData()
            })
        } else if self.showType == "Edit" {
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.showType = "Normal"
            
            self.title = "آرشیو"
            self.navigationItem.leftBarButtonItem?.title = "ویرایش"

            self.loadData()
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
            })
        }
    }
    
    // MARK: - Functions
    private func syncWithServer() {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        PurchasedRestAPIClass.getPurchasedList({ (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            }
            
            if error != HTTPErrorType.Success {
                AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            
                            var purchasedId: [Int] = []
                            let records = localData["records"].arrayValue
                            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                            for record in records {
                                let id = record["id"].intValue
                                let downloaded = record["downloaded"].intValue
                                let createdStr = record["created"].stringValue
                                let created = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(createdStr)
                                
                                if PurchasedModelHandler.getByUsernameAndId(id: id, username: username) != nil {
                                    PurchasedModelHandler.updateDownloadTimes(username: username, id: id, newDownloadTimes: downloaded)
                                } else {
                                    // does not exist
                                    let target = record["target"]
                                    let targetType = target["product_type"].stringValue
                                    
                                    if targetType == "Entrance" {
                                        let uniqueId = target["unique_key"].stringValue
                                        
                                        if PurchasedModelHandler.add(id: id, username: username, isDownloaded: false, downloadTimes: downloaded, isImageDownlaoded: false, purchaseType: targetType, purchaseUniqueId: uniqueId, created: created!) == true {
                                            
                                            // save entrance
                                            let org = target["organization"]["title"].stringValue
                                            let type = target["entrance_type"]["title"].stringValue
                                            let setName = target["entrance_set"]["title"].stringValue
                                            let group = target["entrance_set"]["group"]["title"].stringValue
                                            let setId = target["entrance_set"]["id"].intValue
                                            let bookletsCount = target["booklets_count"].intValue
                                            let duration = target["duration"].intValue
                                            let year = target["year"].intValue
                                            let extraData = JSON(data: target["extra_data"].stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
                                            
                                            let lastPablishedStr = target["last_published"].stringValue
                                            let lastPublished = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(lastPablishedStr)
                                            
                                            if EntranceModelHandler.getByUsernameAndId(id: uniqueId, username: username) == nil {
                                                let entrance = EntranceStructure(entranceTypeTitle: type, entranceOrgTitle: org, entranceGroupTitle: group, entranceSetTitle: setName, entranceSetId: setId, entranceExtraData: extraData, entranceBookletCounts: bookletsCount, entranceYear: year, entranceDuration: duration, entranceUniqueId: uniqueId, entranceLastPublished: lastPublished)
                                                
                                                EntranceModelHandler.add(entrance: entrance, username: username)
                                                
                                            }
                                        }
                                    }
                                }
                                
                                purchasedId.append(id)
                                //print ("---> \(purchasedId)")
                            }
                            
                            // delete all that does not exist
                            let deletedItems = PurchasedModelHandler.getAllPurchasedNotIn(username: username, ids: purchasedId)
                            //print ("---> \(deletedItems)")

                            if deletedItems.count > 0 {
                                for item in deletedItems {
                                    self.deletePurchaseData(uniqueId: item.productUniqueId)
                                    
                                    // delete product and purchase
                                    if item.productType == "Entrance" {
                                        if EntranceModelHandler.removeById(id: item.productUniqueId, username: username) == true {
                                            
                                            EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId)
                                            EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId)
                                            PurchasedModelHandler.removeById(username: username, id: item.id)
                                            
                                        }
                                    }
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.loadData()
                                self.tableView.reloadData()
                            })
                            
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    // All purchased must be deleted
                                    let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                                    let items = PurchasedModelHandler.getAllPurchased(username: username)
                                    for item in items {
                                        self.deletePurchaseData(uniqueId: item.productUniqueId)
                                        
                                        // delete product and purchase
                                        if item.productType == "Entrance" {
                                            if EntranceModelHandler.removeById(id: item.productUniqueId, username: username) == true {
                                                
                                                EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId)
                                                EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId)
                                                PurchasedModelHandler.removeById(username: username, id: item.id)
                                                
                                            }
                                        }
                                    }
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
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
                    
//                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                            self.syncWithServer()
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
    
    private func deletePurchaseData(uniqueId uniqueId: String) {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        let newDir = docsDir.stringByAppendingPathComponent(uniqueId)
        
        do {
            
            try filemgr.removeItemAtPath(newDir)
        } catch {}
    }
    
    private func loadData() {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        let items = PurchasedModelHandler.getAllPurchased(username: username)
        if items.count > 0 {
            var localPurchased: [(uniqueId: String ,type: String, object: Any, purchased: Any, starred: Int, opened: Int, questionsCount: Int)] = []
            
            self.DownloadedCount.removeAll()
            for item in items {
                if item.productType == "Entrance" {
                    var purchased = EntrancePrurchasedStructure()
                    purchased.id = item.id
                    purchased.amount = 0
                    purchased.downloaded = item.downloadTimes
                    purchased.isDataDownloaded = item.isLocalDBCreated
                    purchased.isImagesDownloaded = item.isImageDownloaded
                    purchased.isDownloaded = item.isDownloaded
                    
                    // Get entrance from local db
                    if let entrance = EntranceModelHandler.getByUsernameAndId(id: item.productUniqueId, username: username) {
                        let extraData = JSON(data: entrance.extraData.dataUsingEncoding(NSUTF8StringEncoding)!)
                        
                        let entranceS = EntranceStructure(entranceTypeTitle: entrance.type, entranceOrgTitle: entrance.organization, entranceGroupTitle: entrance.group, entranceSetTitle: entrance.set, entranceSetId: entrance.setId, entranceExtraData: extraData, entranceBookletCounts: entrance.bookletsCount, entranceYear: entrance.year, entranceDuration: entrance.duration, entranceUniqueId: entrance.uniqueId, entranceLastPublished: entrance.lastPublished)
                        
                        // load starred questions if exist
                        let starCount = EntranceQuestionStarredModelHandler.countByEntranceId(entranceUniqueId: item.productUniqueId)
                        // load opened count from db
                        let openedCount = EntranceOpenedCountModelHandler.countByEntranceId(entranceUniqueId: item.productUniqueId)
                        // load questionsCount
                        let qCount = EntranceQuestionModelHandler.countQuestions(entranceId: item.productUniqueId)
                        
                        localPurchased.append((uniqueId: entranceS.entranceUniqueId!, type: "Entrance", object: entranceS, purchased: purchased, starred: starCount, opened: openedCount, questionsCount: qCount))
                        
                        if purchased.isDownloaded == true {
                            self.DownloadedCount.append(localPurchased.count - 1)
                        }
                    }
                }
            }
            self.purchased = localPurchased
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            })
        }
    }
    
    private func updateUserPurchaseData(productId productId: String, productType: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.loading = AlertClass.showUpdatingMessage(viewController: self)
        }
        
        PurchasedRestAPIClass.putEntrancePurchasedDownload(uniqueId: productId, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock ({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error != HTTPErrorType.Success {
                AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            // print("\(localData)")
                            let purchase = localData["purchase"]
                            // get purchase record
                            if purchase["purchase_record"] != nil {
                                let purchase_record = purchase["purchase_record"]
                                let id = purchase_record["id"].intValue
                                let downloaded = purchase_record["downloaded"].intValue
                                
                                let username = UserDefaultsSingleton.sharedInstance.getUsername()
                                PurchasedModelHandler.updateDownloadTimes(username: username!, id: id, newDownloadTimes: downloaded)
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
                    case .NoInternetAccess:
                        fallthrough
                    case .HostUnreachable:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                        })
                        
//                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                            let operation = NSBlockOperation(block: {
//                                self.updateUserPurchaseData(productId: productId, productType: productType)
//                            })
//                            self.queue.addOperation(operation)
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

    internal func downloadProgress(value value: Int, totalCount: Int, indexPath: NSIndexPath) {
        if value >= 0 {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if indexPath.row < self.purchased.count {
                    let id = self.purchased[indexPath.row].uniqueId
                    if DownloaderSingleton.sharedInstance.getDownloaderState(uniqueId: id) != DownloaderSingleton.DownloaderState.Finished {
                        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? FavoriteEntranceNotDownloadedTableViewCell {
                            cell.changeProgressValue(value: value, totalCount: totalCount)
                        }
                    }
                }
            }
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
            })
        }
    }
    
    internal func downloadPaused(indexPath indexPath: NSIndexPath) {
        DownloaderSingleton.sharedInstance.removeDownloader(uniqueId: self.purchased[indexPath.row].uniqueId)
        return
    }
    

    internal func downloadImagesFinished(result result: Bool, indexPath: NSIndexPath) {
        if result == true {
            self.updateUserPurchaseData(productId: self.purchased[indexPath.row].uniqueId, productType: self.purchased[indexPath.row].type)
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if indexPath.row < self.purchased.count {
                    let id = self.purchased[indexPath.row].uniqueId
                    if DownloaderSingleton.sharedInstance.getDownloaderState(uniqueId: id) == DownloaderSingleton.DownloaderState.Finished {
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "ActionResult", messageSubType: "DownloadSuccess", type: "success", completion: nil)
                        })
                        
                        // reload purchase data
                        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                        let item = self.purchased[indexPath.row]
                        if let purchased = PurchasedModelHandler.getByProductId(productType: item.type, productId: item.uniqueId, username: username) {
                            let p = EntrancePrurchasedStructure(id: purchased.id, created: purchased.created, amount: 0, downloaded: purchased.downloadTimes, isDownloaded: purchased.isDownloaded, isDataDownloaded: purchased.isLocalDBCreated, isImagesDownloaded: purchased.isImageDownloaded)
                            
                            let qCount = EntranceQuestionModelHandler.countQuestions(entranceId: item.uniqueId)
                            self.purchased[indexPath.row] = (uniqueId: item.uniqueId, type: item.type, object: item.object, purchased: p, starred: 0, opened: 0, questionsCount: qCount)
                            
                            self.DownloadedCount.append(indexPath.row)
                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        }
                    }
                }
            }
        }
    }

    internal func downloadPackage(productId productId: String, productType: String, indexPath: NSIndexPath) {
        // Get from db if download initial data
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        if PurchasedModelHandler.isInitialDataDownloaded(productType: productType, productId: productId, username: username) == true {
            let operation = NSBlockOperation(block: {
                let downloader = DownloaderSingleton.sharedInstance.getMeDownloader(type: productType, uniqueId: productId) as! EntrancePackageDownloader
                downloader.initialize(entranceUniqueId: productId, viewController: self, vcType: "F", username: username, indexPath: indexPath)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    if downloader.fillImagesArray() == true {
                        let filemgr = NSFileManager.defaultManager()
                        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                        
                        let docsDir = dirPaths[0] as NSString
                        let newDir = docsDir.stringByAppendingPathComponent(productId)
                        
                        var isDir: ObjCBool = false
                        if filemgr.fileExistsAtPath(newDir, isDirectory: &isDir) == true {
                            if isDir {
                                
                                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? FavoriteEntranceNotDownloadedTableViewCell {
                                    
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        cell.changeToDownloadState()
                                        cell.setNeedsLayout()
                                    })
                                }
                                
                                DownloaderSingleton.sharedInstance.setDownloaderStarted(uniqueId: productId)
                                downloader.downloadPackageImages(saveDirectory: newDir)
                            }
                        }
                    }
                })
            })
            self.queue.addOperation(operation)
            
        } else {
            let operation = NSBlockOperation(block: {
                let downloader = DownloaderSingleton.sharedInstance.getMeDownloader(type: productType, uniqueId: productId) as! EntrancePackageDownloader
                downloader.initialize(entranceUniqueId: productId, viewController: self, vcType: "F", username: username, indexPath: indexPath)
                
                downloader.downloadInitialData(self.queue, completion: { (result, indexPath) in
                    if result == true {
                        let valid2 = PurchasedModelHandler.setIsLocalDBCreatedTrue(productType: productType, productId: productId, username: username)
                        
                        if valid2 == true {
                            let filemgr = NSFileManager.defaultManager()
                            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                            
                            let docsDir = dirPaths[0] as NSString
                            let newDir = docsDir.stringByAppendingPathComponent(productId)
                            
                            do {
                                try filemgr.removeItemAtPath(newDir)
                            } catch {}
                            
                            do {
                                try filemgr.createDirectoryAtPath(newDir, withIntermediateDirectories: true, attributes: nil)
                                
                                if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? FavoriteEntranceNotDownloadedTableViewCell {
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                        cell.changeToDownloadState()
                                        cell.setNeedsLayout()
                                    })
                                }
                                
                                DownloaderSingleton.sharedInstance.setDownloaderStarted(uniqueId: productId)
                                downloader.downloadPackageImages(saveDirectory: newDir)
                                
                            } catch {}
                            
                        }
                    }
                })
            })
            self.queue.addOperation(operation)
        }        
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showType == "Normal" {
            return self.purchased.count
        } else if self.showType == "Edit" {
            return self.DownloadedCount.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.showType == "Normal" {
            if self.purchased.count > indexPath.row {
                let item = self.purchased[indexPath.row]
                if item.type == "Entrance" {
                    // get purchase data
                    let purchasedData = item.purchased as! EntrancePrurchasedStructure
                    
                    if purchasedData.isDownloaded == false {
                        // get downloader state
                        if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_NOT_DOWNLOADED", forIndexPath: indexPath) as? FavoriteEntranceNotDownloadedTableViewCell {
                            cell.configureCell(entrance: item.object as! EntranceStructure, purchased: purchasedData, indexPath: indexPath)
                            
                            if DownloaderSingleton.sharedInstance.getDownloaderState(uniqueId: item.uniqueId) == DownloaderSingleton.DownloaderState.Started {
                                if let downloader = DownloaderSingleton.sharedInstance.getMeDownloader(type: item.type, uniqueId: item.uniqueId) as? EntrancePackageDownloader {
                                    downloader.registerVC(viewController: self, vcType: "F", indexPath: indexPath)
                                }
                                cell.changeToDownloadState()
                            } else {
                                cell.addGestures(viewController: self, indexPath: indexPath)
                            }
                            return cell
                        }
                        
                    } else if purchasedData.isDownloaded == true {
                        if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_DOWNLOADED", forIndexPath: indexPath) as? FavoriteEntranceDownloadedTableViewCell {
                            
                            cell.configureCell(entrance: item.object as! EntranceStructure, purchased: purchasedData, indexPath: indexPath, starCount: item.starred, openedCount: item.opened, qCount: item.questionsCount)
                            cell.addGestures(viewController: self, indexPath: indexPath)
                            return cell
                        }
                    }
                }
            }
        } else if self.showType == "Edit" {
            if indexPath.row < self.DownloadedCount.count {
                let i = self.DownloadedCount[indexPath.row]
                let item = self.purchased[i]
                if item.type == "Entrance" {
                    // get purchase data
                    let purchasedData = item.purchased as! EntrancePrurchasedStructure
                    
                    if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_DELETE", forIndexPath: indexPath) as? FavoriteEntranceDeleteTableViewCell {
                        
                        cell.configureCell(entrance: item.object as! EntranceStructure, purchased: purchasedData, indexPath: indexPath)
                        cell.deleteButton.addTarget(self, action: #selector(self.deleteButtonPressed(_:)), forControlEvents: .TouchUpInside)
                        return cell
                    }
                    
                }
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.showType == "Normal" {
            if self.purchased.count > indexPath.row {
                let item = self.purchased[indexPath.row]
                if item.type == "Entrance" {
                    // get purchase data
                    let purchasedData = item.purchased as! EntrancePrurchasedStructure
                    if purchasedData.isDownloaded == false {
                        return 170.0
                    } else if purchasedData.isDownloaded == true {
                        return 210.0
                    }
                }
            }
        } else if self.showType == "Edit" {
            return 140.0
        }
        return 0.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("\(indexPath)")
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EntranceShowVCSegue" {
            if self.selectedIndex != nil {
                if self.selectedIndex!.row < self.purchased.count {
                    let item = self.purchased[self.selectedIndex!.row]
                    if let vc = segue.destinationViewController as? EntranceShowTableViewController {
                        vc.entranceUniqueId = item.uniqueId
                        vc.entrance = item.object as! EntranceStructure
                        vc.showType = self.selectedShowType
                        
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
                        
                    }
                }
            }
        }
    }
}
