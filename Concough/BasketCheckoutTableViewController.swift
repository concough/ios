//
//  BasketCheckoutTableViewController.swift
//  Concough
//
//  Created by Owner on 2017-01-08.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MBProgressHUD

class BasketCheckoutTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var localTableView: UITableView!
    
    internal var loading: MBProgressHUD?
    internal var filemgr: NSFileManager?
    
    private var retryCounter = 0
    
    private lazy var refreshConrtol: UIRefreshControl = {
        var refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید", attributes: [NSFontAttributeName: UIFont(name: "IRANSansMobile-UltraLight", size: 12)!])
        refreshControl.addTarget(self, action: #selector(self.refreshTableView(_:)), forControlEvents: .ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // UI customization
        
        // Initialization
        self.localTableView.emptyDataSetSource = self
        self.localTableView.emptyDataSetDelegate = self
        self.localTableView.tableFooterView = UIView()
        
        self.updateTotalCost()
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ویرایش", style: .Plain, target: self, action: nil)
        self.title = "سبد خرید شما"
        
        self.localTableView.tableFooterView = UIView()
        
        if BasketSingleton.sharedInstance.SalesCount == 0 {
            self.payButton.hidden = true
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(self.refreshButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(BasketCheckoutTableViewController.displayLaunchDetails),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // uitableview refresh control setup
        self.localTableView.addSubview(self.refreshConrtol)
        
        self.displayLaunchDetails()
        // TODO: verify request
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Actions
    func displayLaunchDetails() {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            
            if var path = appDelegate.path {
                appDelegate.path = nil
                
                if path.trim() != "" {
                    if path.trim()!.hasPrefix("/") {
                        path = path.trim()!.substringFromIndex(path.startIndex.advancedBy(1))
                        let components = path.trim()?.componentsSeparatedByString("/")
                        
                        if components![0] == "pay" {
                            if components![1] == "success" {
                                self.verifyCheckout()
                            } else if components![1] == "error" {
                                AlertClass.showAlertMessage(viewController: self, messageType: "BasketResult", messageSubType: "CheckoutError", type: "error", completion: nil)
                            }
                        }
                    }
                }
            } else {
                self.verifyCheckout()
            }
        }
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        self.refreshingBasket()
    }
    
    @IBAction func deleteButtonPressed(sender: UIButton) {
        // get tag from it
        let index = sender.tag
        if let sale = BasketSingleton.sharedInstance.getSaleByIndex(index: index) as? (id: Int, created: NSDate, cost: Int, target: Any, type: String) {
            
            BasketSingleton.sharedInstance.removeSaleById(viewController: self, saleId: sale.id, completion: { (count) in
                self.updateTotalCost()
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.localTableView.deleteRowsAtIndexPaths([NSIndexPath.init(forRow: index, inSection: 0)], withRowAnimation: .Fade)
                    
                    AlertClass.showTopMessage(viewController: self, messageType: "ActionResult", messageSubType: "BasketDeleteSuccess", type: "success", completion: nil)
                    
                    self.localTableView.reloadData()

                    if count == 0 {
                        self.payButton.hidden = true
                    }
                })
                
                }, failure: {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.localTableView.reloadData()
                    })
            })
        }
    }
    

    @IBAction func checkoutButtonPressed(sender: UIButton) {
        BasketSingleton.sharedInstance.checkout(viewController: self, completion: {(count, purchased) in
            self.checkoutCompleted(count, purchased: purchased)

        }, redirectCompletion: { (url, authority) in
            if let nsurl = NSURL(string: url) {
                UIApplication.sharedApplication().openURL(nsurl)
            }
        })
        
    }
    
    // Functions
    private func checkoutCompleted(count: Int, purchased: [Int: (Int, Int, NSDate)]?) {
        if let localPurchased = purchased {
            AlertClass.showAlertMessage(viewController: self, messageType: "ActionResult", messageSubType: "PurchasedSuccess", type: "success", completion: {
                self.tabBarController?.tabBar.items?[2].badgeValue = "\(localPurchased.count)"
            })
            
            var purchasedTemp: [Int] = []
            for p in localPurchased {
                purchasedTemp.append(p.1.0)
            }
            self.downloadImages(purchasedTemp)
            //                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ActionResult", messageSubType: "PurchasedSuccess", completion: {
            //                    self.tabBarController?.tabBar.items?[2].badgeValue = "\(localPurchased.count)"
            //                })
        }
        
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.localTableView.reloadData()
            
            self.updateTotalCost()
            if count == 0 {
                self.payButton.hidden = true
            }
        })

    }
    
    private func verifyCheckout() {
        BasketSingleton.sharedInstance.verifyCheckout(viewController: self) { (count, purchased) in
            self.checkoutCompleted(count, purchased: purchased)
        }
    }
    
    @objc private func refreshTableView(refreshControl: UIRefreshControl) {
        self.refreshConrtol.endRefreshing()
        self.refreshingBasket()
    }

    private func downloadImages(ids: [Int]) {
        self.filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        let newDir = docsDir.stringByAppendingPathComponent("images")
        
        let username: String = UserDefaultsSingleton.sharedInstance.getUsername()!
        let purchased = PurchasedModelHandler.getAllPurchasedIn(username: username, ids: ids)
        for p in purchased {
            if p.productType == "Entrance" {
                if let entrance = EntranceModelHandler.getByUsernameAndId(id: p.productUniqueId, username: username) {
                    downloadEsetImage(esetId: entrance.setId, rootDirectory: newDir)
                }
            }
        }
    }
    
    private func downloadEsetImage(esetId esetId: Int, rootDirectory: String) {
        
        MediaRestAPIClass.downloadEsetImageLocal(esetId, completion: {
            fullPath, data, error in
            
            if error != .Success {
                if error == HTTPErrorType.Refresh {
                    self.downloadEsetImage(esetId: esetId, rootDirectory: rootDirectory)
                } else {
//                    print("error in downloaing image from \(fullPath!)")
                }
            } else {
                if let myData = data {
                    let esetDir = (rootDirectory as NSString).stringByAppendingPathComponent("eset")
                    
                    do {
                        if self.filemgr?.fileExistsAtPath(esetDir) == false {
                            try self.filemgr?.createDirectoryAtPath(esetDir, withIntermediateDirectories: true, attributes: nil)
                        }
                        
                        let filePath = (esetDir as NSString).stringByAppendingPathComponent(String(esetId))
                        
                        if self.filemgr?.fileExistsAtPath(filePath) == true {
                            try self.filemgr?.removeItemAtPath(filePath)
                        }
                        self.filemgr?.createFileAtPath(filePath, contents: myData, attributes: nil)
                        
                        
                    } catch {
                        
                    }
                }
            }
            }, failure: { (error) in
        })
        
    }
    
    private func refreshingBasket() {
        BasketSingleton.sharedInstance.loadBasketItems(viewController: self) { (count) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.localTableView.reloadData()
                
                self.updateTotalCost()
                if count == 0 {
                    self.payButton.hidden = true
                } else {
                    self.payButton.hidden = false
                }
                
            })
        }
    }
    
    private func updateTotalCost() {
        //print("total cost: \(BasketSingleton.sharedInstance.TotalCost)")
        self.totalCostLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(BasketSingleton.sharedInstance.TotalCost)! + " تومان"
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print ("basket count: \(BasketSingleton.sharedInstance.SalesCount)")
        return BasketSingleton.sharedInstance.SalesCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let sale = BasketSingleton.sharedInstance.getSaleByIndex(index: indexPath.row) as? (id: Int, created: NSDate, cost: Int, target: Any, type: String) {
            
            if sale.type == "Entrance" {
                if let cell = tableView.dequeueReusableCellWithIdentifier("ENTRANCE_SECTION", forIndexPath: indexPath) as? BasketEntranceTableViewCell {
                    
                    cell.configureCell(entrance: (sale.target as? EntranceStructure)!, cost: sale.cost, indexPath: indexPath)
                    cell.deleteButton.tag = indexPath.row
                    cell.deleteButton.addTarget(self, action: #selector(self.deleteButtonPressed(_:)), forControlEvents: .TouchUpInside)
                    
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160.0
    }
    
    // MARK: - DZN
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "سبد کالای شما خالیست"
        let attributes = [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 16)!,
                          NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage(named: "Shopping_Cart_50")
        return image
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        self.refreshingBasket()
    }
    
    
    // MARK: - Navigation


}
