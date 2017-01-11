//
//  BasketCheckoutTableViewController.swift
//  Concough
//
//  Created by Owner on 2017-01-08.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class BasketCheckoutTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var localTableView: UITableView!
    
    private lazy var refreshConrtol: UIRefreshControl = {
        var refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید")
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
        
        // uitableview refresh control setup
        self.localTableView.addSubview(self.refreshConrtol)
        self.updateTotalCost()
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ویرایش", style: .Plain, target: self, action: nil)
        self.title = "سبد خرید شما"
        
        self.localTableView.tableFooterView = UIView()
        
        if BasketSingleton.sharedInstance.SalesCount == 0 {
            self.payButton.hidden = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Actions
    @IBAction func deleteButtonPressed(sender: UIButton) {
        // get tag from it
        let index = sender.tag
        if let sale = BasketSingleton.sharedInstance.getSaleByIndex(index: index) as? (id: Int, created: NSDate, cost: Int, target: Any, type: String) {
            
            BasketSingleton.sharedInstance.removeSaleById(viewController: self, saleId: sale.id, completion: { (count) in
                self.updateTotalCost()
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.localTableView.deleteRowsAtIndexPaths([NSIndexPath.init(forRow: index, inSection: 0)], withRowAnimation: .Fade)
                    self.localTableView.reloadData()

                    if count == 0 {
                        self.payButton.hidden = true
                    }
                })
                
            })
        }
    }
    
    @IBAction func checkoutButtonPressed(sender: UIButton) {
        BasketSingleton.sharedInstance.checkout(viewController: self) { (count, purchased) in
            if let localPurchased = purchased {
                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ActionResult", messageSubType: "PurchasedSuccess", completion: {
                    
                })
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.localTableView.reloadData()

                self.updateTotalCost()
                if count == 0 {
                    self.payButton.hidden = true
                }
            })
        }
    }
    
    // Functions
    @objc private func refreshTableView(refreshControl: UIRefreshControl) {
        self.refreshingBasket()
    }

    private func refreshingBasket() {
        BasketSingleton.sharedInstance.loadBasketItems(viewController: self) { (count) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.refreshConrtol.endRefreshing()
                self.localTableView.reloadData()
                
                if count == 0 {
                    self.payButton.hidden = true
                }
            })
        }
    }
    
    private func updateTotalCost() {
        print("total cost: \(BasketSingleton.sharedInstance.TotalCost)")
        self.totalCostLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(BasketSingleton.sharedInstance.TotalCost)! + " تومان"
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print ("basket count: \(BasketSingleton.sharedInstance.SalesCount)")
        return BasketSingleton.sharedInstance.SalesCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let sale = BasketSingleton.sharedInstance.getSaleByIndex(index: indexPath.row) as? (id: Int, created: NSDate, cost: Int, target: Any, type: String) {
            print("data exist")
            
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
        return 145.0
    }
    
    // MARK: - DZN
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "سبد کالای شما خالیست"
        let attributes = [NSFontAttributeName: UIFont(name: "IRANYekanMobile-Bold", size: 16)!,
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
