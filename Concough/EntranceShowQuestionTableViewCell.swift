//
//  EntranceShowQuestionTableViewCell.swift
//  Concough
//
//  Created by Owner on 2017-01-18.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON
import RNCryptor
import Charts

class EntranceShowQuestionTableViewCell: UITableViewCell {
    
    class MyValueFormatter: NSNumberFormatter {
        override func stringFromNumber(number: NSNumber) -> String? {
            if number.intValue >= 1 {
                return "درست"
            } else if number.intValue <= -1 {
                return "نادرست"
            } else {
                return "بی جواب"
            }
        }
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var showAnswer: UIButton!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionImageView1: UIImageView!
    @IBOutlet weak var questionImageView2: UIImageView!
    @IBOutlet weak var questionImageView3: UIImageView!
    @IBOutlet weak var questionImageConstraint2: NSLayoutConstraint?
    @IBOutlet weak var questionImageConstraint3: NSLayoutConstraint?
    @IBOutlet weak var showAnswerImage: UIImageView!
    @IBOutlet weak var answerContainer: UIView!
    @IBOutlet weak var showCommentsImage: UIImageView!
    @IBOutlet weak var commentsContainer: UIView!
    @IBOutlet weak var showCommentsLabel: UILabel!
    @IBOutlet weak var showStatsImage: UIImageView!
    @IBOutlet weak var statsContainer: UIView!
    @IBOutlet weak var showStatsButton: UIButton!
    
    @IBOutlet weak var ShowAnswerButtonContainer: UIStackView!
    @IBOutlet weak var ShowCommentsButtonContainer: UIStackView!
    @IBOutlet weak var ShowStatsButtonContainer: UIStackView!
    
    @IBOutlet weak var newCommentButton: UIButton!
    @IBOutlet weak var lastCommentLabel: UILabel!
    @IBOutlet weak var moreCommnetsButton: UIButton!
    @IBOutlet weak var noCommentLabel: UILabel!
    @IBOutlet weak var commentsContainerView: UIStackView!
//    @IBOutlet weak var newCommentTextView: UITextView!
    @IBOutlet weak var lastCommentImageView: UIImageView!
    @IBOutlet weak var lastCommentDateLabel: UILabel!
    
    @IBOutlet weak var ChartView: UIView!
    @IBOutlet weak var nextChartButton: UIButton!
    
    private var hChartView: HorizontalBarChartView!
    private var lChartView: LineChartView!
    
    private var viewController: UIViewController!
    private var viewControllerType: String!
    private var oldConstraint2: NSLayoutConstraint?
    private var oldConstraint3: NSLayoutConstraint?

    private var indexPath: NSIndexPath!
    private var questionId: String!
    private var starState: Bool!
    private var questionNumber: Int!
    private var isFirstTimeComment: Bool = true
    
    private var which = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        // Initialization code
        self.questionImageView1.hidden = true
        self.questionImageView2.hidden = true
        self.questionImageView3.hidden = true
        
        self.oldConstraint2 = self.questionImageConstraint2
        self.oldConstraint3 = self.questionImageConstraint3
        
        self.nextChartButton.layer.cornerRadius = self.nextChartButton.frame.height / 2.0
        
//        self.newCommentTextView.delegate = self
        
        let font = UIFont(name: "IRANSansMobile", size: 10)!
        
        self.hChartView = HorizontalBarChartView(frame: self.ChartView.frame)
        
