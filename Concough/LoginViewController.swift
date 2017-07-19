//
//  LoginViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-28.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {

    var savedUsername: String?
    
    private var activeTextField: UITextField?
    private var loading: MBProgressHUD?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // customize uibutton
        self.loginButton.layer.cornerRadius = 5
        
        // make text fields properties
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        //self.emailTextField.becomeFirstResponder()
        
        // Set Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
        // GestureRecognizer functions
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTapped(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        self.scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
        // Some Initializations
        if let username = self.savedUsername {
            self.emailTextField.text = username
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    // MARK: - Actions
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        self.login()
    }
    
    // MARK: - Functions
    private func login() {
        if let email = emailTextField.text where email != "", let pass = passwordTextField.text where pass != "" {
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.loading = AlertClass.showLoadingMessage(viewController: self)
            })
            // email and password entered correctly
            var username = email
            if username.hasPrefix("0") {
                username = username.substringFromIndex(username.startIndex.advancedBy(1))
            }
            username = "98" + username
            
            TokenHandlerSingleton.sharedInstance.setUsernameAndPassword(username: username, password: pass)
            
            TokenHandlerSingleton.sharedInstance.authorize({ (error) in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                })

                if error == .Success {
                    
                    // login passed successfully
                    if TokenHandlerSingleton.sharedInstance.isAuthorized() {
                        // ok --> now perform segue
                        
                        KeyChainAccessProxy.setValue(USERNAME_KEY, value: email)
                        KeyChainAccessProxy.setValue(PASSWORD_KEY, value: pass)
                        
                        // get profile data
                        self.getProfile()
                    }
                } else {
                    // error exist
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
            })
        } else {
            // Show alert
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.showAlertMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "warning", completion: nil)
            })
//            AlertClass.showSimpleErrorMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", completion: nil)
        }
    }
    
    private func getProfile() {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        })
        
        ProfileRestAPIClass.getProfileData({ (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error != HTTPErrorType.Success {
                // sometimes happened
                if error == HTTPErrorType.Refresh {
                    self.getProfile()
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
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        self.performSegueWithIdentifier("SignupMoreInfoVCSegue", sender: self)
                                    })
                                default:
                                    break
                                }
                            }
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
                    
//                    case .NoInternetAccess:
//                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                            self.getProfile()
//                        })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
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

        if textField == self.emailTextField {
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
    
    // Gusture Recognizer implementations
    func singleTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
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
