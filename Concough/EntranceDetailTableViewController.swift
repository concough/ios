//
//  EntranceDetailTableViewController.swift
//  Concough
//
//  Created by Owner on 2016-12-20.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class EntranceDetailTableViewController: UITableViewController {

    internal var entranceActivity: ConcoughActivity!
    
    private var entranceInfo: [(title: String, image: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Initialization
        self.title = "کنکور"
        
        self.entranceInfo.append((title: "۱۳۹۴", image: "Calendar"))
        self.entranceInfo.append((title: "۲ دفترچه", image: "PageOverview"))
        self.entranceInfo.append((title: "۲۴۰ دقیقه", image: "Timer"))
        
        print(entranceActivity.target)        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return 2
        default:
            break
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("INITIAL_SECTION", forIndexPath: indexPath) as? EDInitialSectionTableViewCell {
                    cell.configureCell(title: "سراسری دولتی", subTitle: "ریاضی و فنی (ریاضی و فنی)")
                    return cell
                }
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("HEADER_SECTION", forIndexPath: indexPath) as? EDHeaderSectionTableViewCell {
                    cell.configureCell(title: "اطلاعات آزمون")
                    return cell
                }
            default:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("INFORMATION_SECTION", forIndexPath: indexPath) as? EDInformationSectionTableViewCell {
                    
                    cell.configureCell(data: self.entranceInfo)
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
            return 170.0
        case 1:
            switch indexPath.row {
            case 0:
                return 35.0
            default:
                return 80.0
            }
        default:
            break
        }
        return 0.0
    }
    
    // MARK: - Navigation


}