        self.hChartView.descriptionText = ""
        self.hChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        self.hChartView.drawGridBackgroundEnabled = false
        self.hChartView.gridBackgroundColor = UIColor.clearColor()
        self.hChartView.drawBordersEnabled = false
        self.hChartView.getAxis(ChartYAxis.AxisDependency.Left).drawAxisLineEnabled = false
        self.hChartView.getAxis(ChartYAxis.AxisDependency.Right).drawAxisLineEnabled = false
        self.hChartView.getAxis(ChartYAxis.AxisDependency.Left).drawGridLinesEnabled = false
        self.hChartView.getAxis(ChartYAxis.AxisDependency.Right).drawGridLinesEnabled = false
        self.hChartView.getAxis(ChartYAxis.AxisDependency.Right).drawLabelsEnabled = false
        self.hChartView.getAxis(ChartYAxis.AxisDependency.Left).drawLabelsEnabled = false
        self.hChartView.xAxis.labelPosition = .Bottom
        self.hChartView.xAxis.drawGridLinesEnabled = false
        self.hChartView.xAxis.labelFont = font
        self.hChartView.legend.enabled = false
        self.hChartView.setScaleEnabled(false)
        self.hChartView.highlightPerTapEnabled = false
        self.hChartView.highlightFullBarEnabled = false
        self.hChartView.highlightPerDragEnabled = false
        
        
        self.lChartView = LineChartView(frame: self.ChartView.frame)
        self.lChartView.descriptionText = ""
        self.lChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        self.lChartView.drawGridBackgroundEnabled = false
        self.lChartView.gridBackgroundColor = UIColor.clearColor()
        self.lChartView.drawBordersEnabled = false
        self.lChartView.getAxis(ChartYAxis.AxisDependency.Left).drawAxisLineEnabled = false
        self.lChartView.getAxis(ChartYAxis.AxisDependency.Right).drawAxisLineEnabled = false
        self.lChartView.getAxis(ChartYAxis.AxisDependency.Left).drawGridLinesEnabled = false
        self.lChartView.getAxis(ChartYAxis.AxisDependency.Right).drawGridLinesEnabled = false
        self.lChartView.getAxis(ChartYAxis.AxisDependency.Right).drawLabelsEnabled = false
        self.lChartView.getAxis(ChartYAxis.AxisDependency.Left).valueFormatter = MyValueFormatter()
        self.lChartView.getAxis(ChartYAxis.AxisDependency.Left).labelFont = font
        
        //        chartView.getAxis(ChartYAxis.AxisDependency.Left).drawLabelsEnabled = false
        self.lChartView.xAxis.labelPosition = .Bottom
        self.lChartView.xAxis.drawGridLinesEnabled = false
        self.lChartView.xAxis.labelFont = font
        self.lChartView.xAxis.labelTextColor = UIColor(netHex: RED_COLOR_HEX_2, alpha: 1.0)
        self.lChartView.legend.enabled = false
        self.lChartView.legend.font = font
        self.lChartView.setScaleEnabled(false)
        self.lChartView.highlightPerTapEnabled = false
        self.lChartView.highlightFullBarEnabled = false
        self.lChartView.highlightPerDragEnabled = false
        
        let limit = ChartLimitLine(limit: 0.0, label: "۰")
        limit.lineColor = UIColor(netHex: ORANGE_COLOR_HEX, alpha: 0.4)
        limit.lineDashLengths = [10.0, 10.0, 10.0]
        limit.labelPosition = .RightBottom
        limit.valueFont = font
        
        self.lChartView.getAxis(ChartYAxis.AxisDependency.Left).removeAllLimitLines()
        self.lChartView.getAxis(ChartYAxis.AxisDependency.Left).addLimitLine(limit)
        self.lChartView.getAxis(ChartYAxis.AxisDependency.Left).drawLimitLinesBehindDataEnabled = true
     
        self.nextChartButton.addTarget(self, action: #selector(self.nextChartButtonPressed(_:)), forControlEvents: .TouchUpInside)
    }

    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.aspectConstraint1 = nil
        self.aspectConstraint2 = nil
        self.aspectConstraint3 = nil
        self.questionImageView2.image = nil
        self.questionImageView3.image = nil
        
        if self.questionImageConstraint2 == nil {
            self.questionImageConstraint2 = self.oldConstraint2
        }
        if self.questionImageConstraint3 == nil {
            self.questionImageConstraint3 = self.oldConstraint3
        }
//        self.showCommentsButton.setTitle("یادداشت", forState: .Normal)        
        self.showCommentsLabel.text = "۰"
        
