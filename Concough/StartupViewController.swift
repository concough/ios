//
//  StartupViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-28.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MBProgressHUD
import ReachabilitySwift
import SwiftyJSON

class StartupViewController: UIViewController {
    
    private var loadingP: MBProgressHUD?
    private var reachability: Reachability?
    private var retryCounter = 0
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var selectedIndex: Int = 0
    var isOnline: Bool = true
    var filemgr: NSFileManager?
    
    var loggedIn: Bool = false
    
    @IBOutlet weak var transView: UIView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var unauthenticatedView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var acquireButton: UIButton!
    @IBOutlet weak var resetPassButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var enterButton: UIButton!
    
    
    enum returnFormSegueType {
        case None
        case ForgotPasswordVC
        case SignupVC
        case LogIn
        case FromLock
    }
    
    var returnFormVC: returnFormSegueType = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.transView.backgroundColor = UIColor.whiteColor()
        self.unauthenticatedView.hidden = true
        self.lockView.hidden = true
        self.offlineView.hidden = true
        
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        loginButton.layer.borderColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0).CGColor
        loginButton.layer.borderWidth = 2.0
        
        signupButton.layer.cornerRadius = 10
        signupButton.layer.masksToBounds = true
        signupButton.layer.borderColor = UIColor(netHex: GREEN_COLOR_HEX, alpha: 1.0).CGColor
        signupButton.layer.borderWidth = 2.0
        
        acquireButton.layer.cornerRadius = 10
        acquireButton.layer.masksToBounds = true
        acquireButton.layer.borderColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0).CGColor
        acquireButton.layer.borderWidth = 2.0
        
        resetPassButton.layer.cornerRadius = 10
        resetPassButton.layer.masksToBounds = true
        resetPassButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        resetPassButton.layer.borderWidth = 2.0
        
        enterButton.layer.cornerRadius = 10
        enterButton.layer.masksToBounds = true
        enterButton.layer.borderColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0).CGColor
        enterButton.layer.borderWidth = 2.0
        
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: .MixWithOthers)

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(loopVideo), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        notificationCenter.addObserver(
        self,
        selector: #selector(self.applicationDidBecomeActive(_:)),
        name: UIApplicationDidBecomeActiveNotification,
        object: UIApplication.sharedApplication())
        
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        if (returnFormVC != .FromLock) {
            if self.loggedIn == true {
                NSOperationQueue.mainQueue().addOperationWithBlock {
        //                self.selectedIndex = 2
                    self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                }
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.startup()
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupVideo()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        switch returnFormVC {
        case .ForgotPasswordVC:
            returnFormVC = .None
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("ForgotPasswordVCSegue", sender: self)
            }
            
        case .SignupVC:
            returnFormVC = .None
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("SignUpVCSugue", sender: self)
            }
        case .LogIn:
            returnFormVC = .None
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("LogInVCSegue", sender: self)
            }
        case .FromLock:
            returnFormVC = .None
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.startup()
            })
            
        case .None: break
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
//    override func viewDidDisappear(animated: Bool) {
//        
//    }
    
    
    // MARK: - Actions
    @IBAction func loginButtonPressed(sender: UIButton) {
        returnFormVC = .None
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("LogInVCSegue", sender: self)
        }
    }
    
    @IBAction func signupButtonPressed(sender: UIButton) {
        returnFormVC = .None
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("SignUpVCSugue", sender: self)
        }
    }
    
    @IBAction func resetPassButtonPressed(sender: UIButton) {
        returnFormVC = .None
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("ForgotPasswordVCSegue", sender: self)
        }
    }
    
    @IBAction func lockButtonPressed(sender: UIButton) {
        self.getLockedStatus()
        
    }
    
    @IBAction func enterButtonPressed(sender: UIButton) {
        if TokenHandlerSingleton.sharedInstance.isAuthorized() && TokenHandlerSingleton.sharedInstance.isAuthenticated() {
            
            self.loggedIn = true
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.selectedIndex = 2
                self.performSegueWithIdentifier("HomeVCSegue", sender: self)
            }
        }
    }
    
    // MARK: - Functions
    private func startup() {
        LocalNotificationsSingleton.sharedInstance.touch()
        TokenHandlerSingleton.sharedInstance.touch()
        UserDefaultsSingleton.sharedInstance.touch()
        BasketSingleton.sharedInstance.touch()
        RealmSingleton.sharedInstance.touch()
        DeviceInformationSingleton.sharedInstance.touch()
        
        do {
            self.reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
        }
        
        
        if self.reachability != nil && self.reachability!.isReachable() {
            //        if TokenHandlerSingleton.sharedInstance.isAuthorized() {
            //            if UserDefaultsSingleton.sharedInstance.hasProfile() {
            //                NSOperationQueue.mainQueue().addOperationWithBlock {
            //                    self.performSegueWithIdentifier("HomeVCSegue", sender: self)
            //                }
            //            } else {
            //                // get profile
            //                self.getProfile()
            //            }
            //        } else
            if TokenHandlerSingleton.sharedInstance.isAuthenticated() {
                TokenHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, error) in
                    if (authenticated) {
                        if let username = UserDefaultsSingleton.sharedInstance.getUsername() {
                            if let device = DeviceInformationModelHandler.findByUniqueId(username) {
                                if device.state == true {
                                    if UserDefaultsSingleton.sharedInstance.hasProfile() {
                                        NSOperationQueue.mainQueue().addOperationWithBlock({
                                            self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                                        })

                                    } else {
                                        self.getProfile()
                                    }
                                } else {
                                    self.setupLocked()
                                }
                            } else {
                                self.setupLocked()
                            }
                        }
                    } else {
                        self.setupUnauthenticated()
                    }
                    
                    }, failure: { (error) in
                        if TokenHandlerSingleton.sharedInstance.isAuthorized() && TokenHandlerSingleton.sharedInstance.isAuthenticated() {
                            if let username = UserDefaultsSingleton.sharedInstance.getUsername() {
                                if let device = DeviceInformationModelHandler.findByUniqueId(username) {
                                    if device.state == true {
                                        self.isOnline = false
                                        self.setupOffline()
                                    } else {
                                        self.setupLocked()
                                    }
                                } else {
                                    self.setupLocked()
                                }
                            }
                        } else {
                            self.setupUnauthenticated()
                            
                        }
                        
                })
            } else {
                self.setupUnauthenticated()
            }
        } else {
            if TokenHandlerSingleton.sharedInstance.isAuthorized() && TokenHandlerSingleton.sharedInstance.isAuthenticated() {
                let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                if let device = DeviceInformationModelHandler.findByUniqueId(username) {
                    if device.state == true {
                        self.isOnline = false
                        self.setupOffline()
                    } else {
                        self.setupLocked()
                    }
                } else {
                    self.setupLocked()
                }
            } else {
                self.setupUnauthenticated()
                
            }
        }
    }
    
