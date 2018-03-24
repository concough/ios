//
//  ChangePasswordViewController.swift
//  Concough
//
//  Created by Owner on 2017-02-06.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit
import MBProgressHUD

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    private var activeTextField: UITextField!
    private var loading: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI Customizations
        self.submitButton.layer.cornerRadius = 5.0
        
        // set delegates
        self.oldPasswordTextField.delegate = self
        self.newPasswordTextField.delegate = self
        
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
    
    // MARK: - Actions
    @IBAction func submitButtonPressed(sender: UIButton) {
        if let pass1 = self.oldPasswordTextField.text?.trim() where pass1 != "", let pass2 = self.newPasswordTextField.text?.trim() where pass2 != "" {
            
//            if UserDefaultsSingleton.sharedInstance.chackPassword(password: pass1) == true {
            
                self.changePassword(oldPassword: pass1, newPassword: pass2)
                
//            } else {
//                NSOperationQueue.mainQueue().addOperationWithBlock({ 
//                    AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "OldPasswordNotCorrect", type: "error", completion: nil)
//                })
//            }
            
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "error", completion: nil)
            })
        }
    }
    
    // MARK: - Functions
    private func changePassword(oldPassword pass1: String, newPassword pass2: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        AuthRestAPIClass.changePassword(oldPassword: pass1, newPassword: pass2, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.changePassword(oldPassword: pass1, newPassword: pass2)
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
                            let modifiedStr = localData["modified"].stringValue
                            let modified = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(modifiedStr)
                            
                            AlertClass.showAlertMessage(viewController: self, messageType: "ActionResult", messageSubType: "ChangePasswordSuccess", type: "success", completion: {
                                self.changeSetting(newPassword: pass2, modified: modified!)
                            })
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "PassCannotChange":
                                    fallthrough
                                case "FieldTooSmall":
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        AlertClass.showTopMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: nil)
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
        }) { (error) in
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
                    //                            AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                    //                                NSOperationQueue.mainQueue().addOperationWithBlock({
                    //                                    self.login()
                    //                                })
                //                            })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
                }
            }
        }
    }
    
    private func changeSetting(newPassword pass2: String, modified: NSDate) {
        // lets login again
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        TokenHandlerSingleton.sharedInstance.setUsernameAndPassword(username: username, password: pass2)
        KeyChainAccessProxy.setValue(PASSWORD_KEY, value: pass2)

        UserDefaultsSingleton.sharedInstance.updateModified(modified: modified)
        
        TokenHandlerSingleton.sharedInstance.authorize({ (error) in
            if error == .Success {
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    if self.navigationController != nil {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
            } else {
                // error exist
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                })
            }
            
        }) { (error) in
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    fallthrough
                case .HostUnreachable:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    })
                    //                            AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                    //                                NSOperationQueue.mainQueue().addOperationWithBlock({
                    //                                    self.login()
                    //                                })
                //                            })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
                }
            }
        }
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
        if textField == self.oldPasswordTextField {
            self.newPasswordTextField.becomeFirstResponder()
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

}
