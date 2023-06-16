//
//  EntranceLessonLastExamChartViewController.swift
//  Concough
//
//  Created by Owner on 2018-04-09.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON
import RealmSwift

class EntranceLessonLastExamChartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lessonTitleLabel: UILabel!
    @IBOutlet weak var lessonExamDateLabel: UILabel!
    @IBOutlet weak var resultPieChartView: PieChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    internal var entranceUniqueId: String!
    internal var lessonTitle: String!
    internal var lessonOrder: Int!
    internal var bookletOrder: Int!
    internal var whoCalled: String = ""
    internal var examRecord: EntranceLessonExamModel!
    
    private var answers: JSON!
    private var questionsDB: List<EntranceQuestionModel>!
    private var selectedQuestionIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.closeButton.layer.cornerRadius = 10.0
        self.closeButton.layer.masksToBounds = true
        
        self.lessonTitleLabel.text = lessonTitle
        
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.closeButton.layer.cornerRadius = 18.0
        self.closeButton.layer.masksToBounds = true
//        self.closeButton.layer.borderColor = self.closeButton.titleColorForState(.Normal)?.CGColor
//        self.closeButton.layer.borderWidth = 0.7
        
        self.resultPieChartView.backgroundColor = UIColor.clearColor()
        self.resultPieChartView.transparentCircleRadiusPercent = 1
        self.resultPieChartView.holeRadiusPercent = 0.4
        self.resultPieChartView.holeColor = UIColor.clearColor()
        self.resultPieChartView.transparentCircleColor = UIColor.clearColor()
        self.resultPieChartView.descriptionText = ""
        self.resultPieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        self.resultPieChartView.legend.enabled = false
        
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!

        if self.whoCalled != "ExamHistory" {
            if let lastExam = EntranceLessonExamModelHandler.getLastExam(username: username, entranceUniqueId: self.entranceUniqueId, lessonTitle: self.lessonTitle, lessonOrder: self.lessonOrder, bookletOrder: self.bookletOrder) {
                self.examRecord = lastExam
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        self.lessonExamDateLabel.text = self.examRecord.created.timeAgoSinceDate(lang: "fa", numericDates: true)
        
        let y = Double(round((round((self.examRecord.percentage * 10000)) / 100) * 10) / 10)
        self.resultPieChartView.centerAttributedText = NSAttributedString(string: "\(FormatterSingleton.sharedInstance.DecimalFormatter.stringFromNumber(y)!) ٪", attributes: [NSFontAttributeName: UIFont(name: "IRANSansMobile", size: 16)!, NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        let labels = ["درست", "نادرست", "بی جواب"]
        let data = [Double((self.examRecord.trueAnswer)), Double((self.examRecord.falseAnswer)), Double((self.examRecord.noAnswer))]
        self.setChart(labels, values: data)
        
        self.answers = JSON.parse(self.examRecord.examData)
        
        if let lesson = EntranceLessonModelHandler.getOneLessonByTitleAndOrder(username: username, entranceUniqueId: self.entranceUniqueId, lessonTitle: self.lessonTitle, lessonOrder: self.lessonOrder) {
            
            self.questionsDB = lesson.questions
            
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func setChart(dataPoints: [String], values: [Double]) {
        let font = UIFont(name: "IRANSansMobile-Bold", size: 12)!
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.valueFormatter = FormatterSingleton.sharedInstance.NumberFormatter
        chartDataSet.valueFont = font
        chartDataSet.selectionShift = 0.0
        chartDataSet.colors = [UIColor.init(netHex: GREEN_COLOR_HEX, alpha: 1.0),
                               UIColor.init(netHex: RED_COLOR_HEX_2, alpha: 1.0),
                               UIColor.init(netHex: ORANGE_COLOR_HEX, alpha: 1.0)]
        let chartData = PieChartData(xVals: dataPoints, dataSets: [chartDataSet])
        self.resultPieChartView.data = chartData
    }
    
    // MARK: Delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questionsDB.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let question = self.questionsDB[indexPath.row]
        if let cell = self.tableView.dequeueReusableCellWithIdentifier("ENTRANCE_LESSON_LAST_EXAM_ANSWER", forIndexPath: indexPath) as? EntranceLessonLastExamAnswerTableViewCell {
            
            var state = 0
            var answer = 0
            
            if let ans = self.answers["\(question.number)"].int {
                answer = ans
                if question.answer == ans {
                    state = 1
                } else {
                    state = -1
                }
            }
            
            cell.configureCell(viewController: self, indexPathRow: indexPath.row, question: question, answer: answer, state: state, from: self.whoCalled)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