//    private func checkDeviceStateWithServer() {
////        NSOperationQueue.mainQueue().addOperationWithBlock({
////            self.loadingP = AlertClass.showLoadingMessage(viewController: self)
////        })
//        
//        DeviceRestAPIClass.deviceState({ (data, error) in
////            NSOperationQueue.mainQueue().addOperationWithBlock({
////                AlertClass.hideLoaingMessage(progressHUD: self.loadingP)
////            })
//            
//            if error != HTTPErrorType.Success {
//                // sometimes happened
//                if error == HTTPErrorType.Refresh {
//                    self.checkDeviceStateWithServer()
//                } else {
//                    if self.retryCounter < CONNECTION_MAX_RETRY {
//                        self.retryCounter += 1
//                        self.checkDeviceStateWithServer()
//                    } else {
//                        self.retryCounter = 0
//                        
//                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                            AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
//                        })
//                    }
//                }
//            } else {
//                self.retryCounter = 0
//                if let localData = data {
//                    if let status = localData["status"].string {
//                        switch status {
//                        case "OK":
//                            if let state = localData["data"]["state"].bool, let device_unique_id = localData["data"]["device_unique_id"].string {
//                                
//                                var uuid: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
//                                if let temp = KeyChainAccessProxy.getValue(IDENTIFIER_FOR_VENDOR_KEY) as? String {
//                                    uuid = temp
//                                }
//                                
//                                if device_unique_id == uuid {
//                                    // ok --> valid
//                                        if state == true {
//                                            if UserDefaultsSingleton.sharedInstance.hasProfile() {
//                                                self.checkVersion()
//                                            } else {
//                                                self.getProfile()
//                                            }
//                                        } else {
//                                            self.setupLocked()
//                                        }
//                                }
//                            }
//                                
//                            
//                            
//                            break
//                            
//                        case "Error":
//                            if let errorType = localData["error_type"].string {
//                                switch errorType {
//                                case "AnotherDevice":
//                                    // profile not exist --> perform navigation
//                                    let username = UserDefaultsSingleton.sharedInstance.getUsername()!
//                                    NSOperationQueue.mainQueue().addOperationWithBlock({
//                                        AlertClass.showAlertMessage(viewController: self, messageType: "DeviceInfoError", messageSubType: errorType, type: "error", completion: {
//                                            let error_data = localData["error_data"]
//                                            let device_name = error_data["device_name"].string
//                                            let device_model = error_data["device_model"].string
//                                            
//                                            if DeviceInformationSingleton.sharedInstance.setDeviceState(username, device_name: device_name!, device_model: device_model!, state: false, isMe: false) {
//                                                
//                                                self.statusLabel.text = "دستگاه: " + "\(device_name!) \(device_model!)"
//                                                
//                                            }
//                                            
//                                        })
//                                        self.setupLocked()
//                                        //                                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "DeviceInfoError", messageSubType: errorType, completion: {
//                                        //                                        })
//                                        
//                                    })
//                                    break
//                                case "UserNotExit": fallthrough
//                                case "DeviceNotRegistered":
//                                    NSOperationQueue.mainQueue().addOperationWithBlock({
//                                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
//                                    })
//                                    break
//                                default:
//                                    break
//                                }
//                            }
//                        default:
//                            break
//                        }
//                    }
//                }
//            }
//            
//            
//            }) { (error) in
//                if self.retryCounter < CONNECTION_MAX_RETRY {
//                    self.retryCounter += 1
//                    self.checkDeviceStateWithServer()
//                } else {
//                    self.retryCounter = 0
//                
//                    if TokenHandlerSingleton.sharedInstance.isAuthorized() && TokenHandlerSingleton.sharedInstance.isAuthenticated() {
//                        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
//                        if let device = DeviceInformationModelHandler.findByUniqueId(username) {
//                            if device.state == true {
//                                self.isOnline = false
//                                self.setupOffline()
//                            } else {
//                                self.setupLocked()
//                            }
//                        } else {
//                            self.setupLocked()
//                        }
//                    }
//                }
//        }
//        
//    }
    
    private func getLockedStatus() {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.loadingP = AlertClass.showLoadingMessage(viewController: self)
        })
        
        DeviceRestAPIClass.deviceLock(false, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loadingP)
            })
            
            if error != HTTPErrorType.Success {
                // sometimes happened
                if error == HTTPErrorType.Refresh {
                    self.getLockedStatus()
                } else {
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        self.getLockedStatus()
                    } else {
                        self.retryCounter = 0
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                        })
                    }
                }
            } else {
                self.retryCounter = 0
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
//                                                NSOperationQueue.mainQueue().addOperationWithBlock({ 
//                                                    self.syncWithServer()
//                                                })
//                                                if UserDefaultsSingleton.sharedInstance.hasProfile() {
//                                                    NSOperationQueue.mainQueue().addOperationWithBlock({
//                                                        self.performSegueWithIdentifier("HomeVCSegue", sender: self)
//                                                    })
//
//                                                } else {
                                                    self.getProfile()
//                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                            break
                            
                        case "Error":
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
                                                
                                                self.statusLabel.text = "دستگاه: " + "\(device_name!) \(device_model!)"
                                                
                                            }
                                            
                                        })
