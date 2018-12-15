//
//  EntranceLessonExamHistoryItemTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-04-12.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit

class EntranceLessonExamHistoryItemTableViewCell: UITableViewCell {

    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var trueAnswerLabel: UILabel!
    @IBOutlet weak var falseAnswerLabel: UILabel!
    @IBOutlet weak var noAnswerLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func configureCell(percentage percentage: Double, trueAnswer: Int, falseAnswer: Int, noAnswer: Int, examDate: NSDate, started: NSDate, finished: NSDate) {
        
        let y = Double(round((round((percentage * 10000)) / 100) * 10) / 10)
        self.percentageLabel.text = "\(FormatterSingleton.sharedInstance.DecimalFormatter.stringFromNumber(y)!) %"
        self.trueAnswerLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(trueAnswer)!)"
        self.falseAnswerLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(falseAnswer)!)"
        self.noAnswerLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(noAnswer)!)"
        
        self.dateLabel.text = examDate.timeAgoSinceDate(lang: "fa", numericDates: true)
        
        let hourMinuteSecond: NSCalendarUnit = [.Hour, .Minute, .Second]
        
        let diff = NSCalendar.currentCalendar().components(hourMinuteSecond, fromDate: started, toDate: finished, options: [])
        
        var str = ""
        
        var s = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(diff.second)!
        if s.characters.count == 1 {
            s = "۰\(s)"
        }
        str += "\(s)"
        
        var m = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(diff.minute)!
        if m.characters.count == 1 {
            m = "۰\(m)"
        }
        str += " : \(m)"

        if diff.hour > 0 {
            let h = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(diff.hour)!
            str += " : \(h)"
        }
    
        self.timeElapsedLabel.text = "زمان: " + str
    }

}
