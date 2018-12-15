//
//  EntranceLessonLastExamAnswerTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-04-09.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit

class EntranceLessonLastExamAnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var answer1Button: UIButton!
    @IBOutlet weak var answer2Button: UIButton!
    @IBOutlet weak var answer3Button: UIButton!
    @IBOutlet weak var answer4Button: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!

    private var question: EntranceQuestionModel!
    private var index: Int!
    private var viewController: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.answersDefaultState()
        self.resetAnswerButton()
        self.setAnswerButton(0)
        
        self.helpButton.addTarget(self, action: #selector(self.helpPressed(_:)), forControlEvents: .TouchUpInside)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetAnswerButton()
        
        self.setNeedsLayout()
        self.updateConstraintsIfNeeded()
    }
    
    internal func configureCell(viewController viewController: UIViewController, indexPathRow: Int, question: EntranceQuestionModel, answer: Int, state: Int, from: String) {
        self.question = question
        self.index = indexPathRow
        self.viewController = viewController
        
        self.questionLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(question.number)!)"
        if state != 0 {
            self.setAnswerButton(answer, answerState: state)
        }
        
        if from != "ExamHistory" {
            self.helpButton.hidden = true
        }
    }

    private func answersDefaultState() {
        //        let color = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
        
        let color = UIColor.darkGrayColor()
        self.answer1Button.layer.cornerRadius = self.answer1Button.layer.frame.height / 2.0
        self.answer1Button.layer.masksToBounds = true
        self.answer1Button.layer.borderColor = color.CGColor
        self.answer1Button.layer.borderWidth = 1.5
        
        self.answer2Button.layer.cornerRadius = self.answer2Button.layer.frame.height / 2.0
        self.answer2Button.layer.masksToBounds = true
        self.answer2Button.layer.borderColor = color.CGColor
        self.answer2Button.layer.borderWidth = 1.5
        
        self.answer3Button.layer.cornerRadius = self.answer3Button.layer.frame.height / 2.0
        self.answer3Button.layer.masksToBounds = true
        self.answer3Button.layer.borderColor = color.CGColor
        self.answer3Button.layer.borderWidth = 1.5
        
        self.answer4Button.layer.cornerRadius = self.answer4Button.layer.frame.height / 2.0
        self.answer4Button.layer.masksToBounds = true
        self.answer4Button.layer.borderColor = color.CGColor
        self.answer4Button.layer.borderWidth = 1.5
        
    }

    private func resetAnswerButton() {
        let color = UIColor.darkGrayColor()
        self.answer1Button.setTitleColor(color, forState: .Normal)
        self.answer2Button.setTitleColor(color, forState: .Normal)
        self.answer3Button.setTitleColor(color, forState: .Normal)
        self.answer4Button.setTitleColor(color, forState: .Normal)
        
        self.answer1Button.backgroundColor = UIColor(netHex: 0xF6F6F6, alpha: 1.0)
        self.answer2Button.backgroundColor = UIColor(netHex: 0xF6F6F6, alpha: 1.0)
        self.answer3Button.backgroundColor = UIColor(netHex: 0xF6F6F6, alpha: 1.0)
        self.answer4Button.backgroundColor = UIColor(netHex: 0xF6F6F6, alpha: 1.0)
    }
    
    private func setAnswerButton(index: Int, answerState: Int = 0) {
        var color2 = UIColor.darkGrayColor()
        if answerState == 1 {
            color2 = UIColor(netHex: GREEN_COLOR_HEX, alpha: 1.0)
        } else if answerState == -1 {
            color2 = UIColor(netHex: RED_COLOR_HEX_2, alpha: 1.0)
        }
        
        switch index {
        case 1:
            self.answer1Button.backgroundColor = color2
            self.answer1Button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case 2:
            self.answer2Button.backgroundColor = color2
            self.answer2Button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case 3:
            self.answer3Button.backgroundColor = color2
            self.answer3Button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        case 4:
            self.answer4Button.backgroundColor = color2
            self.answer4Button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        default:
            break
        }
        
    }
    
    @IBAction func helpPressed(sender: UIButton) {
        if let vc = self.viewController as? EntranceLessonLastExamChartViewController {
            if let modalViewController = vc.storyboard?.instantiateViewControllerWithIdentifier("ENTRANCE_SHOW_PREVIEW_VC") as? EntranceShowPreviewViewController {
                
                modalViewController.question = self.question
                
                modalViewController.modalPresentationStyle = .Custom
                modalViewController.modalTransitionStyle = .CrossDissolve
                vc.presentViewController(modalViewController, animated: true, completion: nil)
            }
            
        }
    }

}
