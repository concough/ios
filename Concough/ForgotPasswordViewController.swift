//
//  ForgotPasswordViewController.swift
//  Concough
//
//  Created by Owner on 2016-12-12.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    private var activeTextField: UITextField?
    private var signupStruct: SignupStructure!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signupStruct = SignupStructure()
        
        // UI Customization
        self.sendCodeButton.layer.cornerRadius = 5.0

        self.loginButton.layer.cornerRadius = 3.0
        self.loginButton.layer.borderWidth = 1.0
        self.loginButton.layer.borderColor = self.loginButton.titleLabel?.textColor.CGColor
        
        // set delegates
        self.usernameTextField.delegate = self
        
        // set notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        // GestureRecognizer functions
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTapped(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        self.scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    // MARK: - Actions
    @IBAction func sendCodeButtonPressed(sender: UIButton) {
        // sending procedure
        if let username = self.usernameTextField.text?.trim() where username != "" {
            self.forgotPassword(username: username)
        } else {
            AlertClass.showSimpleErrorMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", completion: nil)
        }
    }
    
    // MARK: - Functions
    private func forgotPassword(username username: String) {
        AuthRestAPIClass.forgotPassword(username: username, completion: { (data, error) in
            if error != HTTPErrorType.Success {
                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            // forgot password generate
                            self.signupStruct.username = username
                            self.signupStruct.preSignupId = localData["id"].intValue
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.performSegueWithIdentifier("SubmitSignupCodeVCSegue", sender: self)
                            })
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "BadData":
                                    fallthrough
                                case "RemoteDBError":
                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "HTTPError", messageSubType: errorType, completion: nil)
                                    break
                                case "UserNotExist":
                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, completion: nil)
                                    break
                                default:
                                    break
                                }
                            }
                            break
                        default:
                            break
                        }
                    }
                }
            }
        }, failure: { (error) in
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
                            self.forgotPassword(username: username)
                        })
                    })
                default:
                    break
                }
            }
        })
    }
    
    // MARK: - Gusture Recognizer implementations
    func singleTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: - Unwind Segues
    @IBAction func unwindForgotPasswordPressed(segue: UIStoryboardSegue) {
        //print("Reset Password Unwind Segue")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubmitSignupCodeVCSegue" {
            if let nextVC = segue.destinationViewController as? SubmitSignupCodeViewController {
                nextVC.fromVC = "ForgotPasswordVC"
                nextVC.signupStruct = self.signupStruct
            }
        }
    }
}
