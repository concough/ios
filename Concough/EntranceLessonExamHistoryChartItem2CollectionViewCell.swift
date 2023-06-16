//
//  EntranceLessonExamHistoryChartItem2CollectionViewCell.swift
//  Concough
//
//  Created by Owner on 2018-04-11.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import Charts

class EntranceLessonExamHistoryChartItem2CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var chartView: LineChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    internal func configureCellAsLine(labels labels: [String], data: [Double]) {
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
        self.chartView.getAxis(ChartYAxis.AxisDependency.Left).valueFormatter = FormatterSingleton.sharedInstance.DecimalFormatter
        self.chartView.xAxis.labelPosition = .Bottom
        self.chartView.xAxis.labelFont = font
        self.chartView.xAxis.axisMaxValue = 100.0
//        self.chartView.getAxis(ChartYAxis.AxisDependency.Left).spaceTop = 1
        
        self.chartView.xAxis.drawGridLinesEnabled = false
        self.chartView.xAxis.labelFont = font
//        self.chartView.legend.enabled = false
        self.chartView.legend.font = lfont

        self.chartView.setScaleEnabled(false)
        self.chartView.highlightPerTapEnabled = false
        self.chartView.highlightFullBarEnabled = false
        self.chartView.highlightPerDragEnabled = false
        
        let sum: Double = data.reduce(0.0, combine: +)
        var average: Double = 0.0
        if sum != 0 {
            average = sum / Double(data.count)
        }
        
        if data.count > 1 {
            let limit = ChartLimitLine(limit: average, label: "میانگبن")
            limit.lineColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.7)
            limit.lineDashLengths = [10.0, 10.0, 10.0]
            limit.labelPosition = .LeftBottom
            limit.valueFont = font
            
            self.chartView.getAxis(ChartYAxis.AxisDependency.Left).removeAllLimitLines()
            self.chartView.getAxis(ChartYAxis.AxisDependency.Left).addLimitLine(limit)
            self.chartView.getAxis(ChartYAxis.AxisDependency.Left).drawLimitLinesBehindDataEnabled = true
        }
        
        self.chartView.data = self.setChart(labels, values: data)
    }
    
    func setChart(dataPoints: [String], values: [Double]) -> LineChartData {
        let font = UIFont(name: "IRANSansMobile-Medium", size: 12)!
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "درصد ۱۰ سنجش اخیر")
        chartDataSet.valueFormatter = FormatterSingleton.sharedInstance.DecimalFormatter
        chartDataSet.valueFont = font
        chartDataSet.colors = [UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0) ]
        chartDataSet.fillColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.7)
        chartDataSet.drawFilledEnabled = true
        chartDataSet.circleRadius = 3.0
        chartDataSet.circleColors = [UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0) ]
        //        chartDataSet.colors = [UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.7), UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.4), UIColor(netHex: BLUE_COLOR_HEX, alpha: 0.1) ]
        let chartData = LineChartData(xVals: dataPoints, dataSets: [chartDataSet])
        return chartData
        
    }
   
}
