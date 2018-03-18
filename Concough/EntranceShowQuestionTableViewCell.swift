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

class EntranceShowQuestionTableViewCell: UITableViewCell {

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
    
    private var viewController: UIViewController!
    private var viewControllerType: String!
    private var oldConstraint2: NSLayoutConstraint?
    private var oldConstraint3: NSLayoutConstraint?

    private var questionId: String!
    private var starState: Bool!
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
        
        self.setNeedsLayout()
        self.updateConstraintsIfNeeded()
    }
    
    override func drawRect(rect: CGRect) {
        self.questionNumberLabel.layer.cornerRadius = self.questionNumberLabel.layer.frame.width / 2.0
        self.questionNumberLabel.layer.masksToBounds = true
        
        self.questionNumberLabel.layer.borderColor = self.questionNumberLabel.textColor.CGColor
        self.questionNumberLabel.layer.borderWidth = 2.0
        
        //self.showAnswer.layer.borderColor = self.showAnswer.currentTitleColor.CGColor
        //self.showAnswer.layer.borderWidth = 0.7
        //self.showAnswer.layer.cornerRadius = 3.0
        //self.showAnswer.layer.masksToBounds = true        
    }
    
    internal func configureCell(viewController viewController: UIViewController, vcType: String, question: Int, questionId: String, answer: Int, starred: Bool, images: [NSData], showAnswer: Bool) {
        self.questionNumberLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(question)!
        self.answerLabel.text = "گزینه " + questionAnswerToString(answer) + " درست است"
        self.answerLabel.hidden = !showAnswer
        
        if (showAnswer) {
            self.showAnswer.setTitleColor(UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.3), forState: .Normal)
            self.showAnswerImage.tintImageColor(UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.3))
        } else {
            self.showAnswer.setTitleColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
            self.showAnswerImage.tintImageColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0))
            
        }
        
        self.viewController = viewController
        self.viewControllerType = vcType
        
        self.questionId = questionId
        self.questionNumber = question
        self.starState = starred
        
        self.showAnswer.addTarget(self, action: #selector(self.answerShowClicked(_:)), forControlEvents: .TouchUpInside)
        self.starButton.addTarget(self, action: #selector(self.starButtonPressed(_:)), forControlEvents: .TouchUpInside)
        self.changeStarState(state: starred)
        self.insertImages(images: images)
    }
    
    @IBAction func answerShowClicked(sender: UIButton) {
        self.answerLabel.hidden = false
        self.showAnswer.setTitleColor(UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.3), forState: .Normal)
        self.showAnswerImage.tintImageColor(UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 0.3))
        
        if let vc = self.viewController as? EntranceShowTableViewController {
            vc.addAnsweredQuestionId(questionId: self.questionId)
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
    
    internal func changeStarState(state state: Bool) {

        if state == true {
            self.starButton.setImage(UIImage(named: "BookmarkRibbonFilled"), forState: .Normal)
            self.starButton.tintColor = UIColor(netHex: RED_COLOR_HEX_2, alpha: 1.0)
        } else {
            self.starButton.setImage(UIImage(named: "BookmarkRibbon"), forState: .Normal)
            self.starButton.tintColor = UIColor.darkGrayColor()
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
