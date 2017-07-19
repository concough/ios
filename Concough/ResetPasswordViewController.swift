//
//  ResetPasswordViewController.swift
//  Concough
//
//  Created by Owner on 2016-12-12.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import MBProgressHUD

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    internal var resetCode: Int!
    internal var signupStruct: SignupStructure!
    
    private var activeTextField: UITextField!
    private var loading: MBProgressHUD?
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retryPasswordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI Customizations
        self.resetButton.layer.cornerRadius = 5.0
        
        // set delegates
        self.passwordTextField.delegate = self
        self.retryPasswordTextField.delegate = self
        
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
    
    @IBAction func resetPasswordFuncPressed(sender: UIButton) {
        if let pass1 = self.passwordTextField.text?.trim() where pass1 != "", let pass2 = self.retryPasswordTextField.text?.trim() where pass2 != "" {
            
            if pass1 == pass2 {
                // make request
                self.resetPassword(password1: pass1, password2: pass2)
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "NotSameFields", type: "error", completion: nil)
                })                
            }
            
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "error", completion: nil)
            })
        }
    }
    
    // MARK: - Functions
    private func resetPassword(password1 pass1: String, password2 pass2: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        AuthRestAPIClass.resetPassword(username: self.signupStruct.username!, id: self.signupStruct.preSignupId!, password: pass1, rpassword: pass2, code: self.resetCode, completion: { (data, error) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            if error != HTTPErrorType.Success {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                })
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            TokenHandlerSingleton.sharedInstance.setUsernameAndPassword(username: self.signupStruct.username!, password: pass1)
                            self.startup()
                            // forgot password generate
//                            NSOperationQueue.mainQueue().addOperationWithBlock({
//                                self.performSegueWithIdentifier("StartupVCSegue", sender: self)
//                            })
//                            NSOperationQueue.mainQueue().addOperationWithBlock({
//                                self.performSegueWithIdentifier("HomeVCSegue", sender: self)
//                            })
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "ExpiredCode":
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        AlertClass.showAlertMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, type: "error", completion: { 
                                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                                self.performSegueWithIdentifier("ForgotPasswordResendVCUnSegue", sender: self)
                                            })
                                        })
                                    })
                                case "UserNotExist":
                                    fallthrough
                                case "PreAuthNotExist":
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        AlertClass.showTopMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: nil)
                                        self.performSegueWithIdentifier("ForgotPasswordVCUnSegue", sender: self)
                                    })
                                case "MultiRecord":
                                    fallthrough
                                case "BadData":
                                    fallthrough
                                case "RemoteDBError":
                                    fallthrough
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
//                            self.resetPassword(password1: pass1, password2: pass2)
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
    
    private func startup() {
        if TokenHandlerSingleton.sharedInstance.isAuthorized() {
            if UserDefaultsSingleton.sharedInstance.hasProfile() {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                }
            } else {
                // get profile
                self.getProfile()
            }
        } else if TokenHandlerSingleton.sharedInstance.isAuthenticated() {
            TokenHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, error) in
                if authenticated {
                    print("StartupViewController: Authenticated")
                    if UserDefaultsSingleton.sharedInstance.hasProfile() {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                        }
                    } else {
                        // get profile
                        self.getProfile()
                    }
                } else {
                    print("StartupViewController: Not Authenticated")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                    }
                }
                }, failure: { (error) in
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                    }
                    
                    //                if let err = error {
                    //                    switch err {
                    //                    case .NoInternetAccess:
                    //                        fallthrough
                    //                    case .HostUnreachable:
                    //                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    //
                    ////                            AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                    ////                                NSOperationQueue.mainQueue().addOperationWithBlock({
                    ////                                    self.startup()
                    ////                                })
                    ////                            })
                    //                    default:
                    //                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    //                    }
                    //                }
            })
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("LogInVCSegue", sender: self)
            }            
        }
    }
    
    private func getProfile() {
        ProfileRestAPIClass.getProfileData({ (data, error) in
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.getProfile()
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                    })
                }
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            // profile exist
                            let profile = localData["record"][0]
                            
                            // save profile
                            if let gender = profile["gender"].string, let grade = profile["grade"].string, let birthday = profile["birthday"].string, let modified = profile["modified"].string, let firstname = profile["user"]["first_name"].string, let lastname = profile["user"]["last_name"].string {
                                
                                let modifiedDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(modified)
                                let birthdayDate = FormatterSingleton.sharedInstance.UTCShortDateFormatter.dateFromString(birthday)
                                
                                UserDefaultsSingleton.sharedInstance.createProfile(firstname: firstname, lastname: lastname, grade: grade, gender: gender, birthday: birthdayDate!, modified: modifiedDate!)
                            }
                            
                            if UserDefaultsSingleton.sharedInstance.hasProfile() {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                                })
                            } else {
                                // profile not created --> try again
                            }
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "ProfileNotExist":
                                    // profile not exist --> perform navigation
                                    fallthrough
                                default:
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                                    })
                                }
                            }
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
                        fallthrough
                    case .HostUnreachable:
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                        
                        //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        //                        NSOperationQueue.mainQueue().addOperationWithBlock({
                        //                            self.getProfile()
                        //                        })
                    //                    })
                    default:
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    }
                }
        })
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
        if textField == self.passwordTextField {
            self.retryPasswordTextField.becomeFirstResponder()
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

    // MARK: - Gusture Recognizer implementations
    func singleTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StartupVCSegue" {
        }
    }
 
}
