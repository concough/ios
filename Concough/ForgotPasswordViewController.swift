//
//  ForgotPasswordViewController.swift
//  Concough
//
//  Created by Owner on 2016-12-12.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import MBProgressHUD

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    private var activeTextField: UITextField?
    private var signupStruct: SignupStructure!
    private var loading: MBProgressHUD?
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var send_type: String = "sms" {
        didSet {
            if send_type == "call" {
                self.sendCodeButton.setTitle("ارسال کد از طریق تماس", forState: .Normal)
            } else if send_type == "sms" {
                self.sendCodeButton.setTitle("ارسال کد", forState: .Normal)
            } else {
                self.sendCodeButton.setTitle("فردا سعی نمایید ..", forState: .Normal)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signupStruct = SignupStructure()
        
        // UI Customization
        self.sendCodeButton.layer.cornerRadius = 5.0

        self.loginButton.layer.cornerRadius = 3.0
        self.loginButton.layer.borderWidth = 1.0
        self.loginButton.layer.borderColor = self.loginButton.titleLabel?.textColor.CGColor

        self.returnButton.layer.cornerRadius = 3.0
        self.returnButton.layer.borderWidth = 1.0
        self.returnButton.layer.borderColor = self.returnButton.titleLabel?.textColor.CGColor
        
        // set delegates
        self.usernameTextField.delegate = self
        self.usernameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
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
    
    @IBAction func textFieldDidChange(textField: UITextField) {
        if textField.text?.trim()?.characters.count > 0 {
            textField.textAlignment = .Left
            textField.semanticContentAttribute = .ForceLeftToRight
        } else {
            textField.textAlignment = .Center
            textField.semanticContentAttribute = .ForceRightToLeft
        }
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
    @IBAction func returnButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendCodeButtonPressed(sender: UIButton) {
        // sending procedure
        if var username = self.usernameTextField.text?.trim() where username != "" {
            if username.isValidPhoneNumber {
                if username.hasPrefix("0") {
                    username = username.substringFromIndex(username.startIndex.advancedBy(1))
                }
                username = "98" + username
                
                self.forgotPassword(username: username)
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "PhoneVerifyWrong", type: "error", completion: nil)
                })
            }
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "error", completion: nil)
            })
        }
    }
    
    // MARK: - Functions
    private func forgotPassword(username username: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        AuthRestAPIClass.forgotPassword(username: username, send_type: self.send_type, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.forgotPassword(username: username)
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                    })
                }
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
                                case "UserNotExist":
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                        AlertClass.showTopMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: nil)
                                    })
                                case "SMSSendError": fallthrough
                                case "CallSendError":
                                    AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: nil)
                                case "ExceedToday":
                                    AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: {
                                        
                                        self.send_type = "call"
                                    })
                                case "ExceedCallToday":
                                    AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: {
                                        
                                        self.send_type = ""
                                    })
                                
                                case "BadData":
                                    fallthrough
                                case "RemoteDBError":
                                    fallthrough
                                default:
                                    AlertClass.showAlertMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, type: "error", completion: nil)
//                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
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
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    fallthrough
                case .HostUnreachable:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    })
//                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
//                            self.forgotPassword(username: username)
//                        })
//                    })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
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