        self.setNeedsLayout()
        self.updateConstraintsIfNeeded()
    }
    
    override func drawRect(rect: CGRect) {
        self.questionNumberLabel.layer.cornerRadius = self.questionNumberLabel.layer.frame.width / 2.0
        self.questionNumberLabel.layer.masksToBounds = true
        self.questionNumberLabel.layer.borderColor = self.questionNumberLabel.textColor.CGColor
        self.questionNumberLabel.layer.borderWidth = 2.0
        
        self.lastCommentImageView.tintImageColor(UIColor.darkGrayColor())
        
        self.newCommentButton.layer.borderColor = self.newCommentButton.titleColorForState(.Normal)?.CGColor
        self.newCommentButton.layer.borderWidth = 1.0
        self.newCommentButton.layer.cornerRadius = self.newCommentButton.frame.size.height / 2.0
        self.newCommentButton.layer.masksToBounds = true
    }
    
    internal func configureCell(viewController viewController: UIViewController, vcType: String, indexPath: NSIndexPath, question: Int, questionId: String, answer: Int, starred: Bool, images: [NSData], showAnswer: EntranceQuestionAnswerState, commentsCount: Int, lastComment: EntranceQuestionCommentModel?) {
        self.questionNumberLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(question)!
        self.answerLabel.text = "گزینه " + questionAnswerToString(answer) + " درست است"
        
        self.viewController = viewController
        self.viewControllerType = vcType
        
        self.indexPath = indexPath
        self.questionId = questionId
        self.questionNumber = question
        self.starState = starred
        
        self.changeStarState(state: starred)
        self.insertImages(images: images)

        self.setupComment(count: commentsCount, lastComment: lastComment)
        self.changeAnswerContainerState(state: showAnswer)
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.answerShowClicked(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.enabled = true
        
        self.ShowAnswerButtonContainer.userInteractionEnabled = true
        self.ShowAnswerButtonContainer.addGestureRecognizer(singleTapGestureRecognizer)

        let singleTapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(self.showCommentsClicked(_:)))
        singleTapGestureRecognizer2.numberOfTapsRequired = 1
        singleTapGestureRecognizer2.numberOfTouchesRequired = 1
        singleTapGestureRecognizer2.enabled = true
        
        self.ShowCommentsButtonContainer.userInteractionEnabled = true
        self.ShowCommentsButtonContainer.addGestureRecognizer(singleTapGestureRecognizer2)
        
        let singleTapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(self.showStatsClicked(_:)))
        singleTapGestureRecognizer3.numberOfTapsRequired = 1
        singleTapGestureRecognizer3.numberOfTouchesRequired = 1
        singleTapGestureRecognizer3.enabled = true
        
        self.ShowStatsButtonContainer.userInteractionEnabled = true
        self.ShowStatsButtonContainer.addGestureRecognizer(singleTapGestureRecognizer3)
        
