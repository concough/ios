//
//  EntranceLessonExamResultViewController.swift
//  Concough
//
//  Created by Owner on 2018-04-08.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit

class EntranceLessonExamResultViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var examTimelabel: UILabel!
    @IBOutlet weak var questionsCountLabel: UILabel!
    @IBOutlet weak var examTimeImage: UIImageView!
    @IBOutlet weak var questionsCountImage: UIImageView!
    @IBOutlet weak var resultExamTimeLabel: UILabel!
    @IBOutlet weak var resultExamPercentage: UILabel!
    @IBOutlet weak var resultTrueAnswerlabel: UILabel!
    @IBOutlet weak var resultFalseAnswerlabel: UILabel!
    @IBOutlet weak var resultNoAnswerlabel: UILabel!
    @IBOutlet weak var seeResultsButton: UIButton!
    @IBOutlet weak var closeResultButton: UIButton!

    @IBOutlet weak var resultNoAnswerImage: UIImageView!
    
    internal var entranceLessonExamStruct: EntranceLessonExamStructure!
    internal var examDelegate: EntranceLessonExamDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.containerView.layer.cornerRadius = 5.0
        self.containerView.layer.masksToBounds = true
        
        self.seeResultsButton.layer.cornerRadius = 5.0
        self.seeResultsButton.layer.masksToBounds = true
        self.seeResultsButton.layer.borderWidth = 1.0
        self.seeResultsButton.layer.borderColor = self.seeResultsButton.titleColorForState(.Normal)?.CGColor

        self.closeResultButton.layer.cornerRadius = 5.0
        self.closeResultButton.layer.masksToBounds = true
        self.closeResultButton.layer.borderWidth = 1.0
        self.closeResultButton.layer.borderColor = self.closeResultButton.titleColorForState(.Normal)?.CGColor
        
        self.examTimeImage.tintImageColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0))
        self.questionsCountImage.tintImageColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0))

        self.subTitleLabel.text = self.entranceLessonExamStruct.title!
        self.examTimelabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.entranceLessonExamStruct.duration!)!)'"
        self.questionsCountLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.entranceLessonExamStruct.qCount!)!)"
        
        let hourMinuteSecond: NSCalendarUnit = [.Hour, .Minute, .Second]
        
        let diff = NSCalendar.currentCalendar().components(hourMinuteSecond, fromDate: self.entranceLessonExamStruct!.started!, toDate: self.entranceLessonExamStruct!.finished!, options: [])
        
        var str = ""
        
        let h = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(diff.hour)!
        str += "\(h) : "
        
        var m = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(diff.minute)!
        if m.characters.count == 1 {
            m = "۰\(m)"
        }
        str += "\(m) : "
        
        var s = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(diff.second)!
        if s.characters.count == 1 {
            s = "۰\(s)"
        }
        str += "\(s)"
        
        self.resultExamTimeLabel.text = str
        
        let y = Double(round((round((self.entranceLessonExamStruct.percentage * 10000)) / 100) * 10) / 10)
        self.resultExamPercentage.text = "\(FormatterSingleton.sharedInstance.DecimalFormatter.stringFromNumber(y)!) درصد"
        
        FormatterSingleton.sharedInstance.NumberFormatter
        
        self.resultTrueAnswerlabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.entranceLessonExamStruct.trueAnswer)!)"
        self.resultFalseAnswerlabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.entranceLessonExamStruct.falseAnswer)!)"
        self.resultNoAnswerlabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.entranceLessonExamStruct.noAnswer)!)"        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func seeResultsPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.examDelegate {
            delegate.showLessonExamResult()
        }
        
    }
    
    @IBAction func closeResultPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let delegate = self.examDelegate {
            delegate.cancelLessonExam(withLog: false)
        }
        
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
