//
//  LoginViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-28.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON

class LoginViewController: UIViewController, UITextFieldDelegate {

    var savedUsername: String?
    
    private var activeTextField: UITextField?
    private var loading: MBProgressHUD?
    private var filemgr: NSFileManager?
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // customize uibutton
        self.loginButton.layer.cornerRadius = 5
        self.signupButton.layer.cornerRadius = 3
        self.signupButton.layer.borderWidth = 1.0
        self.signupButton.layer.borderColor = self.signupButton.titleLabel?.textColor.CGColor

        self.returnButton.layer.cornerRadius = 3
        self.returnButton.layer.borderWidth = 1.0
        self.returnButton.layer.borderColor = self.returnButton.titleLabel?.textColor.CGColor

        // make text fields properties
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        //self.emailTextField.becomeFirstResponder()
        self.emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        self.passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        
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
    @IBAction func returnButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        self.login()
    }
    
    @IBAction func textFieldDidChange(textField: UITextField) {
        if textField.text?.trim()?.characters.count > 0 {
            textField.textAlignment = .Left
            textField.semanticContentAttribute = .ForceLeftToRight
        } else {
            textField.textAlignment = .Right
            textField.semanticContentAttribute = .ForceRightToLeft
        }
    }
    
    // MARK: - Functions
    private func login() {
        if let email = emailTextField.text where email != "", let pass = passwordTextField.text where pass != "" {
            
            if email.isValidPhoneNumber {
            
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

                if error == .Success {
                    
                    // login passed successfully
                    if TokenHandlerSingleton.sharedInstance.isAuthorized() {
                        // ok --> now perform segue
                        
                        KeyChainAccessProxy.setValue(USERNAME_KEY, value: username)
                        KeyChainAccessProxy.setValue(PASSWORD_KEY, value: pass)
                        
                        
                        self.getLockedStatus()
                        return
                    }
                } else {
                    // error exist
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.hideLoaingMessage(progressHUD: self.loading)
                    })
                    
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
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.showAlertMessage(viewController: self, messageType: "Form", messageSubType: "PhoneVerifyWrong", type: "warning", completion: nil)
                })
            }
        } else {
            // Show alert
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.showAlertMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "warning", completion: nil)
            })
