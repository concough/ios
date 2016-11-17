//
//  HomeTableViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-09.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HomeTableViewController: UITableViewController {

    var baseUrl = "http://192.168.1.15:8000/api/"
    var apiVersion = "v1"
    
    var moreFeedExist = true
    var activityList = [ConcoughActivity]()
    var localImageStorage = Dictionary<String, Dictionary<Int, NSData>>()
    
    let queue = NSOperationQueue()
    var oldOperation: NSBlockOperation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Initialization
        self.localImageStorage.updateValue(Dictionary<Int, NSData>(), forKey: "eset")
        self.queue.maxConcurrentOperationCount = 1  // make serial queue
        
        // uitableview refresh control setup
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید")
        }
        self.refreshControl?.addTarget(self, action: #selector(HomeTableViewController.refreshTableView(_:)), forControlEvents: .ValueChanged)
        
        loadFeeds(next: nil)
    }

    func refreshTableView(refreshControl_: UIRefreshControl) {
        let operation = NSBlockOperation() {
            self.loadFeeds(next: nil)
        }
        
        queue.addOperation(operation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activityList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        // Configure the cell...
        //cell.textLabel?.text = self.activityList[indexPath.row].activityType

        NSLog("drawing tableview cell index: \(indexPath.row)")
        
        let activity = activityList[indexPath.row] as ConcoughActivity
        //guard let activity = activityList[indexPath.row] else {
        //    return UITableViewCell()
        //}
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeZone = NSTimeZone(name: "Asia/tehran")
        dateFormatter.locale = NSLocale(localeIdentifier: "fa_IR")
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .NoStyle
        numberFormatter.locale = NSLocale(localeIdentifier: "fa")
        
        switch activity.activityType {
            case "ENTRANCE_CREATE":
                let target = activity.target

                let cell = self.tableView.dequeueReusableCellWithIdentifier(activity.activityType, forIndexPath: indexPath) as? EntranceCreateTableViewCell
                cell?.entranceTitleUILabel.text = "\(target["entrance_type"]["title"].stringValue) \(target["organization"]["title"].stringValue) "
                cell?.entranceSetUILabel.text = "\(target["entrance_set"]["title"].stringValue) \(target["entrance_set"]["group"]["title"].stringValue)"
                cell?.entranceYearUILabel.text = " \(numberFormatter.stringFromNumber(target["year"].numberValue)!) "
                cell?.entranceUpdateTimeUILabel.text = "\(dateFormatter.stringFromDate(activity.created))"
            
                let imageID = target["entrance_set"]["id"].intValue
                //self.setImageForCell("eset", imageId: imageID, indexPath: indexPath, activityType: activity.activityType)
                self.downloadImageForCell("eset", imageId: imageID, indexPath: indexPath, activityType: activity.activityType)
                
                return cell!
            
            case "ENTRANCE_UPDATE":
                let target = activity.target

                let cell = self.tableView.dequeueReusableCellWithIdentifier(activity.activityType, forIndexPath: indexPath) as? EntranceUpdateTableViewCell
                cell?.entranceTitleUILabel.text = "کنکور" + "\(target["enrtance_type"]["title"].stringValue) \(target["organization"]["title"].stringValue) \(numberFormatter.stringFromNumber(target["year"].numberValue)!)"
                cell?.entranceSetUILabel.text = "\(target["entrance_set"]["title"].stringValue) \(target["entrance_set"]["group"]["title"].stringValue)"
                cell?.entranceUpdateTimeUILabel.text = "\(dateFormatter.stringFromDate(activity.created))"
                
                let imageID = target["entrance_set"]["id"].intValue
                //self.setImageForCell("eset", imageId: imageID, indexPath: indexPath, activityType: activity.activityType)
                self.downloadImageForCell("eset", imageId: imageID, indexPath: indexPath, activityType: activity.activityType)
                
                return cell!
            
            default:
                let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
                return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let activity = activityList[indexPath.row] as ConcoughActivity
        //guard let activity = activityList[indexPath.row] as ConcoughActivity else {
        //    return 0.0
        //}

        switch activity.activityType {
            case "ENTRANCE_CREATE": return 220.0
            case "ENTRANCE_UPDATE": return 100.0
        default: return 0.0
        }
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRowsInSection(lastSectionIndex) - 1
        
        if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
            // must load more
            if self.moreFeedExist == true {
                // get last item of activity feed
                let activity = self.activityList[lastRowIndex]
                let last_time = activity.createdStr
                //print("\(indexPath) - \(last_time)")
                
                loadFeeds(next: last_time)
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // Private Functions
    
    private func loadFeeds(next next: String?) {
        let className = "activities"
        var functionName = ""
        
        if let nextStr = next {
            if nextStr.characters.count > 0 {
                functionName = "next/\(nextStr)/"
            }
        }
        
        let fullPath = "\(self.baseUrl)\(self.apiVersion)/\(className)/\(functionName)"
        //print(fullPath)
        
        Alamofire.request(.GET, fullPath).validate().responseJSON { response in
            
            //debugPrint(response)
            switch response.result {
            case .Success:
                if let nextStr = next where nextStr != "" {
                } else {
                    self.activityList.removeAll()
                }
                self.refreshControl?.endRefreshing()


                if let json = response.result.value {
                    let jsonData = JSON(json)
                    
                    if jsonData.count > 0 {
                        
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        formatter.timeZone = NSTimeZone(name: "UTS")
                        
                        for (_, item) in jsonData {
                            let cStr = item["created"].stringValue
                            let aType = item["activity_type"].stringValue
                            let t = item["target"]
                            
                            let c:NSDate = formatter.dateFromString(cStr)!
                            
                            let con = ConcoughActivity(created: c, createdStr: cStr, activityType: aType, target: t)
                            self.activityList.append(con)
                        }
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                            self.tableView.reloadData()
                        }
                        
                    } else { // no more feeds
                        self.moreFeedExist = false
                        
                    }
                    
                }
            case .Failure(let error):
                //print(error)
                break
            }
        }
        
    }

    private func setImageForCell(type: String, imageId: Int, indexPath: NSIndexPath, activityType: String) {
        let operation = NSBlockOperation() {
            print("operation index:\(indexPath.row)")
            
            guard let data = self.localImageStorage[type]![imageId] else {
                self.downloadImageForCell(type, imageId: imageId, indexPath: indexPath, activityType: activityType)
                return
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                
                switch activityType {
                case "ENTRANCE_CREATE":
                    let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! EntranceCreateTableViewCell
                    cell.entranceImage.image = UIImage(data: data)
                    cell.setNeedsDisplay()
                case "ENRANCE_UPDATE":
                    let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! EntranceUpdateTableViewCell
                    cell.entranceImage.image = UIImage(data: data)
                    cell.setNeedsDisplay()
                default:
                    break
                    
                }
            }

        }
        
        queue.addOperation(operation)
    }
    
    private func downloadImageForCell(type: String, imageId: Int, indexPath: NSIndexPath, activityType: String) {
        let className = "media"
        let functionName = "\(type)/\(imageId)"
        let fullPath = "\(self.baseUrl)\(self.apiVersion)/\(className)/\(functionName)"
        
        Alamofire.request(.GET ,fullPath).responseData() { response in
            print("download index:\(indexPath.row)")
            
            switch response.result {
            case .Success:
                guard let data = response.result.value else {
                    return
                }
                //self.localImageStorage[type]!.updateValue(data, forKey: imageId)
                
                NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                    
                    switch activityType {
                        case "ENTRANCE_CREATE":
                            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? EntranceCreateTableViewCell
                            cell?.entranceImage.image = UIImage(data: data)
                            //cell?.setNeedsDisplay()
                        case "ENTRANCE_UPDATE":
                            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? EntranceUpdateTableViewCell
                            cell?.entranceImage.image = UIImage(data: data)
                            //cell?.setNeedsDisplay()
                        default:
                            break
                        
                    }
                }
                
            case .Failure(let error):
                //print(error)
                break
            }
        
        }
    }
}
