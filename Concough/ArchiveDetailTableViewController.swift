//
//  ArchiveDetailTableViewController.swift
//  Concough
//
//  Created by Owner on 2016-12-26.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

class ArchiveDetailTableViewController: UITableViewController {

    internal var esetDetail: ArchiveEsetDetailStructure!
    
    private var entrances: [ArchiveEntranceStructure] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = self.esetDetail.entranceTypeTitle
        self.getEntrances()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Functions
    private func getEntrances() {
        
        if let setId = self.esetDetail.entranceEset?.id {
            ArchiveRestAPIClass.getEntrances(entranceSetId: setId, completion: { (data, error) in
                if error != HTTPErrorType.Success {
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
                } else {
                    if let localData = data {
                        if let status = localData["status"].string {
                            switch status {
                            case "OK":
                                // get record
                                let record = localData["record"]
                                print(record)
                                
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
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.getEntrances()
                            })
                        })
                    default:
                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                    }
                }
            }
        }
        
        let dict = "{\"زبان\": \"انگلیسی\", \"دین\": \"اسلام\"}"
        var e = ArchiveEntranceStructure()
        e.buyCount = 32
        e.extraData = JSON(data: dict.dataUsingEncoding(NSUTF8StringEncoding)!)
        e.lastPablished = NSDate()
        e.organization = "دولتی"
        e.year = 1394
        
        var e2 = ArchiveEntranceStructure()
        e2.buyCount = 45
        e2.extraData = JSON(data: dict.dataUsingEncoding(NSUTF8StringEncoding)!)
        e2.lastPablished = NSDate()
        e2.organization = "آزاد"
        e2.year = 1393

        var e3 = ArchiveEntranceStructure()
        e3.buyCount = 1234
        e3.extraData = JSON(data: dict.dataUsingEncoding(NSUTF8StringEncoding)!)
        e3.lastPablished = NSDate()
        e3.organization = "دولتی"
        e3.year = 1390

        var e4 = ArchiveEntranceStructure()
        e4.buyCount = 8
        e4.extraData = JSON(data: dict.dataUsingEncoding(NSUTF8StringEncoding)!)
        e4.lastPablished = NSDate()
        e4.organization = "آزاد"
        e4.year = 1390
        
        self.entrances.append(e)
        self.entrances.append(e2)
        self.entrances.append(e3)
        self.entrances.append(e4)
        
        self.tableView.reloadData()
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
            return 110.0
        case 1:
            return 70.0
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
    
    // MARK: - Navigation
}