//                                        AlertClass.showSimpleErrorMessage(viewController: self, messageType: "DeviceInfoError", messageSubType: errorType, completion: {
//                                        })
                                        
                                    })
                                case "UserNotExit": fallthrough
                                case "DeviceNotRegistered":
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                                    })
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
                AlertClass.hideLoaingMessage(progressHUD: self.loadingP)
            })

            if self.retryCounter < CONNECTION_MAX_RETRY {
                self.retryCounter += 1
                self.getLockedStatus()
            } else {
                self.retryCounter = 0
                
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
    }
    
    
//    private func checkVersion() {
//        SettingsRestAPIClass.appLastVersion({ (data, error) in
//            if error != HTTPErrorType.Success {
//                if error == HTTPErrorType.Refresh {
//                    self.checkVersion()
//                } else {
//                    self.loggedIn = true
//                    NSOperationQueue.mainQueue().addOperationWithBlock {
//                        self.selectedIndex = 0
//                        self.performSegueWithIdentifier("HomeVCSegue", sender: self)
//                    }
//                }
//                
//            } else {
//                if let localData = data {
//                    if let status = localData["status"].string {
//                        switch status {
//                        case "OK":
//                            // profile exist
//                            if let version = localData["version"].int, let released = localData["released"].string, let link = localData["link"].string {
//                                
//                                var showMsg = false
//                                
//                                if version > APP_VERSION {
//                                    kCFNumberFormatterAlwaysShowDecimalSeparator
//                                    if let existVer = DeviceInformationSingleton.sharedInstance.getLastAppVersion() {
//                                        if version > existVer {
//                                            showMsg = true
//                                        } else {
//                                            let count = DeviceInformationSingleton.sharedInstance.getLastAppVersionCount(version)
//                                            
//                                            if count <= 2 {
//                                                showMsg = true
//                                            }
//                                        }
//                                        
//                                    } else {
//                                        showMsg = true
//                                    }
//                                    DeviceInformationSingleton.sharedInstance.putLastAppVersion(version)
//                                }
//                                
//                                if showMsg {
//                                    let (title, _, _) = AlertClass.convertMessage(messageType: "DeviceAction", messageSubType: "UpdateApp")
//                                    
//                                    let date = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(released)
//                                    
//                                    
//                                    let newMsg: String = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(version)!
//                                    let persianDate: String = FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(date!)
//                                    
//                                    let msg = " نسخه\(newMsg) منتشر شده است\nتاریخ: \(persianDate)"
//                                    
//                                    AlertClass.showSuccessMessageCustom(viewController: self, title: title, message: msg, yesButtonTitle: "دانلود", noButtonTitle: "بعدا", completion: {
//                                        
//                                        UIApplication.sharedApplication().openURL(NSURL(string: link)!)
//                                        
////                                        NSOperationQueue.mainQueue().addOperationWithBlock {
////                                            self.selectedIndex = 0
////                                            self.performSegueWithIdentifier("HomeVCSegue", sender: self)
////                                        }
//                                    }, noCompletion: {
//                                        self.loggedIn = true
//                                        NSOperationQueue.mainQueue().addOperationWithBlock {
//                                            self.selectedIndex = 0
//                                            self.performSegueWithIdentifier("HomeVCSegue", sender: self)
//                                        }
//                                    })
//                                } else {
//                                    self.loggedIn = true
//                                    NSOperationQueue.mainQueue().addOperationWithBlock {
//                                        self.selectedIndex = 0
//                                        self.performSegueWithIdentifier("HomeVCSegue", sender: self)
//                                    }
//                                }
//                            } else {
//                                self.loggedIn = true
//                                NSOperationQueue.mainQueue().addOperationWithBlock {
//                                    self.selectedIndex = 0
//                                    self.performSegueWithIdentifier("HomeVCSegue", sender: self)
//                                }
//                            }
//                            
//                            
//                            
//                        case "Error":
//                            if let errorType = localData["error_type"].string {
//                                switch errorType {
//                                case "EmptyArray":
//                                    // profile not exist --> perform navigation
//                                    fallthrough
//                                default:
//                                    break
//                                }
//                            }
//                            fallthrough
//                        default:
//                            self.loggedIn = true
//                            
//                            NSOperationQueue.mainQueue().addOperationWithBlock {
//                                self.selectedIndex = 0
//                                self.performSegueWithIdentifier("HomeVCSegue", sender: self)
//                            }
//                        }
//                    }
//                }
//            }
//        }) { (error) in
//            if let err = error {
//                switch err {
//                case .NoInternetAccess:
//                    fallthrough
//                case .HostUnreachable:
//                    AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
//                    
//                    //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                    //                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                    //                            self.getProfile()
//                    //                        })
//                //                    })
//                default:
//                    AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
//                }
//            }
//            
//            self.loggedIn = true
//            NSOperationQueue.mainQueue().addOperationWithBlock {
//                self.selectedIndex = 0
//                self.performSegueWithIdentifier("HomeVCSegue", sender: self)
//            }
//        }
//    }
    
    private func getProfile() {
        ProfileRestAPIClass.getProfileData({ (data, error) in
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.getProfile()
                } else {
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        self.getProfile()
                    } else {
                        self.retryCounter = 0
                        
                        self.setupUnauthenticated()
                    }
                }
                
                //                NSOperationQueue.mainQueue().addOperationWithBlock({
                //                    self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                //                })
            } else {
                self.retryCounter = 0
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            // profile exist
                            let profile = localData["record"][0]
                            
                            // save profile
                            if let gender = profile["gender"].string, let grade = profile["grade"].string, let gradeString = profile["grade_string"].string, let birthday = profile["birthday"].string, let modified = profile["modified"].string, let firstname = profile["user"]["first_name"].string, let lastname = profile["user"]["last_name"].string {
                                
                                let modifiedDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(modified)
                                let birthdayDate = FormatterSingleton.sharedInstance.UTCShortDateFormatter.dateFromString(birthday)
                                
                                UserDefaultsSingleton.sharedInstance.createProfile(firstname: firstname, lastname: lastname, grade: grade, gradeString: gradeString, gender: gender, birthday: birthdayDate!, modified: modifiedDate!)
                            }
                            
                            if UserDefaultsSingleton.sharedInstance.hasProfile() {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                                })
                                
                            } else {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.performSegueWithIdentifier("SignupMoreInfoVCSegue", sender: self)
                                })

                                // profile not created --> try again
                                //                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                //                                    self.performSegueWithIdentifier("", sender: self)
                                //                                })
                                
                            }
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "ProfileNotExist":
                                    // profile not exist --> perform navigation
                                    fallthrough
                                default:
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        self.performSegueWithIdentifier("SignupMoreInfoVCSegue", sender: self)
                                    })
                                    
                                    //                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                    //                                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                                    //                                    })
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
            }, failure: { (error) in
                if self.retryCounter < CONNECTION_MAX_RETRY {
                    self.retryCounter += 1
                    self.getProfile()
                } else {
                    self.retryCounter = 0
                    
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
                    self.setupUnauthenticated()
                }
        })
    }
    
