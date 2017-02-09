//
//  SignUpViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-28.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import MBProgressHUD

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    private var signupStruct: SignupStructure!
    private var isUsernameValid: Bool = false
    private var isEmailValid: Bool = false
    private var mainUsernameText: String!
    
    private var activeTextField: UITextField?
    private var loading: MBProgressHUD?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var SignupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailMsgStackView: UIStackView!
    @IBOutlet weak var emailMsgLabel: UILabel!
    @IBOutlet weak var usernameMsgLabel: UILabel!
    @IBOutlet weak var usernameMsgRefreshControl: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signupStruct = SignupStructure()
        
        // customize views
        self.SignupButton.layer.cornerRadius = 5
        self.loginButton.layer.cornerRadius = 3
        self.loginButton.layer.borderWidth = 1.0
        self.loginButton.layer.borderColor = self.loginButton.titleLabel?.textColor.CGColor
        
        self.mainUsernameText = self.usernameMsgLabel.text
        self.usernameMsgRefreshControl.stopAnimating()
        self.emailMsgStackView.hidden = true
        
        // make text fields properties
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.usernameTextField.delegate = self
        
        // Set Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        // Gesture Recognizer functions
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTapped(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        self.scrollView.addGestureRecognizer(singleTapGestureRecognizer)
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
    
    // MARK - Actions
    @IBAction func signupButtonPressed(sender: UIButton) {
        if let email = self.emailTextField.text where email != "", let pass = self.passwordTextField.text where pass != "", let username = self.usernameTextField.text where username != "" {
           
            if self.isUsernameValid && self.isEmailValid {
                self.signupStruct.username = username
                self.signupStruct.password = pass
                self.signupStruct.email = email

                self.makePreSignup(username: username, email: email, password: pass)
            }
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.showAlertMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "warning", completion: nil)
            })
        }
    }
    
    // MARK: - Functions
    private func makePreSignup(username username: String, email: String, password: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        AuthRestAPIClass.preSignup(username: username, email: email, completion: { (data, error) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error == HTTPErrorType.Success {
                // data will returned
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            //print("preSignup successful.")
                            // ok --> navigate to other window
                            if let id = localData["id"].int {
                                self.signupStruct.preSignupId = id
                                
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.performSegueWithIdentifier("SubmitSignupCodeVCSegue", sender: self)
                                })
                            } else {
                                // id field not exist
                            }
                            break
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                    case "ExistUsername":
                                        self.usernameMsgLabel.text = "این نام کاربری قبلا انتخاب شده است"
                                        self.usernameMsgLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
                                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, completion: nil)
                                    default:
                                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                        default: break
                        }
                    }
                }
            } else {
                // error exist with network
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                })
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
//                            self.makePreSignup(username: username, email: email, password: password)
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
    
    private func checkUsername(username username: String) {
        AuthRestAPIClass.checkUsername(username: username, completion: { (data, error) in
            self.usernameMsgRefreshControl.stopAnimating()
            if error == HTTPErrorType.Success {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            //print("Signup OK received")
                            self.isUsernameValid = true
                            self.usernameMsgLabel.text = "نام کاربری انتخاب شده صحیح است"
                            self.usernameMsgLabel.textColor = UIColor(netHex: GREEN_COLOR_HEX, alpha: 1.0)
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "ExistUsername":
                                    self.usernameMsgRefreshControl.stopAnimating()
                                    self.usernameMsgLabel.text = "این نام کاربری قبلا انتخاب شده است"
                                    self.usernameMsgLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
                                    
                                default:
                                    self.usernameMsgLabel.text = self.mainUsernameText
                                    self.usernameMsgLabel.textColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 1.0)
                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            } else {
                // show alert
                self.usernameMsgLabel.text = self.mainUsernameText
                self.usernameMsgLabel.textColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 1.0)
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                })
            }
        }, failure: { (error) in
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
//                            self.checkUsername(username: username)
//                        })
//                    })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
                    break
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
        
        if textField == self.usernameTextField {
            // chack for valid username with server
            self.usernameMsgLabel.text = self.mainUsernameText
            self.usernameMsgLabel.textColor = UIColor(netHex: GRAY_COLOR_HEX_1, alpha: 1.0)
            
            if let username = textField.text where username != "" {
                if username.isValidUsername {
                    self.emailMsgStackView.hidden = false
                    self.usernameMsgRefreshControl.startAnimating()
                    
                    self.checkUsername(username: username)
                } else {
                    //print("invalid username")
                    self.usernameMsgLabel.text = "نام کاربری وارد شده صحیح نمی باشد"
                    self.usernameMsgLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
                }
            }
            
        } else if textField == self.emailTextField {
            if let email = self.emailTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                
                if email.isValidEmail {
                    self.isEmailValid = true
                    self.emailMsgLabel.text = ""
                    self.emailMsgStackView.hidden = true
                } else {
                    self.isEmailValid = false
                    self.emailMsgLabel.text = "ایمیل معتبر وارد نمایید"
                    self.emailMsgLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
                    self.emailMsgStackView.hidden = false
                }
            }
        } else if textField == self.passwordTextField {
            // validate password
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == self.usernameTextField {
            self.emailTextField.becomeFirstResponder()
            
            
        } else if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SubmitSignupCodeVCSegue" {
            if let destVC = segue.destinationViewController as? SubmitSignupCodeViewController {
                destVC.signupStruct = self.signupStruct
                destVC.fromVC = "SignupVC"
            }
        } 
    }    
}
