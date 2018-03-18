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
    
    private var send_type: String = "sms" {
        didSet {
            if send_type == "call" {
                self.resendButton.setTitle("ارسال کد از طریق تماس", forState: .Normal)
            } else if send_type == "sms" {
                self.resendButton.setTitle("ارسال مجدد کد فعالسازی", forState: .Normal)
            } else {
                self.resendButton.setTitle("فردا سعی نمایید ..", forState: .Normal)
            }
        }
    }
    private var code: Int?
    private var loading: MBProgressHUD?
    private var timer:  NSTimer!
    
    private var timerCounter: Int = 120 {
        didSet {
            if timerCounter > 0 {
                self.timerLabel.hidden = false
                
                let minute: Int = timerCounter / 60
                let seconds: Int = timerCounter % 60
                self.timerLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(minute)!):\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(seconds)!)"
                
            } else {
                self.timerLabel.hidden = true
                self.timer.invalidate()
                self.changeResendButtonState(state: true)
            }
        }
    }
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timer = NSTimer()
        // configure text fields
        self.codeTextField.delegate = self
        
        self.resendButton.layer.cornerRadius = 5.0
        self.resendButton.layer.borderWidth = 1.0
        self.resendButton.layer.borderColor = self.resendButton.titleLabel?.textColor.CGColor
        self.submitButton.layer.cornerRadius = 5.0
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.changeResendButtonState(state: false)
        self.startTimerWithInterval()
    }
    
    deinit {
        self.timer.invalidate()
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
    private func changeResendButtonState(state state: Bool) {
        
        if state {
            self.resendButton.setTitleColor(UIColor.init(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
            self.resendButton.layer.borderColor = self.resendButton.titleLabel?.textColor.CGColor
            self.resendButton.enabled = true
            
        } else {
            self.resendButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            self.resendButton.layer.borderColor = self.resendButton.titleLabel?.textColor.CGColor
            self.resendButton.enabled = false
        }
    }
    
    private func startTimerWithInterval() {
        self.timerCounter = 120
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc private func updateCounting() {
        self.timerCounter-=1
    }
    
    private func stopCounting() {
        self.timerLabel.hidden = true
        self.timer.invalidate()
    }
    
    private func preSignup() {
        switch self.fromVC {
        case "SignupVC":
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.loading = AlertClass.showLoadingMessage(viewController: self)
            })
            
            AuthRestAPIClass.preSignup(username: self.signupStruct.username!, send_type: self.send_type, completion: { (data, error) in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                })

                if error == HTTPErrorType.Success {
                    // data will returned
                    if let localData = data {
                        if let status = localData["status"].string {
                            switch status {
                            case "OK":
                                AlertClass.showAlertMessage(viewController: self, messageType: "ActionResult", messageSubType: "ResendCodeSuccess", type: "success", completion: { 
                                    self.changeResendButtonState(state: false)
                                    self.startTimerWithInterval()
                                })
                                
//                                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ActionResult", messageSubType: "ResendCodeSuccess", completion: {
//                                
//                                })
                            case "Error":
                                if let errorType = localData["error_type"].string {
                                    switch errorType {
                                    case "ExistUsername":
                                        AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: "ExistUsername", type: "error", completion: {
                                            self.stopCounting()
                                            self.changeResendButtonState(state: false)
                                        
                                        })
                                    case "SMSSendError": fallthrough
                                    case "CallSendError":
                                        AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: nil)
                                        self.changeResendButtonState(state: true)
                                    case "ExceedToday":
                                        AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: {
                                            
                                            self.send_type = "call"
                                        })
                                    case "ExceedCallToday":
                                        AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: {
                                            
                                            self.send_type = ""
                                            self.stopCounting()
                                            self.changeResendButtonState(state: false)
                                        })
                                        
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
        case "ForgotPasswordVC":
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.loading = AlertClass.showLoadingMessage(viewController: self)
            })
            
            AuthRestAPIClass.forgotPassword(username: self.signupStruct.username!, send_type: self.send_type, completion: { (data, error) in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                })
                
                if error == HTTPErrorType.Success {
                    // data will returned
                    if let localData = data {
                        if let status = localData["status"].string {
                            switch status {
                            case "OK":
                                AlertClass.showAlertMessage(viewController: self, messageType: "ActionResult", messageSubType: "ResendCodeSuccess", type: "success", completion: { 
                                    self.changeResendButtonState(state: false)
                                    self.startTimerWithInterval()
                                    
                                })
//                                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ActionResult", messageSubType: "ResendCodeSuccess", completion: {
//                                    
//                                })
                            case "Error":
                                if let errorType = localData["error_type"].string {
                                    switch errorType {
                                    case "RemoteDBError": fallthrough
                                    case "UserNotExist":
                                        AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: "UserNotExist", type: "error", completion: nil)
                                        self.stopCounting()
                                        self.changeResendButtonState(state: false)
                                    case "SMSSendError": fallthrough
                                    case "CallSendError":
                                        AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: nil)
                                        self.changeResendButtonState(state: true)
                                    case "ExceedToday":
                                        self.send_type = "call"
                                        self.changeResendButtonState(state: true)
                                        
//                                        AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: {
//                                            
//                                        })
                                    case "ExceedCallToday":
                                        AlertClass.showAlertMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: {
                                            
                                            self.send_type = ""
                                            self.stopCounting()
                                            self.changeResendButtonState(state: false)
                                        })
                                        
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
        if self.codeTextField.text?.trim() != "" {
            if let code = self.codeTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                if let intCode:Int = (code as NSString).integerValue {
                    self.stopCounting()
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
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "error", completion: nil)
            })
        }
    }
    
    func SendPreSignupCode() {
        if self.codeTextField.text?.trim() != "" {
        
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
                                    self.stopCounting()
 
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
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "error", completion: nil)
            })
        }
    }
    
    func makeLoginRequest() {
        TokenHandlerSingleton.sharedInstance.setUsernameAndPassword(username: self.signupStruct.username!, password: self.signupStruct.password!)
        
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
                    
                    self.getLockedStatus()
                    
                } else {
                }
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.loading = AlertClass.showLoadingMessage(viewController: self)
                })
                
                AlertClass.showAlertMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "success", completion: { 
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                    })
                })
