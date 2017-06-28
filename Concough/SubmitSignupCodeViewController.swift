//
//  SubmitSignupCodeViewController.swift
//  Concough
//
//  Created by Owner on 2016-12-06.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import MBProgressHUD

class SubmitSignupCodeViewController: UIViewController, UITextFieldDelegate {
    
    var signupStruct: SignupStructure!
    var fromVC: String!
    
    private var code: Int?
    private var loading: MBProgressHUD?
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // configure text fields
        self.codeTextField.delegate = self
        
        self.resendButton.layer.cornerRadius = 5.0
        self.resendButton.layer.borderWidth = 1.0
        self.resendButton.layer.borderColor = self.resendButton.titleLabel?.textColor.CGColor
        self.submitButton.layer.cornerRadius = 5.0
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }    
    
    // MARK: - Delegates
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.codeTextField {
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.codeTextField {
        }
        return true
    }
    
    // MARK: - Actions
    @IBAction func sendSignupCode(sender: UIButton) {
        switch self.fromVC {
        case "SignupVC":
            self.SendPreSignupCode()
        case "ForgotPasswordVC":
            self.SendForgotPasswordCode()
        default:
            break
        }
    }
    
    @IBAction func resendPreAuthCode(sender: UIButton) {
        self.preSignup()
    }
    
    // MARK: - Functions
    private func preSignup() {
        switch self.fromVC {
        case "SignupVC":
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.loading = AlertClass.showLoadingMessage(viewController: self)
            })
            
            AuthRestAPIClass.preSignup(username: self.signupStruct.username!, completion: { (data, error) in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                })

                if error == HTTPErrorType.Success {
                    // data will returned
                    if let localData = data {
                        if let status = localData["status"].string {
                            switch status {
                            case "OK":
                                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ActionResult", messageSubType: "ResendCodeSuccess", completion: nil)
                            case "Error":
                                if let errorType = localData["error_type"].string {
                                    switch errorType {
                                    case "ExistUsername":
                                        AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: nil)
                                    default:
                                        break
//                                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
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
//                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                            NSOperationQueue.mainQueue().addOperationWithBlock({ 
//                                self.preSignup()
//                            })
//                        })
                    default:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                        })
                    }
                }
            })
        case "ForgotPasswordVC":
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.loading = AlertClass.showLoadingMessage(viewController: self)
            })
            
            AuthRestAPIClass.forgotPassword(username: self.signupStruct.username!, completion: { (data, error) in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                })
                
                if error == HTTPErrorType.Success {
                    // data will returned
                    if let localData = data {
                        if let status = localData["status"].string {
                            switch status {
                            case "OK":
                                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ActionResult", messageSubType: "ResendCodeSuccess", completion: nil)
                            case "Error":
                                if let errorType = localData["error_type"].string {
                                    switch errorType {
                                    case "UserNotExist":
                                        fallthrough
                                    case "ExistUsername":
                                        AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: nil)
                                    default:
                                        break
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
                        //                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        //                            NSOperationQueue.mainQueue().addOperationWithBlock({
                        //                                self.preSignup()
                        //                            })
                    //                        })
                    default:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                        })
                    }
                }
            })
        default:
            break
        }
    }
    
    func SendForgotPasswordCode() {
        if let code = self.codeTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            if let intCode:Int = (code as NSString).integerValue {
                self.code = intCode
                self.performSegueWithIdentifier("ResetPasswordVCSegue", sender: self)
            } else {
                // show error message
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "CodeWrong", type: "error", completion: nil)
                })
            }
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "error", completion: nil)
            })
        }
    }
    
    func SendPreSignupCode() {
        if let code = self.codeTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            if let intCode:Int = (code as NSString).integerValue {

                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.loading = AlertClass.showLoadingMessage(viewController: self)
                })
                
                AuthRestAPIClass.signup(username: self.signupStruct.username!, id: self.signupStruct.preSignupId!, code: intCode, completion: { (data, error) in
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
                                    self.view.endEditing(true)
                                    //print("Code Approved successfully")
                                    // make login request
                                    self.signupStruct.password = code
                                    self.makeLoginRequest()
                                case "Error":
                                    if let errorType = localData["error_type"].string {
                                        switch errorType {
                                        case "ExistUsername":
                                            fallthrough
                                        case "PreAuthNotExist":
                                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                                AlertClass.showTopMessage(viewController: self, messageType: "AuthProfile", messageSubType: (error?.toString())!, type: "error", completion: nil)
                                            })
                                        case "ExpiredCode":
                                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                                AlertClass.showAlertMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, type: "error", completion: nil)
                                            })
                                            
                                        case "BadData":
                                            fallthrough
                                        case "RemoteDBError":
                                            fallthrough
                                        default:
                                            break
//                                            AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
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
//                            AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                                NSOperationQueue.mainQueue().addOperationWithBlock({
//                                    self.SendPreSignupCode()
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
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "CodeWrong", type: "error", completion: nil)
                })
            }
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "error", completion: nil)
            })            
        }
    }
    
    func makeLoginRequest() {
        TokenHandlerSingleton.sharedInstance.setUsernameAndPassword(username: self.signupStruct.username!, password: self.signupStruct.password!)
        
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        })
        
        TokenHandlerSingleton.sharedInstance.authorize({ (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error == .Success {
                
                // login passed successfully
                if TokenHandlerSingleton.sharedInstance.isAuthorized() {
                    // ok --> now perform segue
                    
                    KeyChainAccessProxy.setValue(USERNAME_KEY, value: self.signupStruct.username!)
                    KeyChainAccessProxy.setValue(PASSWORD_KEY, value: self.signupStruct.password!)
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.performSegueWithIdentifier("SignupMoreInfoVCSegue", sender: self)
                    })
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                    })
                }
            } else {
                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!) {
                    // make Login segue
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                    })
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
//                            self.makeLoginRequest()
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
    
    // MARK: - Unwind Segues
    @IBAction func unwindResendForgotPasswordPressed(segue: UIStoryboardSegue) {
        //print("Reset Password Unwind Segue")
    }    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LogInVCSegue" {
            if let destVC = segue.destinationViewController as? LoginViewController {
                destVC.savedUsername = self.signupStruct.username
            }
        } else if segue.identifier == "SignupMoreInfoVCSegue" {
        } else if segue.identifier == "ResetPasswordVCSegue" {
            if let vc = segue.destinationViewController as? ResetPasswordViewController {
                vc.resetCode = self.code!
                vc.signupStruct = self.signupStruct
            }
        }
    }

}