        self.starButton.addTarget(self, action: #selector(self.starButtonPressed(_:)), forControlEvents: .TouchUpInside)

        self.moreCommnetsButton.addTarget(self, action: #selector(self.moreCommentsClicked(_:)), forControlEvents: .TouchUpInside)
        self.newCommentButton.addTarget(self, action: #selector(self.newCommentClicked(_:)), forControlEvents: .TouchUpInside)
        
        self.setupStat()
        self.changeStatView(which: self.which)
        
        if showAnswer == .STATS {
//            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: chartView, attribute: NSLayoutAttribute.Height , relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100)
//            
//            chartView.addConstraint(heightConstraint)
//            self.setNeedsUpdateConstraints()
//            self.setNeedsLayout()
            
//            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
//            swipeRight.direction = UISwipeGestureRecognizerDirection.Right
//            self.statsContainer.addGestureRecognizer(swipeRight)
//            
//            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
//            swipeDown.direction = UISwipeGestureRecognizerDirection.Left
//            self.statsContainer.addGestureRecognizer(swipeDown)
        }
    }

    @IBAction func answerShowClicked(sender: UITapGestureRecognizer) {
        if let vc = self.viewController as? EntranceShowTableViewController {
            vc.changeQuestionAnswerContainerState(indexPath: self.indexPath, questionId: self.questionId, state: .ANSWER)
        }
    }
    
    @IBAction func showCommentsClicked(sender: UITapGestureRecognizer) {
        if let vc = self.viewController as? EntranceShowTableViewController {
            vc.changeQuestionAnswerContainerState(indexPath: self.indexPath, questionId: self.questionId, state: .COMMENTS)
        }
    }
    
    @IBAction func showStatsClicked(sender: UITapGestureRecognizer) {
        if let vc = self.viewController as? EntranceShowTableViewController {
            vc.changeQuestionAnswerContainerState(indexPath: self.indexPath, questionId: self.questionId, state: .STATS)
        }
    }
    
    @IBAction func moreCommentsClicked(sender: UIButton) {
        if let vc = self.viewController as? EntranceShowTableViewController {
            if let modalViewController = vc.storyboard?.instantiateViewControllerWithIdentifier("ENTRANCE_ALL_COMMENTS_VC") as? EntranceShowAllCommentViewController {
                
                vc.newCommentOnQuestionClicked(indexPath: self.indexPath, questionId: self.questionId)
                
                modalViewController.entranceUniqueId = vc.entranceUniqueId
                modalViewController.questionId = self.questionId                
                modalViewController.questionIndexPath = self.indexPath
                modalViewController.questionNo = self.questionNumber
                modalViewController.commentDelegate = vc
                
                modalViewController.modalPresentationStyle = .Custom
                modalViewController.modalTransitionStyle = .CrossDissolve
                vc.presentViewController(modalViewController, animated: true, completion: nil)
            }
        }
    }

    @IBAction func newCommentClicked(sender: UIButton) {
        if let vc = self.viewController as? EntranceShowTableViewController {
            if let modalViewController = vc.storyboard?.instantiateViewControllerWithIdentifier("ENTRANCE_COMMENT_VC") as? EntranceShowNewCommentViewController {
                
                vc.newCommentOnQuestionClicked(indexPath: self.indexPath, questionId: self.questionId)
                modalViewController.indexPath = self.indexPath
                modalViewController.questionUniqueId = self.questionId
                modalViewController.questionNo = self.questionNumber
                modalViewController.commentDelegate = vc
                
                modalViewController.modalPresentationStyle = .OverCurrentContext
                vc.presentViewController(modalViewController, animated: true, completion: nil)                
            }
        }
    }
    
    
    @IBAction func starButtonPressed(sender: UIButton) {
        self.starState = !self.starState
        self.changeStarState(state: self.starState)

        if self.viewControllerType == "E" {
            if let vc = self.viewController as? EntranceShowTableViewController {
                vc.addStarQuestionId(questionId: self.questionId, questionNo: self.questionNumber, state: self.starState)
            }
        }
    }
    
    @IBAction func nextChartButtonPressed(sender: UIButton) {
        self.which += 1
        if self.which == 2 {
            self.which = 0
        }
        self.changeStatView(which: self.which)
    }
    
    @IBAction func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                self.which -= 1
                if self.which == -1 {
                    self.which = 1
                }
            case UISwipeGestureRecognizerDirection.Left:
                self.which += 1
                if self.which == 2 {
                    self.which = 0
                }
            default:
                break
            }
            
            self.changeStatView(which: self.which)
        }
    }
    
    internal func changeAnswerContainerState(state state: EntranceQuestionAnswerState) {
        let color1 = UIColor.grayColor()
//        let color1 = UIColor(netHex: GRAY_BLUE_COLOR_HEX, alpha: 1.0)
        let color2 = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        self.showAnswer.setTitleColor(color2, forState: .Normal)
        self.showCommentsLabel.textColor = color1
        self.showStatsButton.setTitleColor(color1, forState: .Normal)
        
        self.showAnswerImage.tintImageColor(color2)
        self.showCommentsImage.tintImageColor(color1)
        self.showStatsImage.tintImageColor(color1)
        
        self.answerContainer.hidden = true
        self.commentsContainer.hidden = true
        self.statsContainer.hidden = true
        
        if state == .ANSWER {
            self.showAnswer.setTitleColor(UIColor.blackColor(), forState: .Normal)
            self.showAnswerImage.tintImageColor(UIColor.blackColor())
            self.answerContainer.hidden = false
        } else if state == .COMMENTS {
            self.showCommentsLabel.textColor = UIColor.blackColor()
            self.showCommentsImage.tintImageColor(UIColor.blackColor())
            self.commentsContainer.hidden = false
        } else if state == .STATS {
            self.showStatsButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            self.showStatsImage.tintImageColor(UIColor.blackColor())
            self.statsContainer.hidden = false
            self.statsContainer.setNeedsLayout()
            
        }
    }
    
    internal func setupComment(count count: Int, lastComment: EntranceQuestionCommentModel?) {
        self.commentsContainerView.hidden = true
        self.noCommentLabel.hidden = true
        self.moreCommnetsButton.hidden = true
        
        if count > 0 {
//            let title = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(count)!) یادداشت"
            let title = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(count)!)"
            self.showCommentsLabel.text = title
            
            if let comment = lastComment {
                switch EntranceCommentType.toType(comment.commentType) {
                case .TEXT:
                    let data = JSON.parse(comment.commentData)
                    
                    if let str = data["text"].string {
                        self.lastCommentLabel.text = str
                    }
                    self.lastCommentDateLabel.text = comment.created.timeAgoSinceDate(lang: "fa", numericDates: true)
                    self.commentsContainerView.hidden = false
                    if count > 0 {
                        self.moreCommnetsButton.hidden = false
                    }
                }
            }
        } else {
            self.showCommentsLabel.text = "۰"
            self.noCommentLabel.hidden = false
        }
    }
    
    internal func changeStarState(state state: Bool) {

        if state == true {
            self.starButton.setImage(UIImage(named: "BookmarkRibbonFilled"), forState: .Normal)
            self.starButton.tintColor = UIColor(netHex: RED_COLOR_HEX_2, alpha: 1.0)
        } else {
            self.starButton.setImage(UIImage(named: "BookmarkRibbon"), forState: .Normal)
            self.starButton.tintColor = UIColor.darkGrayColor()
        }
    }
    
    internal func changeStatView(which which: Int) {
        if which == 0 {
            self.ChartView.subviews.forEach({ $0.removeFromSuperview() })
            self.ChartView.addSubview(self.hChartView)
            self.hChartView.animate(yAxisDuration: 1.0)
            
        } else if which == 1 {
            self.ChartView.subviews.forEach({ $0.removeFromSuperview() })
            self.ChartView.addSubview(self.lChartView)
            self.lChartView.animate(yAxisDuration: 1.0)
            
        }
    }
    
    internal func setupStat() {
        if let vc = self.viewController as? EntranceShowTableViewController {
            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
            if let stat = EntranceQuestionExamStatModelHandler.getByNo(username: username, entranceUniqueId: vc.entranceUniqueId, questionNo: self.questionNumber) {
                
                var labels: [String] = ["کل", "درست", "نادرست", "بی جواب"]
                var data: [Double] = [Double(stat.totalCount), Double(stat.trueCount), Double(stat.falseCount), Double(stat.emptyCount)]
                self.setChart(labels, values: data)
                
                var statDataArray = stat.statData.componentsSeparatedByString(",")
                data = []
                labels = []
                let colors: [UIColor] = []
                
                var min = 0
                var max = statDataArray.count
                
                if statDataArray[statDataArray.count - 1].trim() == "" {
                    max -= 1
                    if statDataArray.count > 11 {
                        min = max - 10
                    }
                } else {
                    if statDataArray.count > 10 {
                        min = max - 10
                    }
                }
                
                for i in min..<max {
                    
                    if statDataArray[i].trim() != "" {
                        data.append(Double(statDataArray[i].trim()!)!)
                    
                    } else {
                        data.append(Double(0))
                    }
                    if i == max - 1 {
                        labels.append("سنجش آخر")
                    } else {
                        labels.append("\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(max - i)!)")
                    }
//                    switch Double(statDataArray[i].trim()!)! {
//                    case -1:
////                        colors.append(UIColor(netHex: RED_COLOR_HEX_2, alpha: 1.0))
//                        colors.append(UIColor(netHex: RED_COLOR_HEX_2, alpha: 1.0))
//                    case 1:
////                        colors.append(UIColor(netHex: GREEN_COLOR_HEX, alpha: 1.0))
//                        colors.append(UIColor(netHex: GREEN_COLOR_HEX, alpha: 1.0))
//                    default:
////                        colors.append(UIColor(netHex: ORANGE_COLOR_HEX, alpha: 1.0))
//                        colors.append(UIColor(netHex: ORANGE_COLOR_HEX, alpha: 1.0))
//                    }
                    
                }
                
                data.append(0.0)
                labels.append("")

                if data.count <= 2 {
                    self.lChartView.getAxis(ChartYAxis.AxisDependency.Left).setLabelCount(2, force: true)
                } else {
                    self.lChartView.getAxis(ChartYAxis.AxisDependency.Left).setLabelCount(3, force: true)
                }
            
                self.setChart2(labels, values: data, colors: colors)
                
                
            } else {
                var labels = ["کل", "درست", "نادرست", "بی جواب"]
                var data = [0.0, 0.0, 0.0, 0.0]
                self.setChart(labels, values: data)
                
                labels = ["", ""]
                data = [0.0, 0.0]
                self.lChartView.getAxis(ChartYAxis.AxisDependency.Left).setLabelCount(1, force: true)
                self.setChart2(labels, values: data, colors: [UIColor.grayColor()])
                
            }
        }
    }
    
    private func setChart(dataPoints: [String], values: [Double]) {
        let font = UIFont(name: "IRANSansMobile", size: 10)!
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "x")
        chartDataSet.valueFormatter = FormatterSingleton.sharedInstance.NumberFormatter
        chartDataSet.valueFont = font
        chartDataSet.colors = [UIColor.grayColor(), UIColor(netHex: GREEN_COLOR_HEX, alpha: 1.0), UIColor(netHex: RED_COLOR_HEX_2, alpha: 1.0), UIColor(netHex: ORANGE_COLOR_HEX, alpha: 1.0) ]
