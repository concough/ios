//
//  EntranceMultiDetailTableViewController.swift
//  Concough
//
//  Created by Owner on 2018-05-21.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

class EntranceMultiDetailTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, ProductBuyDelegate {

    internal var uniqueId: String!
    internal var target: JSON!
    internal var actType: String!
    
    private var selectedActivityIndex = -1
    private var retryCounter = 0
    private var entranceMultiSale: EntranceMultiSaleStructure?
    private var entrances: [String: EntranceStructure] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "بسته آزمون"
        
        self.tableView.estimatedRowHeight = 200.0
        self.tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.entranceMultiSale = nil
        self.tableView.reloadData()
        self.getEntranceMultiSaleData()
        
        if let entrances = self.target["entrances"].array {
            for ent in entrances {
                let organization = ent["organization"]["title"].stringValue
                let entrance_type = ent["entrance_type"]["title"].stringValue
                let entrance_set = ent["entrance_set"]["title"].stringValue
                let entrance_set_id = ent["entrance_set"]["id"].intValue
                let entrance_group = ent["entrance_set"]["group"]["title"].stringValue
                let extra_data = JSON(data: ent["extra_data"].stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
//                let booklet_count = ent["booklets_count"].intValue
//                let duration = ent["duration"].intValue
                let booklet_count = 0
                let duration = 0
                let year = ent["year"].intValue
                let month = ent["month"].intValue
                let last_published_str = ent["last_published"].stringValue
                let entrance_unique_id = ent["unique_key"].stringValue
                
                let last_published = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(last_published_str)
                
                let entranceS = EntranceStructure(entranceTypeTitle: entrance_type, entranceOrgTitle: organization, entranceGroupTitle: entrance_group, entranceSetTitle: entrance_set, entranceSetId: entrance_set_id, entranceExtraData: extra_data, entranceBookletCounts: booklet_count, entranceYear: year, entranceMonth: month, entranceDuration: duration, entranceUniqueId: entrance_unique_id, entranceLastPublished: last_published)
                
                self.entrances.updateValue(entranceS, forKey: entrance_unique_id)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Functions
    private func getEntranceMultiSaleData() {
            ProductRestAPIClass.getEntranceMultiSaleData(uniqueId: self.uniqueId, completion: { (data, error) in
                
                if error != HTTPErrorType.Success {
                    if error == HTTPErrorType.Refresh {
                        self.getEntranceMultiSaleData()
                    } else {
                        if self.retryCounter < CONNECTION_MAX_RETRY {
                            self.retryCounter += 1
                            self.getEntranceMultiSaleData()
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
                                
                                let sale = localData["sale_data"]
                                let discount = sale["discount"].intValue
                                let total_cost = sale["sale_record"]["total_cost"].intValue
                                let cost = sale["sale_record"]["cost"].intValue
                                
                                self.entranceMultiSale = EntranceMultiSaleStructure(discount: discount, totalCost: total_cost, payCost: cost)
                                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? EMDInitailTableViewCell {
                                    
                                    cell.configureCosts(saleStruct: self.entranceMultiSale!)
                                    cell.disableBuy(state: false)
                                }
                                
                            case "Error":
                                if let errorType = localData["error_type"].string {
                                    switch errorType {
                                    case "EmptyArray":
                                        break
                                    case "EntranceNotExist":
                                        // No Entrance data exist --> pop this
                                        NSOperationQueue.mainQueue().addOperationWithBlock({
                                            AlertClass.showAlertMessage(viewController: self, messageType: "ErrorResult", messageSubType: "NotExist", type: "error", completion: {
                                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                                    self.dismissViewControllerAnimated(true, completion: nil)
                                                })
                                            })
                                        })
                                        
                                    default:
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
                        self.getEntranceMultiSaleData()
                } else {
                    self.retryCounter = 0
                    
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
    
    private func showBuyDialog(balance balance: Int, cost: Int, canBuy: Bool) {
        if let rect = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? EMDInitailTableViewCell {
            
            let popover = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ENTRANCE_BUY_VC") as! EntranceBuyViewController
            popover.modalPresentationStyle = .Popover
            popover.popoverPresentationController?.delegate = self
            popover.popoverPresentationController?.sourceView = rect.buyButton
            popover.popoverPresentationController?.sourceRect = rect.buyButton.bounds
            popover.popoverPresentationController?.permittedArrowDirections = .Any
            popover.preferredContentSize = CGSize(width: self.view.layer.bounds.width, height: 210)
            
            popover.balance = balance
            popover.cost = cost
            popover.canBuy = canBuy
            popover.productType = "EntranceMulti"
            popover.uniqueId = self.uniqueId
            popover.productBuyDelegate = self
            
            self.presentViewController(popover, animated: true, completion: nil)
        }
    }
    
    private func createWallet() {
        WalletRestAPIClass.info(completion: { (data, error) in
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.createWallet()
                    
                } else {
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        self.createWallet()
                    } else {
                        self.retryCounter = 0
                        
                        AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                        
                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EMDInitailTableViewCell {
                            cell.disableBuy(state: false)
                        }
                        
                    }
                }
            } else {
                self.retryCounter = 0
                
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EMDInitailTableViewCell {
                    cell.disableBuy(state: false)
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
                                let cost: Int = (self.entranceMultiSale?.payCost!)!
                                
                                var canBuy = true
                                if cost > walletInfo.cash {
                                    canBuy = false
                                }
                                
                                self.showBuyDialog(balance: walletInfo.cash, cost: cost, canBuy: canBuy)
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
                self.createWallet()
            } else {
                self.retryCounter = 0
                
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EMDInitailTableViewCell {
                    cell.disableBuy(state: false)
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

    // MARK: - Delegates
    func ProductBuyedResult(data data: JSON, productId: String, productType: String) {
        let cash = data["wallet_cash"].intValue
        var updated = NSDate()
        if let m = data["wallet_updated"].string {
            updated = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(m)!
        }
        
        UserDefaultsSingleton.sharedInstance.setWalletInfo(cash: cash, updated: updated)
        
        var purchasedTemp: [Int] = []
        let username = UserDefaultsSingleton.sharedInstance.getUsername()
        
        if let purchased = data["purchased"].array {
            for item in purchased {
                let purchaseId = item["purchase_id"].intValue
                let downloaded = item["downloaded"].intValue
                let product_id = item["product_id"].stringValue
                
                let purchased_time_str = item["purchase_time"].stringValue
                let purchasedTime = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(purchased_time_str)!
                
                if let entrance = self.entrances[product_id] {
                    if EntranceModelHandler.add(entrance: entrance, username: username!) == true {
                        if PurchasedModelHandler.add(id: purchaseId, username: username!, isDownloaded: false, downloadTimes: downloaded, isImageDownlaoded: false, purchaseType: "Entrance", purchaseUniqueId: entrance.entranceUniqueId!, created: purchasedTime) == false {
                            
                            // rollback entrance insert
                            EntranceModelHandler.removeById(id: entrance.entranceUniqueId!, username: username!)
                        } else {
                            purchasedTemp.append(purchaseId)
                        }
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
    
    // MARK: - Actions
    @IBAction func buyButtonPressed(sender: UIButton) {
        //        self.showBuyDialog(balance: 500, cost: 100, canBuy: false)
        //        return
        
        if UserDefaultsSingleton.sharedInstance.hasWallet() {
            let walletInfo = UserDefaultsSingleton.sharedInstance.getWalletInfo()!
            let cost: Int = (self.entranceMultiSale?.payCost!)!
            
            var canBuy = true
            if cost > walletInfo.cash {
                canBuy = false
            }
            
            self.showBuyDialog(balance: walletInfo.cash, cost: cost, canBuy: canBuy)
            
        } else {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EMDInitailTableViewCell {
                cell.disableBuyButton()
            }
            
            self.createWallet()
        }
        
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.target["entrances"].array?.count {
            return count + 1
        }
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_MULTI_INITIAL", forIndexPath: indexPath) as? EMDInitailTableViewCell {

                var count: Int = 0
                if let c = self.target["entrances"].array?.count {
                    count = c
                }
                
                if let sale = self.entranceMultiSale {
                    cell.configureCell(firstEntrance: self.target["entrances"][0], totalCost: sale.totalCost!, payCost: sale.payCost!, entrancesCount: count, disabelBuy: false, indexPath: indexPath)
                } else {
                    cell.configureCell(firstEntrance: self.target["entrances"][0], totalCost: 0, payCost: 0, entrancesCount: count, disabelBuy: true, indexPath: indexPath)
                }
                cell.buyButton.addTarget(self, action: #selector(self.buyButtonPressed(_:)), forControlEvents: .TouchUpInside)
                
                return cell
            }
        } else {
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_MULTI_ITEM", forIndexPath: indexPath) as? EMDEntranceItemTableViewCell {
                cell.configureCell(entrance: self.target["entrances"][indexPath.row - 1])
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > 0 {
            
            self.selectedActivityIndex = indexPath.row
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("EntranceDetailVCSegue", sender: self)
            }

        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EntranceDetailVCSegue" {
            if let vc = segue.destinationViewController as? EntranceDetailTableViewController {
                // get entrance unique id
                let targ = self.target["entrances"][self.selectedActivityIndex - 1]
                let uniqueId = targ["unique_key"].stringValue
                vc.entranceUniqueId = uniqueId
            }
        }
    }
}
