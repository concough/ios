//
//  EntranceLessonHeaderTestTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-04-01.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import Charts

class EntranceLessonHeaderTestTableViewCell: UITableViewCell {
    @IBOutlet weak var testCountLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var newTestButton: UIButton!
    @IBOutlet weak var detailStatButton: UIButton!
    @IBOutlet weak var statContainerView: PieChartView!
    
    
    private var viewController: UIViewController!
    private var vcType: String!
    private var lessonTitle: String!
    private var lessonOrder: Int!
    private var bookletOrder: Int!
    
    private var examCount: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        
        // Initialization code
//        self.statContainerView.layer.borderColor = self.newTestButton.titleColorForState(.Normal)?.CGColor
//        self.statContainerView.layer.borderWidth = 1.0
        self.statContainerView.transparentCircleRadiusPercent = 1
        self.statContainerView.holeRadiusPercent = 0.4
        self.statContainerView.transparentCircleColor = UIColor.clearColor()
        self.statContainerView.descriptionText = ""
        self.statContainerView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        self.statContainerView.legend.enabled = false
        self.newTestButton.layer.borderColor = self.newTestButton.titleColorForState(.Normal)?.CGColor
        self.newTestButton.layer.borderWidth = 1.5
        self.newTestButton.layer.cornerRadius = self.newTestButton.frame.size.height / 2.0
        self.newTestButton.layer.masksToBounds = true
        
        self.newTestButton.addTarget(self, action: #selector(self.newTestPressed(_:)), forControlEvents: .TouchUpInside)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
    }
    
    internal func configureCell(viewController viewController: UIViewController, vcType: String, examCount: Int, examAverage: Double, lastExam: EntranceLessonExamModel?, lessonTitle: String, lessonOrder: Int, bookletOrder: Int) {
        self.viewController = viewController
        self.vcType = vcType
        self.lessonTitle = lessonTitle
        self.lessonOrder = lessonOrder
        self.bookletOrder = bookletOrder
        
        let y = Double(round((round((examAverage * 10000)) / 100) * 10) / 10)
        self.averageLabel.text = "\(FormatterSingleton.sharedInstance.DecimalFormatter.stringFromNumber(y)!) %"
        self.testCountLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(examCount)!)"
        
        self.examCount = examCount
        if examCount == 0 {
            self.statContainerView.userInteractionEnabled = false
            self.statContainerView.centerAttributedText = NSAttributedString(string: "بدون\nسنجش", attributes: [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 13)!, NSForegroundColorAttributeName: UIColor.blackColor()])
            
            self.setDefaultChart()
        } else {
            if lastExam != nil {
                let singleTapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(self.chartClicked(_:)))
                singleTapGestureRecognizer2.numberOfTapsRequired = 1
                singleTapGestureRecognizer2.numberOfTouchesRequired = 1
                singleTapGestureRecognizer2.enabled = true
                
                self.statContainerView.userInteractionEnabled = true
                self.statContainerView.addGestureRecognizer(singleTapGestureRecognizer2)
                
                
//                let labels = ["درست", "نادرست", "بی جواب"]
                let labels = ["", "", ""]
                let data = [Double((lastExam?.trueAnswer)!), Double((lastExam?.falseAnswer)!), Double((lastExam?.noAnswer)!)]

                self.statContainerView.centerAttributedText = NSAttributedString(string: "آخرین\nسنجش", attributes: [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 13)!, NSForegroundColorAttributeName: UIColor.blackColor()])
                
                self.setChart(labels, values: data)
            } else {
                self.statContainerView.centerAttributedText = NSAttributedString(string: "بدون\nسنجش", attributes: [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 13)!, NSForegroundColorAttributeName: UIColor.blackColor()])
                
                self.statContainerView.userInteractionEnabled = false
                self.setDefaultChart()
            }
        }
        
    }

    @IBAction func newTestPressed(sender: UIButton) {
        if let vc = self.viewController as? EntranceShowTableViewController {
            if let modalViewController = vc.storyboard?.instantiateViewControllerWithIdentifier("ENTRANCE_LESSON_EXAM_DIALOG") as? EntranceLessonExamDialogViewController {
                
                modalViewController.examDelegate = vc
                modalViewController.modalPresentationStyle = .OverCurrentContext
                vc.presentViewController(modalViewController, animated: true, completion: nil)
            }
        }        
    }
    
    @IBAction func chartClicked(sender: UITapGestureRecognizer) {
        if let vc = self.viewController as? EntranceShowTableViewController {
            if let modalViewController = vc.storyboard?.instantiateViewControllerWithIdentifier("ENTRANCE_LESSON_LAST_EXAM_CHART") as? EntranceLessonLastExamChartViewController {

                modalViewController.entranceUniqueId = vc.entranceUniqueId
                modalViewController.lessonTitle = self.lessonTitle
                modalViewController.lessonOrder = self.lessonOrder
                modalViewController.bookletOrder = self.bookletOrder
                modalViewController.whoCalled = "LastExamChart"
                
                modalViewController.modalPresentationStyle = .Custom
                modalViewController.modalTransitionStyle = .CrossDissolve
                vc.presentViewController(modalViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func detailStatButtonPressed(sender: UIButton) {
        if let vc = self.viewController as? EntranceShowTableViewController {
            if self.examCount > 0 {
                vc.performSegueWithIdentifier("EntranceLessonExamHistoryVCSegue", sender: self)
            } else {
                AlertClass.showAlertMessage(viewController: self.viewController, messageType: "ExamAction", messageSubType: "LessonExamHistoryNotAvail", type: "", completion: nil)
            }
        }
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        let font = UIFont(name: "IRANSansMobile-Bold", size: 13)!
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.valueFormatter = FormatterSingleton.sharedInstance.NumberFormatter
        chartDataSet.valueFont = font
        chartDataSet.selectionShift = 0.0
        chartDataSet.colors = [UIColor.init(netHex: GREEN_COLOR_HEX, alpha: 0.8),
                               UIColor.init(netHex: RED_COLOR_HEX_2, alpha: 1.0),
                               UIColor.init(netHex: ORANGE_COLOR_HEX, alpha: 1.0)]
        let chartData = PieChartData(xVals: dataPoints, dataSets: [chartDataSet])
        self.statContainerView.data = chartData
    }
    
    func setDefaultChart() {
        let font = UIFont(name: "IRANSansMobile-Bold", size: 10)!
        
        var dataEntries: [ChartDataEntry] = []
        
        let dataEntry = ChartDataEntry(value: 1, xIndex: 0)
        dataEntries.append(dataEntry)
        
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.valueFormatter = FormatterSingleton.sharedInstance.NumberFormatter
        chartDataSet.valueFont = font
        chartDataSet.selectionShift = 0.0
        chartDataSet.colors = [UIColor.grayColor()]
        let chartData = PieChartData(xVals: [""], dataSets: [chartDataSet])
        self.statContainerView.data = chartData
        
    }
    
}