//        chartDataSet.colors = [UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.7), UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.4), UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.1) ]
        let chartData = BarChartData(xVals: dataPoints, dataSets: [chartDataSet])
        self.hChartView.data = chartData
    }
    
    func setChart2(dataPoints: [String], values: [Double], colors: [UIColor]) {
        let font = UIFont(name: "IRANSansMobile", size: 10)!
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "عملکرد ۱۰ سنجش اخیر")
        chartDataSet.valueFormatter = FormatterSingleton.sharedInstance.NumberFormatter
        chartDataSet.valueFont = font
        chartDataSet.colors = [UIColor(netHex: ORANGE_COLOR_HEX, alpha: 1.0)]
//        chartDataSet.colors = [UIColor.lightGrayColor()]
        chartDataSet.drawFilledEnabled = false
        chartDataSet.circleRadius = 4.0
//        chartDataSet.drawCubicEnabled = true
        chartDataSet.mode = .CubicBezier
        chartDataSet.lineWidth = 2.0
        chartDataSet.circleColors = [UIColor(netHex: ORANGE_COLOR_HEX, alpha: 1.0) ]
//        chartDataSet.circleColors = colors
//        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawValuesEnabled = false
        
//                chartDataSet.colors = [UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.7), UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.4), UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.1) ]
        let chartData = LineChartData(xVals: dataPoints, dataSets: [chartDataSet])
        self.lChartView.data = chartData
    }

    
    internal var aspectConstraint1: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                self.questionImageView1.removeConstraint(oldValue!)
            }
            if aspectConstraint1 != nil {
                self.questionImageView1.addConstraint(aspectConstraint1!)
            }
        }
    }

    internal var aspectConstraint2: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                self.questionImageView2.removeConstraint(oldValue!)
            }
            if aspectConstraint2 != nil {
                if self.questionImageConstraint2 != nil {
                    self.questionImageView2.removeConstraint(self.questionImageConstraint2!)
                }
                self.questionImageView2.addConstraint(aspectConstraint2!)
            }
        }
    }

    internal var aspectConstraint3: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                self.questionImageView3.removeConstraint(oldValue!)
            }
            if aspectConstraint3 != nil {
                if self.questionImageConstraint3 != nil {
                    self.questionImageView3.removeConstraint(self.questionImageConstraint3!)
                }
                self.questionImageView3.addConstraint(aspectConstraint3!)
            }
        }
    }
    
    private func insertImages(images images: [NSData]) {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        let hash_str = username + ":" + SECRET_KEY
        let hash_key = MD5Digester.digest(hash_str)
        
        if images.count >= 1 {
            let decodedData = NSData(base64EncodedData: images[0], options: NSDataBase64DecodingOptions.init(rawValue: 0))
            
            do {
                
                let originalImage = try RNCryptor.decryptData(decodedData!, password: hash_key)
                let image = UIImage(data: originalImage)
                
                let ratio = (image?.size.width)! / (image?.size.height)!
                self.questionImageView1.hidden = false
                self.questionImageView1.image = image
                self.aspectConstraint1 = NSLayoutConstraint(item: self.questionImageView1, attribute: .Width, relatedBy: .Equal, toItem: self.questionImageView1, attribute: .Height, multiplier: ratio, constant: 0.0)
            } catch {}
            
        }
        if images.count >= 2 {
            let decodedData = NSData(base64EncodedData: images[1], options: NSDataBase64DecodingOptions.init(rawValue: 0))
            
            do {
                let originalImage = try RNCryptor.decryptData(decodedData!, password: hash_key)
                let image = UIImage(data: originalImage)
            
                let ratio = (image?.size.width)! / (image?.size.height)!
                self.questionImageView2.hidden = false
                self.questionImageView2.image = image
                self.aspectConstraint2 = NSLayoutConstraint(item: self.questionImageView2, attribute: .Width, relatedBy: .Equal, toItem: self.questionImageView2, attribute: .Height, multiplier: ratio, constant: 0.0)

            } catch {}
        }
        if images.count >= 3 {
            let decodedData = NSData(base64EncodedData: images[2], options: NSDataBase64DecodingOptions.init(rawValue: 0))
            
            do {
                let originalImage = try RNCryptor.decryptData(decodedData!, password: hash_key)
                let image = UIImage(data: originalImage)
            
                let ratio = (image?.size.width)! / (image?.size.height)!
                self.questionImageView3.hidden = false
                self.questionImageView3.image = image
                self.aspectConstraint3 = NSLayoutConstraint(item: self.questionImageView3, attribute: .Width, relatedBy: .Equal, toItem: self.questionImageView3, attribute: .Height, multiplier: ratio, constant: 0.0)

            } catch {}
        }
        
//        self.setNeedsUpdateConstraints()
//        self.updateConstraints()
//        self.sizeToFit()
//        self.setNeedsLayout()
    }
}
