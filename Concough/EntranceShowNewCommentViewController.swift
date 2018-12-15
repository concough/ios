//
//  EntranceCommentViewController.swift
//  Concough
//
//  Created by Owner on 2018-03-31.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

class EntranceShowNewCommentViewController: UIViewController, UITextViewDelegate {
    private let MAX_CHARACTER_COUNT = 255

    @IBOutlet weak var commentCotainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var commentCharCountLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    internal var questionUniqueId: String!
    internal var questionNo: Int!
    internal var indexPath: NSIndexPath!
    internal var commentDelegate: EntranceShowCommentDelegate?
    
    private var commentType: EntranceCommentType = .TEXT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.opaque = false
        
        self.commentCotainer.layer.cornerRadius = 5.0
        self.commentCotainer.layer.masksToBounds = true
//        self.commentCotainer.layer.borderColor = UIColor.darkGrayColor().CGColor
//        self.commentCotainer.layer.borderWidth = 1.0
        
        self.submitButton.layer.cornerRadius = 5.0
        self.submitButton.layer.masksToBounds = true
        
        
        self.commentTextView.becomeFirstResponder()
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.mainViewTapped(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.enabled = true
        
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(singleTapGestureRecognizer)
        
        self.commentTextView.delegate = self
        
        // configure
        self.titleLabel.text = "  سوال \(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(questionNo)!)"
        
        let allowChar = self.MAX_CHARACTER_COUNT - self.commentTextView.text.characters.count
        self.commentCharCountLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(allowChar)!) کاراکتر"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mainViewTapped(sender: UITapGestureRecognizer) {
        if self.commentTextView.isFirstResponder() {
            self.view.endEditing(true)
        } else {
            if let delegate = self.commentDelegate {
                delegate.cancelComment()
            }
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        if self.commentTextView.text.trim()?.characters.count > 0 {
        self.view.endEditing(true)
        self.disableSubmitButton(state: true)
        if let delegate = self.commentDelegate {
            if self.commentType == .TEXT {
                let eData = JSON(["text": self.commentTextView.text, "questionNo": self.questionNo])
                
                let result = delegate.addTextComment(questionId: self.questionUniqueId, questionNo: self.questionNo, indexPath: self.indexPath, commentData: eData.rawString()!)
                
                if result {
                    self.dismissViewControllerAnimated(false, completion: nil)
                } else {
                    self.disableSubmitButton(state: false)
                    self.errorLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
                    self.errorLabel.text = "خطا! لطقا دوباره سعی نمایید."
                    self.errorLabel.hidden = false
                }
            } else {
                self.disableSubmitButton(state: false)
            }
        } else {
            self.disableSubmitButton(state: false)
        }
        } else {
            let s = AlertClass.convertMessage(messageType: "Form", messageSubType: "EmptyFields")
            self.errorLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
            self.errorLabel.text = s.message
            self.errorLabel.hidden = false
        }
    }
    
    private func disableSubmitButton(state state: Bool) {
        if state {
            self.submitButton.enabled = false
            self.submitButton.backgroundColor = UIColor.grayColor()
        } else {
            self.submitButton.enabled = true
            self.submitButton.backgroundColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let allowChar = self.MAX_CHARACTER_COUNT - self.commentTextView.text.characters.count
        self.commentCharCountLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(allowChar)!) کاراکتر"
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count
        return numberOfChars <= self.MAX_CHARACTER_COUNT
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
