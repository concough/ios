//
//  SignupMoreInfoViewController1.swift
//  Concough
//
//  Created by Owner on 2016-12-10.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class SignupMoreInfoViewController1: UIViewController, UITextFieldDelegate {
    
    internal var infoStruct:SignupMoreInfoStruct!
    private var activeTextField: UITextField!
    private var selectedGender: GenderEnum?
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var maleImageView: UIImageView!
    @IBOutlet weak var femaleImageView: UIImageView!
    @IBOutlet weak var otherImageView: UIImageView!
    @IBOutlet weak var maleUILabel: UILabel!
    @IBOutlet weak var femaleUILabel: UILabel!
    @IBOutlet weak var otherUILabel: UILabel!
    @IBOutlet weak var nextBarItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoStruct = SignupMoreInfoStruct();
        self.selectedGender = GenderEnum.Male
        
        // setting delegates
        self.firstnameTextField.delegate = self
        self.lastnameTextField.delegate = self
        
        // customize UI
        self.ConfigureImageUIDefault()
        
        let attributes = NSDictionary(object: UIFont(name: "IRANYekanMobile-Bold", size: 14)! , forKey: NSFontAttributeName) as! [String: AnyObject]
        self.nextBarItem.setTitleTextAttributes(attributes, forState: .Normal)
        
        //self.genderSegmentControl.layer.cornerRadius = 5.0
        //self.genderSegmentControl.setTitleTextAttributes(attributes as [NSObject : AnyObject], forState: .Normal)
        
        // Set Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        // Gesture Recognizer functions
        let maleImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(_:)))
        maleImageTapGestureRecognizer.numberOfTapsRequired = 1
        maleImageTapGestureRecognizer.numberOfTouchesRequired = 1
        let femaleImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(_:)))
        femaleImageTapGestureRecognizer.numberOfTapsRequired = 1
        femaleImageTapGestureRecognizer.numberOfTouchesRequired = 1
        let otherImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(_:)))
        otherImageTapGestureRecognizer.numberOfTapsRequired = 1
        otherImageTapGestureRecognizer.numberOfTouchesRequired = 1

        self.maleImageView.userInteractionEnabled = true
        self.femaleImageView.userInteractionEnabled = true
        self.otherImageView.userInteractionEnabled = true
        self.maleImageView.addGestureRecognizer(maleImageTapGestureRecognizer)
        self.femaleImageView.addGestureRecognizer(femaleImageTapGestureRecognizer)
        self.otherImageView.addGestureRecognizer(otherImageTapGestureRecognizer)
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTapped(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        self.scrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        if let firstname = self.infoStruct.firstname where firstname != "" {
            self.firstnameTextField.text = firstname
        }
        if let lastname = self.infoStruct.lastname where lastname != "" {
            self.lastnameTextField.text = lastname
        }
        if let gender = self.infoStruct.gender {
            self.selectedGender = GenderEnum(rawValue: gender)
        }
        self.ConfigureImageUISelected()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    // MARK: - TextField Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == self.firstnameTextField {
            self.lastnameTextField.becomeFirstResponder()
        }
        return true
    }
    
    // MARK: - Notifications Implementations
    func keyboardWillShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardSize: CGSize = (userInfo["UIKeyboardFrameBeginUserInfoKey"]?.CGRectValue().size)!
            
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            // if active text field is hidden by keyboard, scroll it so it's visible
            var aRect: CGRect = self.view.frame
            aRect.size.height -= keyboardSize.height
            
            if self.activeTextField != nil {
                if !CGRectContainsPoint(aRect, (self.activeTextField?.frame.origin)!) {
                    self.scrollView.scrollRectToVisible((self.activeTextField?.frame)!, animated: true)
                }
            }
            
        }
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: - Gesture Recognizer Implementations
    func singleTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        //print("next button pressed")
        if let firstname = self.firstnameTextField.text?.trim() where firstname != "", let lastname = self.lastnameTextField.text?.trim() where lastname != "" {
            
            self.infoStruct.firstname = firstname
            self.infoStruct.lastname = lastname
            self.infoStruct.gender = self.selectedGender!.rawValue
            
            self.performSegueWithIdentifier("SignupMoreInfoVC2Segue", sender: self)
        }
        else {
            AlertClass.showSimpleErrorMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", completion: nil)
        }
    }
    
    // MARK: - Functions
    private func ConfigureImageUIDefault() {
        self.maleImageView.layer.masksToBounds = true
        self.maleImageView.layer.cornerRadius = 30.0
        self.maleImageView.layer.borderWidth = 1.0
        self.maleImageView.layer.borderColor = UIColor.init(netHex: GRAY_COLOR_HEX_1, alpha: 0.5).CGColor
        self.maleUILabel.textColor = UIColor.init(netHex: GRAY_COLOR_HEX_1, alpha: 1.0)

        self.femaleImageView.layer.masksToBounds = true
        self.femaleImageView.layer.cornerRadius = 30.0
        self.femaleImageView.layer.borderWidth = 1.0
        self.femaleImageView.layer.borderColor = UIColor.init(netHex: GRAY_COLOR_HEX_1, alpha: 0.5).CGColor
        self.femaleUILabel.textColor = UIColor.init(netHex: GRAY_COLOR_HEX_1, alpha: 1.0)

        self.otherImageView.layer.masksToBounds = true
        self.otherImageView.layer.cornerRadius = 30.0
        self.otherImageView.layer.borderWidth = 1.0
        self.otherImageView.layer.borderColor = UIColor.init(netHex: GRAY_COLOR_HEX_1, alpha: 0.5).CGColor
        self.otherUILabel.textColor = UIColor.init(netHex: GRAY_COLOR_HEX_1, alpha: 1.0)

    }
    
    private func ConfigureImageUISelected() {
        if let gender = self.selectedGender {
            switch gender {
            case .Male:
                // male selected
                self.maleImageView.layer.borderWidth = 2.0
                self.maleImageView.layer.borderColor = UIColor.init(netHex: BLUE_COLOR_HEX, alpha: 1.0).CGColor
                self.maleUILabel.textColor = UIColor.init(netHex: BLUE_COLOR_HEX, alpha: 1.0)
                
            case .Female:
                // female selected
                self.femaleImageView.layer.borderWidth = 2.0
                self.femaleImageView.layer.borderColor = UIColor.init(netHex: BLUE_COLOR_HEX, alpha: 1.0).CGColor
                self.femaleUILabel.textColor = UIColor.init(netHex: BLUE_COLOR_HEX, alpha: 1.0)

            case .Other:
                // other selected
                self.otherImageView.layer.borderWidth = 2.0
                self.otherImageView.layer.borderColor = UIColor.init(netHex: BLUE_COLOR_HEX, alpha: 1.0).CGColor
                self.otherUILabel.textColor = UIColor.init(netHex: BLUE_COLOR_HEX, alpha: 1.0)
            }
        }
    }
    
    func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        if let tappedImageView = gestureRecognizer.view as? UIImageView {
            if tappedImageView == self.maleImageView {
                self.selectedGender = GenderEnum.Male
                self.ConfigureImageUIDefault()
                self.ConfigureImageUISelected()
                
            } else if tappedImageView == self.femaleImageView {
                self.selectedGender = GenderEnum.Female
                self.ConfigureImageUIDefault()
                self.ConfigureImageUISelected()
                
            } else if tappedImageView == self.otherImageView {
                self.selectedGender = GenderEnum.Other
                self.ConfigureImageUIDefault()
                self.ConfigureImageUISelected()
                
            }
        }
    }
    
     // MARK: - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "SignupMoreInfoVC2Segue" {
            if let firstname = self.firstnameTextField.text?.trim() where firstname != "", let lastname = self.lastnameTextField.text?.trim() where lastname != "" {
                
                self.infoStruct.firstname = firstname
                self.infoStruct.lastname = lastname
                self.infoStruct.gender = self.selectedGender!.rawValue
                
                return true
            }
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SignupMoreInfoVC2Segue" {
            if let nextVC = segue.destinationViewController as? SignupMoreInfoViewController2 {
                nextVC.infoStruct = self.infoStruct
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "اطلاعات تکمیلی", style: .Plain, target: self, action: nil)
            }
        }
    }
}
