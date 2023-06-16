//
//  EntranceLessonExamHistoryChartItemCollectionViewCell.swift
//  Concough
//
//  Created by Owner on 2018-04-10.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import Charts


class EntranceLessonExamHistoryChartItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var chartView: BarChartView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    internal func configureCellAsBar(labels labels: [String], data: [[Double]]) {
//        self.chartView = BarChartView()
        
        let font = UIFont(name: "IRANSansMobile", size: 10)!
        let lfont = UIFont(name: "IRANSansMobile", size: 12)!
        
        self.chartView.descriptionText = ""
        self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 2.0)
        self.chartView.drawGridBackgroundEnabled = false
        self.chartView.gridBackgroundColor = UIColor.clearColor()
        self.chartView.drawBordersEnabled = false
        self.chartView.getAxis(ChartYAxis.AxisDependency.Left).drawAxisLineEnabled = false
        self.chartView.getAxis(ChartYAxis.AxisDependency.Right).drawAxisLineEnabled = false
        self.chartView.getAxis(ChartYAxis.AxisDependency.Left).drawGridLinesEnabled = false
        self.chartView.getAxis(ChartYAxis.AxisDependency.Right).drawGridLinesEnabled = false
        self.chartView.getAxis(ChartYAxis.AxisDependency.Right).drawLabelsEnabled = false
//        self.chartView.getAxis(ChartYAxis.AxisDependency.Left).drawLabelsEnabled = false
        self.chartView.getAxis(ChartYAxis.AxisDependency.Left).labelFont = font
        self.chartView.getAxis(ChartYAxis.AxisDependency.Left).valueFormatter = FormatterSingleton.sharedInstance.NumberFormatter
        self.chartView.xAxis.labelPosition = .Bottom
        self.chartView.xAxis.drawGridLinesEnabled = false
        self.chartView.xAxis.labelFont = font
//        self.chartView.legend.enabled = false
        self.chartView.legend.font = lfont
        self.chartView.setScaleEnabled(false)
        self.chartView.highlightPerTapEnabled = false
        self.chartView.highlightFullBarEnabled = false
        self.chartView.highlightPerDragEnabled = false
        self.chartView.drawValueAboveBarEnabled = false
        self.chartView.clearValues()
        
        self.chartView.data = self.setChart(labels, values: data)
    }

    func setChart(dataPoints: [String], values: [[Double]]) -> BarChartData {
        let font = UIFont(name: "IRANSansMobile-Medium", size: 12)!
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(values: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "۱۰ سنجش اخیر")
        chartDataSet.stackLabels = ["درست", "نادرست", "بی جواب"]
        chartDataSet.valueFormatter = FormatterSingleton.sharedInstance.NumberFormatter
        chartDataSet.valueFont = font
        chartDataSet.colors = [UIColor(netHex: GREEN_COLOR_HEX, alpha: 0.8), UIColor(netHex: RED_COLOR_HEX_2, alpha: 1.0), UIColor(netHex: ORANGE_COLOR_HEX, alpha: 1.0) ]
        let chartData = BarChartData(xVals: dataPoints, dataSets: [chartDataSet])
        return chartData
        
    }

}
