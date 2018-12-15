//
//  TestViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-26.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import Alamofire
import SwiftMessages
import Charts

class TestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var barChartView: HorizontalBarChartView!
    var months: [String]!
    
    private var tableView1: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationUserDidTakeScreenshotNotification, object: nil, queue: mainQueue) { (notification) in
        }
        
        months = ["کل", "درست", "نادرست", "بی جواب"]
        let unitsSold = [20.0, 10.0, 6.0, 4.0]
        self.setChart(months, values: unitsSold)
        
        self.tableView1 = UITableView(frame: CGRect(x: 8.0, y: 8.0, width: self.view.bounds.size.width - 8.0 * 10, height: 180.0), style: UITableViewStyle.Plain)
        self.tableView1?.delegate = self
        self.tableView1?.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "row \(indexPath.row)"
        return cell
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        
    }
    
    @IBAction func testOauthToken(sender: UIButton) {
        var headers: [String: String] = ["Content-Type": "application/x-www-form-urlencoded",
                                         "Accept": "application/json"]
        let parameters: [String: String] = ["grant_type": "password",
                                            "username": "abolfazlbeh",
                                            "password": "abolfazl#102938"]
        
        let clientId = "vKREqBOlXXVZNqWdAGTYio8W6Rhe4SpTAtCZb6Ra"
        let clientPassword = "uAnxNKjqK1b5i0Y3SYpCWnyjORQR14JIpOHchse0alsYpqIVrpy2C9Fu095anIrM6v3yft0pDjO8eGu5G8q5UDs7WjMEqpHUVwg9x6QHrIlW6NR2DZiUJD0njCaqkBaL"
        
        let clientData: NSData = "\(clientId):\(clientPassword)".dataUsingEncoding(NSUTF8StringEncoding)!
        let client64String = clientData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0))
        
        let login_url = "http://192.168.1.15:8000/api/o/token/"
        
        
        headers["Authorization"] = "Basic \(client64String)"
        Alamofire.request(.POST, login_url, parameters: parameters, encoding: .URL, headers: headers).responseData {
            response in
            
            debugPrint(response)
        }
    }
    
    @IBAction func clearKeyChainCache(sender: UIButton) {
//        if KeyChainAccessProxy.clearAllValue() {
//            print ("All KeyChain Value cleared")
//        }
//        if UserDefaultsSingleton.sharedInstance.clearAll() {
//            print ("All UserDefaults Value cleared")
//        }
    
        UserDefaultsSingleton.sharedInstance.clearWallet()
        
//    SnapshotCounterHandler.deleteAllValue()
    }
    
    @IBAction func deleteAllLessonExamPressed(sender: UIButton) {
        EntranceLessonExamModelHandler.deleteAllExams()
        EntranceQuestionExamStatModelHandler.deleteAllStats()
    }
    
    @IBAction func showMessaeg(sender: UIButton) {
//        let view = MessageView.viewFromNib(layout: .MessageViewIOS8)
//        var config = SwiftMessages.Config()
//        config.presentationStyle = .Top
//        config.preferredStatusBarStyle = UIStatusBarStyle.Default
//        //config.presentationContext = .Window(windowLevel: UIWindowLevel)
//        config.duration = .Seconds(seconds: 3)
//        config.interactiveHide = true
//        
//        view.configureTheme(.Info)
//        view.configureDropShadow()
//        view.configureContent(title: "تست", body: nil, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
//
//        view.titleLabel?.font = UIFont()
//        SwiftMessages.show(config: config, view: view)
        
        let actionSheet = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .ActionSheet)
        
//        let view = UIView(frame: CGRect(x: 8.0, y: 8.0, width: actionSheet.view.bounds.size.width - 8.0 * 4.5, height: 120.0))
//        view.backgroundColor = UIColor.greenColor()
        actionSheet.view.addSubview(self.tableView1!)
        
        actionSheet.addAction(UIAlertAction(title: "Add to a Playlist", style: .Default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Create Playlist", style: .Default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Remove from this Playlist", style: .Default, handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)
    }
        
    func setChart(dataPoints: [String], values: [Double]) {
        let font = UIFont(name: "IRANSansMobile", size: 12)!
        
        self.barChartView.descriptionText = ""
        self.barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 1.0)
        self.barChartView.drawGridBackgroundEnabled = false
        self.barChartView.gridBackgroundColor = UIColor.clearColor()
        self.barChartView.drawBordersEnabled = false
        self.barChartView.getAxis(ChartYAxis.AxisDependency.Left).drawAxisLineEnabled = false
        self.barChartView.getAxis(ChartYAxis.AxisDependency.Right).drawAxisLineEnabled = false
        self.barChartView.getAxis(ChartYAxis.AxisDependency.Left).drawGridLinesEnabled = false
        self.barChartView.getAxis(ChartYAxis.AxisDependency.Right).drawGridLinesEnabled = false
        self.barChartView.getAxis(ChartYAxis.AxisDependency.Right).drawLabelsEnabled = false
        self.barChartView.getAxis(ChartYAxis.AxisDependency.Left).drawLabelsEnabled = false
        self.barChartView.xAxis.labelPosition = .Bottom
        self.barChartView.xAxis.drawGridLinesEnabled = false
        self.barChartView.xAxis.labelFont = font
        self.barChartView.legend.enabled = false
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        chartDataSet.valueFormatter = FormatterSingleton.sharedInstance.NumberFormatter
        chartDataSet.valueFont = font
        chartDataSet.colors = [UIColor.blackColor(), UIColor.darkGrayColor(), UIColor.grayColor(), UIColor.lightGrayColor()]
        let chartData = BarChartData(xVals: dataPoints, dataSets: [chartDataSet])
        self.barChartView.data = chartData
    }
    
    
}