//            AlertClass.showSimpleErrorMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", completion: nil)
        }
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
                                                self.getProfile()
                                                return
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
    
    private func getProfile() {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        })
        
        ProfileRestAPIClass.getProfileData({ (data, error) in
            
            if error != HTTPErrorType.Success {
                // sometimes happened
                if error == HTTPErrorType.Refresh {
                    self.getProfile()
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
                            // profile exist
                            let profile = localData["record"][0]
                            
                            // save profile
                            if let gender = profile["gender"].string, let grade = profile["grade"].string, let gradeString = profile["grade_string"].string, let birthday = profile["birthday"].string, let modified = profile["modified"].string, let firstname = profile["user"]["first_name"].string, let lastname = profile["user"]["last_name"].string {
                                
                                let modifiedDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(modified)
                                let birthdayDate = FormatterSingleton.sharedInstance.UTCShortDateFormatter.dateFromString(birthday)
                                
                                UserDefaultsSingleton.sharedInstance.createProfile(firstname: firstname, lastname: lastname, grade: grade, gradeString: gradeString, gender: gender, birthday: birthdayDate!, modified: modifiedDate!)
                            }
                            
                            
                            if UserDefaultsSingleton.sharedInstance.hasProfile() {
                                self.syncWithServer()
//                                NSOperationQueue.mainQueue().addOperationWithBlock({
//                                    self.performSegueWithIdentifier("HomeVCSegue", sender: self)
//                                })
                            } else {
                                // profile not created --> try again
                            }
                        case "Error":
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                AlertClass.hideLoaingMessage(progressHUD: self.loading)
                            })
                            
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
    
    private func syncWithServer() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.loading = AlertClass.showLoadingMessage(viewController: self)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
        
        PurchasedRestAPIClass.getPurchasedList({ (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            }
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.syncWithServer()
                } else {
                    AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                }
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            
                            var purchasedId: [Int] = []
                            let records = localData["records"].arrayValue
                            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                            for record in records {
                                let id = record["id"].intValue
                                let downloaded = record["downloaded"].intValue
                                let createdStr = record["created"].stringValue
                                let created = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(createdStr)
                                
                                if PurchasedModelHandler.getByUsernameAndId(id: id, username: username) != nil {
                                    PurchasedModelHandler.updateDownloadTimes(username: username, id: id, newDownloadTimes: downloaded)
                                } else {
                                    // does not exist
                                    let target = record["target"]
                                    let targetType = target["product_type"].stringValue
                                    
                                    if targetType == "Entrance" {
                                        let uniqueId = target["unique_key"].stringValue
                                        
                                        if PurchasedModelHandler.add(id: id, username: username, isDownloaded: false, downloadTimes: downloaded, isImageDownlaoded: false, purchaseType: targetType, purchaseUniqueId: uniqueId, created: created!) == true {
                                            
                                            // save entrance
                                            let org = target["organization"]["title"].stringValue
                                            let type = target["entrance_type"]["title"].stringValue
                                            let setName = target["entrance_set"]["title"].stringValue
                                            let group = target["entrance_set"]["group"]["title"].stringValue
                                            let setId = target["entrance_set"]["id"].intValue
                                            let bookletsCount = target["booklets_count"].intValue
                                            let duration = target["duration"].intValue
                                            let year = target["year"].intValue
                                            let extraData = JSON(data: target["extra_data"].stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
                                            
                                            let lastPablishedStr = target["last_published"].stringValue
                                            let lastPublished = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(lastPablishedStr)
                                            
                                            if EntranceModelHandler.getByUsernameAndId(id: uniqueId, username: username) == nil {
                                                let entrance = EntranceStructure(entranceTypeTitle: type, entranceOrgTitle: org, entranceGroupTitle: group, entranceSetTitle: setName, entranceSetId: setId, entranceExtraData: extraData, entranceBookletCounts: bookletsCount, entranceYear: year, entranceDuration: duration, entranceUniqueId: uniqueId, entranceLastPublished: lastPublished)
                                                
                                                EntranceModelHandler.add(entrance: entrance, username: username)
                                                
                                            }
                                        }
                                    }
                                }
                                
                                purchasedId.append(id)
                                //print ("---> \(purchasedId)")
                            }
                            
                            // delete all that does not exist
                            let deletedItems = PurchasedModelHandler.getAllPurchasedNotIn(username: username, ids: purchasedId)
                            //print ("---> \(deletedItems)")
                            
                            if deletedItems.count > 0 {
                                for item in deletedItems {
                                    self.deletePurchaseData(uniqueId: item.productUniqueId)
                                    
                                    // delete product and purchase
                                    if item.productType == "Entrance" {
                                        if EntranceModelHandler.removeById(id: item.productUniqueId, username: username) == true {
                                            
                                            EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId)
                                            EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId)
                                            PurchasedModelHandler.removeById(username: username, id: item.id)
                                            
                                        }
                                    }
                                }
                            }
                            
                            self.downloadImages(purchasedId)
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    // All purchased must be deleted
                                    let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                                    let items = PurchasedModelHandler.getAllPurchased(username: username)
                                    for item in items {
                                        self.deletePurchaseData(uniqueId: item.productUniqueId)
                                        
                                        // delete product and purchase
                                        if item.productType == "Entrance" {
                                            if EntranceModelHandler.removeById(id: item.productUniqueId, username: username) == true {
                                                
                                                EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId)
                                                EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId)
                                                PurchasedModelHandler.removeById(username: username, id: item.id)
                                                
                                            }
                                        }
                                    }
                                    break
                                default:
                                    break
                                    //                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.performSegueWithIdentifier("HomeVCSegue", sender: self)
            })

        }) { (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            }
            
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
                    //                            self.syncWithServer()
                    //                        })
                //                    })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
                    //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                }
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.performSegueWithIdentifier("HomeVCSegue", sender: self)
            })
        }
    }
    
    private func downloadImages(ids: [Int]) {
        self.filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        let newDir = docsDir.stringByAppendingPathComponent("images")
        
        let username: String = UserDefaultsSingleton.sharedInstance.getUsername()!
        let purchased = PurchasedModelHandler.getAllPurchasedIn(username: username, ids: ids)
        for p in purchased {
            if p.productType == "Entrance" {
                if let entrance = EntranceModelHandler.getByUsernameAndId(id: p.productUniqueId, username: username) {
                    downloadEsetImage(esetId: entrance.setId, rootDirectory: newDir)
                }
            }
        }
    }
    
    private func downloadEsetImage(esetId esetId: Int, rootDirectory: String) {
        
        MediaRestAPIClass.downloadEsetImageLocal(esetId, completion: {
            fullPath, data, error in
            
            if error != .Success {
                if error == HTTPErrorType.Refresh {
                    self.downloadEsetImage(esetId: esetId, rootDirectory: rootDirectory)
                } else {
                    //                    print("error in downloaing image from \(fullPath!)")
                }
            } else {
                if let myData = data {
                    let esetDir = (rootDirectory as NSString).stringByAppendingPathComponent("eset")
                    
                    do {
                        if self.filemgr?.fileExistsAtPath(esetDir) == false {
                            try self.filemgr?.createDirectoryAtPath(esetDir, withIntermediateDirectories: true, attributes: nil)
                        }
                        
                        let filePath = (esetDir as NSString).stringByAppendingPathComponent(String(esetId))
                        
                        if self.filemgr?.fileExistsAtPath(filePath) == true {
                            try self.filemgr?.removeItemAtPath(filePath)
                        }
                        self.filemgr?.createFileAtPath(filePath, contents: myData, attributes: nil)
                        
                        
                    } catch {
                        
                    }
                }
            }
            }, failure: { (error) in
        })
        
    }
    
    
    private func deletePurchaseData(uniqueId uniqueId: String) {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        let newDir = docsDir.stringByAppendingPathComponent(uniqueId)
        
        do {
            
            try filemgr.removeItemAtPath(newDir)
        } catch {}
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
