//
//  EntranceShowQuestionExamTableViewCell.swift
//  Concough
//
//  Created by Owner on 2018-04-03.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON
import RNCryptor

class EntranceShowQuestionExamTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionImageView1: UIImageView!
    @IBOutlet weak var questionImageView2: UIImageView!
    @IBOutlet weak var questionImageView3: UIImageView!
    @IBOutlet weak var questionImageConstraint2: NSLayoutConstraint?
    @IBOutlet weak var questionImageConstraint3: NSLayoutConstraint?
    
    @IBOutlet weak var answer1Button: UIButton!
    @IBOutlet weak var answer2Button: UIButton!
    @IBOutlet weak var answer3Button: UIButton!
    @IBOutlet weak var answer4Button: UIButton!
    @IBOutlet weak var answerEraserImageView: UIImageView!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    
    @IBOutlet weak var backLabel: UILabel!
    
    private var viewController: UIViewController!
    private var viewControllerType: String!
    private var oldConstraint2: NSLayoutConstraint?
    private var oldConstraint3: NSLayoutConstraint?
    
    private var indexPath: NSIndexPath!
    private var questionId: String!
    private var questionNumber: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        // Initialization code
        self.questionImageView1.hidden = true
        self.questionImageView2.hidden = true
        self.questionImageView3.hidden = true
        
        self.oldConstraint2 = self.questionImageConstraint2
        self.oldConstraint3 = self.questionImageConstraint3
        self.answersDefaultState()
        self.resetAnswerButton()
        self.setAnswerButton(0)
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
        self.resetAnswerButton()
        
        self.setNeedsLayout()
        self.updateConstraintsIfNeeded()
    }
    
    override func drawRect(rect: CGRect) {
//        self.questionNumberLabel.layer.cornerRadius = self.questionNumberLabel.layer.frame.width / 2.0
//        self.questionNumberLabel.layer.masksToBounds = true
//        self.questionNumberLabel.layer.borderColor = self.questionNumberLabel.textColor.CGColor
//        self.questionNumberLabel.layer.borderWidth = 2.0
        
        self.backLabel.layer.cornerRadius = self.backLabel.layer.frame.height / 2.0
        self.backLabel.layer.masksToBounds = true
        
    }
    
    internal func configureCell(viewController viewController: UIViewController, vcType: String, indexPath: NSIndexPath, question: Int, questionId: String, images: [NSData], lastQuestionNo: Int, answered: Int, correctAnswer: Int, showType: String) {
        self.questionNumberLabel.text = "سوال " + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(question)! + " از " + FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(lastQuestionNo)!
        
        self.viewController = viewController
        self.viewControllerType = vcType
        
        self.indexPath = indexPath
        self.questionId = questionId
        self.questionNumber = question
        
        self.insertImages(images: images)
        
        if showType == "Exam" {
            self.answerEraserImageView.hidden = false
            self.correctAnswerLabel.hidden = true
            
            self.answer1Button.addTarget(self, action: #selector(self.answerClicked(_:)), forControlEvents: .TouchUpInside)
            self.answer2Button.addTarget(self, action: #selector(self.answerClicked(_:)), forControlEvents: .TouchUpInside)
            self.answer3Button.addTarget(self, action: #selector(self.answerClicked(_:)), forControlEvents: .TouchUpInside)
            self.answer4Button.addTarget(self, action: #selector(self.answerClicked(_:)), forControlEvents: .TouchUpInside)
            
            let singleTapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(self.anserEraserPressed(_:)))
            singleTapGestureRecognizer2.numberOfTapsRequired = 1
            singleTapGestureRecognizer2.numberOfTouchesRequired = 1
            singleTapGestureRecognizer2.enabled = true

            self.answerEraserImageView.userInteractionEnabled = true
            self.answerEraserImageView.addGestureRecognizer(singleTapGestureRecognizer2)
            
            if answered > 0 {
                self.setAnswerButton(answered)
            }
        } else if showType == "ExamResult" {
            self.answerEraserImageView.hidden = true
            self.correctAnswerLabel.hidden = false
            self.correctAnswerLabel.text = questionAnswerToString(correctAnswer) + " ✔︎"
            
            let convert = translateAnswer(answer: correctAnswer)
            if convert.contains(answered) {
                self.setAnswerButton(answered, answerState: 1)
            } else {
                self.setAnswerButton(answered, answerState: -1)
            }
        }
    }
    
    private func translateAnswer(answer answer: Int) -> [Int] {
        switch answer {
        case 0: fallthrough
        case 1: fallthrough
        case 2: fallthrough
        case 3: fallthrough
        case 4:
            return [answer]
        case 5:
            return [1, 2]
        case 6:
            return [1, 3]
        case 7:
            return [1, 4]
        case 8:
            return [2, 3]
        case 9:
            return [2, 4]
        case 10:
            return [3, 4]
        default:
            return []
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

    @IBAction func answerClicked(sender: UIButton) {
        self.resetAnswerButton()
        self.setAnswerButton(sender.tag)
        
        if self.viewControllerType == "E" {
            if let vc = self.viewController as? EntranceShowTableViewController {
                vc.lessonExamQuestionAnswered(indexPath: self.indexPath, questionId: self.questionId, answer: sender.tag)
            }
        }
    }
    
    @IBAction func anserEraserPressed(sender: UIGestureRecognizer) {
        self.resetAnswerButton()
        self.setAnswerButton(0)
        if self.viewControllerType == "E" {
            if let vc = self.viewController as? EntranceShowTableViewController {
                vc.lessonExamQuestionCleared(indexPath: self.indexPath, questionId: self.questionId)
            }
        }
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