//                AlertClass.showSimpleErrorMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!) {
//                    // make Login segue
//                }
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
    
    private func getLockedStatus() {
        DeviceRestAPIClass.deviceCreate({ (data, error) in
            if error != HTTPErrorType.Success {
                // sometimes happened
                if error == HTTPErrorType.Refresh {
                    self.getLockedStatus()
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.hideLoaingMessage(progressHUD: self.loading)
                        AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                    })
                }
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            if let username = UserDefaultsSingleton.sharedInstance.getUsername() {
                                if let state = localData["data"]["state"].bool, let device_unique_id = localData["data"]["device_unique_id"].string {
                                    
                                    var uuid: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
                                    if let temp = KeyChainAccessProxy.getValue(IDENTIFIER_FOR_VENDOR_KEY) as? String {
                                        uuid = temp
                                    }
                                    
                                    if device_unique_id == uuid {
                                        // ok --> valid
                                        if DeviceInformationSingleton.sharedInstance.setDeviceState(username, device_name: "ios", device_model: UIDevice.currentDevice().type.rawValue, state: state, isMe: true) {
                                            
                                            if state == true {
                                                // get profile data
                                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                                    self.performSegueWithIdentifier("SignupMoreInfoVCSegue", sender: self)
                                                })
                                            } else {
                                                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("StartupVC") as? StartupViewController {
                                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                                        self.presentViewController(vc, animated: true, completion: nil)
                                                    })
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                AlertClass.hideLoaingMessage(progressHUD: self.loading)
                            })
                            break
                            
                        case "Error":
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                AlertClass.hideLoaingMessage(progressHUD: self.loading)
                            })
                            
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "AnotherDevice":
                                    // profile not exist --> perform navigation
                                    let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        AlertClass.showAlertMessage(viewController: self, messageType: "DeviceInfoError", messageSubType: errorType, type: "error", completion: { 
                                            
                                            let error_data = localData["error_data"]
                                            let device_name = error_data["device_name"].string
                                            let device_model = error_data["device_model"].string
                                            
                                            if DeviceInformationSingleton.sharedInstance.setDeviceState(username, device_name: device_name!, device_model: device_model!, state: false, isMe: false) {
                                                
                                                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("StartupVC") as? StartupViewController {
                                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                                        self.presentViewController(vc, animated: true, completion: nil)
                                                    })
                                                    
                                                }
                                            }
                                        })
                                        
//                                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "DeviceInfoError", messageSubType: errorType, completion: {
//                                        })
                                        
                                    })
                                case "UserNotExit": fallthrough
                                case "DeviceNotRegistered":
                                    //                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                    //                                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                                    //                                    })
                                    break
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
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
                }
            }
            
        }
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