//    private func syncWithServer() {
//        PurchasedRestAPIClass.getPurchasedList({ (data, error) in
//            if error != HTTPErrorType.Success {
//                if error == HTTPErrorType.Refresh {
//                    self.syncWithServer()
//                } else {
//                    if self.retryCounter < CONNECTION_MAX_RETRY {
//                        self.retryCounter += 1
//                        self.syncWithServer()
//                    } else {
//                        self.retryCounter = 0
//                    }
//                }
//            } else {
//                self.retryCounter = 0
//                if let localData = data {
//                    if let status = localData["status"].string {
//                        switch status {
//                        case "OK":
//                            
//                            var purchasedId: [Int] = []
//                            let records = localData["records"].arrayValue
//                            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
//                            for record in records {
//                                let id = record["id"].intValue
//                                let downloaded = record["downloaded"].intValue
//                                let createdStr = record["created"].stringValue
//                                let created = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(createdStr)
//                                
//                                if PurchasedModelHandler.getByUsernameAndId(id: id, username: username) != nil {
//                                    PurchasedModelHandler.updateDownloadTimes(username: username, id: id, newDownloadTimes: downloaded)
//                                    
//                                    let target = record["target"]
//                                    let targetType = target["product_type"].stringValue
//                                    
//                                    if targetType == "Entrance" {
//                                        let uniqueId = target["unique_key"].stringValue
//                                        let month = target["month"].intValue
//                                        
//                                        if let item = EntranceModelHandler.getByUsernameAndId(id: uniqueId, username: username) {
//                                            if item.month != month {
//                                                EntranceModelHandler.correctMonthOfEntrance(id: uniqueId, username: username, month: month)
//                                            }
//                                        }
//                                    }
//                                    
//                                } else {
//                                    // does not exist
//                                    let target = record["target"]
//                                    let targetType = target["product_type"].stringValue
//                                    
//                                    if targetType == "Entrance" {
//                                        let uniqueId = target["unique_key"].stringValue
//                                        
//                                        if PurchasedModelHandler.add(id: id, username: username, isDownloaded: false, downloadTimes: downloaded, isImageDownlaoded: false, purchaseType: targetType, purchaseUniqueId: uniqueId, created: created!) == true {
//                                            
//                                            // save entrance
//                                            let org = target["organization"]["title"].stringValue
//                                            let type = target["entrance_type"]["title"].stringValue
//                                            let setName = target["entrance_set"]["title"].stringValue
//                                            let group = target["entrance_set"]["group"]["title"].stringValue
//                                            let setId = target["entrance_set"]["id"].intValue
//                                            let bookletsCount = target["booklets_count"].intValue
//                                            let duration = target["duration"].intValue
//                                            let year = target["year"].intValue
//                                            let month = target["month"].intValue
//                                            let extraData = JSON(data: target["extra_data"].stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
//                                            
//                                            let lastPablishedStr = target["last_published"].stringValue
//                                            let lastPublished = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(lastPablishedStr)
//                                            
//                                            if EntranceModelHandler.getByUsernameAndId(id: uniqueId, username: username) == nil {
//                                                let entrance = EntranceStructure(entranceTypeTitle: type, entranceOrgTitle: org, entranceGroupTitle: group, entranceSetTitle: setName, entranceSetId: setId, entranceExtraData: extraData, entranceBookletCounts: bookletsCount, entranceYear: year, entranceMonth: month, entranceDuration: duration, entranceUniqueId: uniqueId, entranceLastPublished: lastPublished)
//                                                
//                                                EntranceModelHandler.add(entrance: entrance, username: username)
//                                                
//                                            }
//                                        }
//                                    }
//                                }
//                                
//                                purchasedId.append(id)
//                            }
//                            
//                            // delete all that does not exist
//                            let deletedItems = PurchasedModelHandler.getAllPurchasedNotIn(username: username, ids: purchasedId)
//                            
//                            if deletedItems.count > 0 {
//                                for item in deletedItems {
//                                    self.deletePurchaseData(uniqueId: item.productUniqueId)
//                                    
//                                    // delete product and purchase
//                                    if item.productType == "Entrance" {
//                                        if EntranceModelHandler.removeById(id: item.productUniqueId, username: username) == true {
//                                            
//                                            EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId, username: username)
//                                            EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId, username: username)
//                                            PurchasedModelHandler.removeById(username: username, id: item.id)
//                                            
//                                        }
//                                    }
//                                }
//                            }
//                            
//                            self.downloadImages(purchasedId)
//                            
//                        case "Error":
//                            if let errorType = localData["error_type"].string {
//                                switch errorType {
//                                case "EmptyArray":
//                                    // All purchased must be deleted
//                                    let username = UserDefaultsSingleton.sharedInstance.getUsername()!
//                                    let items = PurchasedModelHandler.getAllPurchased(username: username)
//                                    for item in items {
//                                        self.deletePurchaseData(uniqueId: item.productUniqueId)
//                                        
//                                        // delete product and purchase
//                                        if item.productType == "Entrance" {
//                                            if EntranceModelHandler.removeById(id: item.productUniqueId, username: username) == true {
//                                                
//                                                EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId, username: username)
//                                                EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId, username: username)
//                                                PurchasedModelHandler.removeById(username: username, id: item.id)
//                                                
//                                            }
//                                        }
//                                    }
//                                    break
//                                default:
//                                    break
//                                    //                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
//                                }
//                            }
//                        default:
//                            break
//                        }
//                    }
//                }
//            }
//            
//        }) { (error) in
//            if self.retryCounter < CONNECTION_MAX_RETRY {
//                self.retryCounter += 1
//                self.syncWithServer()
//            } else {
//                self.retryCounter = 0
//                
//                if let err = error {
//                    switch err {
//                    case .NoInternetAccess:
//                        fallthrough
//                    case .HostUnreachable:
//                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
//                        })
//                        
//                        //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                        //                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                        //                            self.syncWithServer()
//                        //                        })
//                    //                    })
//                    default:
//                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
//                        })
//                        //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
//                    }
//                }
//            }
//        }
//    }
//    
//    private func downloadImages(ids: [Int]) {
//        self.filemgr = NSFileManager.defaultManager()
//        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        
//        let docsDir = dirPaths[0] as NSString
//        let newDir = docsDir.stringByAppendingPathComponent("images")
//        
//        let username: String = UserDefaultsSingleton.sharedInstance.getUsername()!
//        let purchased = PurchasedModelHandler.getAllPurchasedIn(username: username, ids: ids)
//        for p in purchased {
//            if p.productType == "Entrance" {
//                if let entrance = EntranceModelHandler.getByUsernameAndId(id: p.productUniqueId, username: username) {
//                    downloadEsetImage(esetId: entrance.setId, rootDirectory: newDir)
//                }
//            }
//        }
//    }
//    
//    private func downloadEsetImage(esetId esetId: Int, rootDirectory: String) {
//        
//        MediaRestAPIClass.downloadEsetImageLocal(esetId, completion: {
//            fullPath, data, error in
//            
//            if error != .Success {
//                if error == HTTPErrorType.Refresh {
//                    self.downloadEsetImage(esetId: esetId, rootDirectory: rootDirectory)
//                } else {
//                }
//            } else {
//                if let myData = data {
//                    let esetDir = (rootDirectory as NSString).stringByAppendingPathComponent("eset")
//                    
//                    do {
//                        if self.filemgr?.fileExistsAtPath(esetDir) == false {
//                            try self.filemgr?.createDirectoryAtPath(esetDir, withIntermediateDirectories: true, attributes: nil)
//                        }
//                        
//                        let filePath = (esetDir as NSString).stringByAppendingPathComponent(String(esetId))
//                        
//                        if self.filemgr?.fileExistsAtPath(filePath) == true {
//                            try self.filemgr?.removeItemAtPath(filePath)
//                        }
//                        self.filemgr?.createFileAtPath(filePath, contents: myData, attributes: nil)
//                        
//                        
//                    } catch {
//                        
//                    }
//                }
//            }
//            }, failure: { (error) in
//        })
//        
//    }
//    
//    
//    private func deletePurchaseData(uniqueId uniqueId: String) {
//        let filemgr = NSFileManager.defaultManager()
//        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        
//        let docsDir = dirPaths[0] as NSString
//        let newDir = docsDir.stringByAppendingPathComponent(uniqueId)
//        
//        do {
//            
//            try filemgr.removeItemAtPath(newDir)
//        } catch {}
//    }
//    
    
    private func setupVideo() {
        // Load the video from the app bundle.
        let videoURL: NSURL = NSBundle.mainBundle().URLForResource("video", withExtension: "mp4")!
        
        player = AVPlayer(URL: videoURL)
        player?.actionAtItemEnd = .None
        player?.muted = true
        
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.playerLayer!.zPosition = -1
        
        playerLayer!.frame = view.frame
        
        view.layer.addSublayer(playerLayer!)
        player?.play()
        
        //loop video
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.loopVideo),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: nil)
    }
    
    private func unsetupVideo() {
        if (self.player != nil) {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
            player?.pause()
            player = nil
            
            self.playerLayer?.removeFromSuperlayer()
        }
    }
    
    private func setupUnauthenticated() {
        //        setupOffline()
        self.loading.stopAnimating()
//        self.transView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.7)
        self.unauthenticatedView.hidden = false
    }
    
    private func setupLocked() {
        self.loading.stopAnimating()
//        self.transView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.7)
        self.lockView.hidden = false
        
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        if let device = DeviceInformationModelHandler.findByUniqueId(username) {
            if device.isMe == true {
                self.statusLabel.text = "دستگاه فعلی"
                
            } else {
                self.statusLabel.text = "دستگاه: " + "\(device.device_name) \(device.device_model)"
            }
        }
    }
    
    private func setupOffline() {
        self.loading.stopAnimating()
//        self.transView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.7)
        self.offlineView.hidden = false
        
        do {
            try reachability?.startNotifier()
            reachability?.whenReachable = { reachability in
                // this is called on a background thread, but UI updates must
                // be on the main thread, like this:
                self.reachability?.stopNotifier()
                self.loggedIn = true
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    if UserDefaultsSingleton.sharedInstance.hasProfile() {
                        self.selectedIndex = 0
                        self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                    } else {
                        self.getProfile()
                    }
                }
            }
        } catch {
        }
        
    }
    
    func loadBasket() {
        BasketSingleton.sharedInstance.loadBasketItems(viewController: self) { (count) in
        }
    }
    
    @objc private func loopVideo() {
        player?.seekToTime(kCMTimeZero)
        player?.play()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
//        return true
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HomeVCSegue" {
//            if self.isOnline {
//                self.loadBasket()
//            }
            
            if self.isOnline {
                SynchronizationSingleton.sharedInstance.startSync()
            }
            unsetupVideo()
            UIApplication.sharedApplication().idleTimerDisabled = false

            if let destinationVC = segue.destinationViewController as? UITabBarController {
                destinationVC.selectedIndex = self.selectedIndex
            }
        }
    }
    
    // MARK: - Unwind Segue Operations
    
    @IBAction func unwindForgotPasswordPressed(segue: UIStoryboardSegue) {
        self.returnFormVC = .ForgotPasswordVC
    }
    
    @IBAction func unwindSignUpPressed(segue: UIStoryboardSegue) {
        self.returnFormVC = .SignupVC
    }
    
    @IBAction func unwindLogInPressed(segue: UIStoryboardSegue) {
        self.returnFormVC = .LogIn
    }
}
