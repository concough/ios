//
//  SettingsTableViewController.swift
//  Concough
//
//  Created by Owner on 2017-02-03.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit
import SimpleAlert
import MBProgressHUD

class SettingsTableViewController: UITableViewController, ContactsProtocol {

    private var loading: MBProgressHUD?
    private var loadUrlString: String = ""
    private var inEditingMode: Bool = false
    private var retryCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید", attributes: [NSFontAttributeName: UIFont(name: "IRANSansMobile-Light", size: 12)!])
        }
        self.refreshControl?.addTarget(self, action: #selector(self.refreshTableView(_:)), forControlEvents: .ValueChanged)
        self.tableView.tableFooterView = UIView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Actions
    @IBAction func shareButtonPressed(sender: UIBarButtonItem) {
        let first = "کنکوق: دسترسی به تمام آزمونهای برگزار شده در کشور آنلاین بصورت آنلاین و آفلاین و ده ها قابلیت دیگر"
        let second: NSURL = NSURL(string: ABOUT_URL)!
        let image: UIImage = UIImage(named: "logo_white_share")!
        
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [first, second, image], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.barButtonItem = sender
        activityViewController.popoverPresentationController?.permittedArrowDirections = .Up
        
        activityViewController.excludedActivityTypes = [
            UIActivityTypeAirDrop,
            UIActivityTypeAssignToContact,
            UIActivityTypeOpenInIBooks,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToTencentWeibo,
            UIActivityTypePostToVimeo,
            UIActivityTypeSaveToCameraRoll
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func refreshTableView(refreshControl_: UIRefreshControl) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    @IBAction func editButtonPressed(sender: UIButton) {
        self.inEditingMode = !inEditingMode
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.tableView.reloadData()
        }
    }
    
    @IBAction func editGradeButtonPressed(sender: UIButton) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        ProfileRestAPIClass.getProfileGradeList({ (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.editGradeButtonPressed(sender)
                } else {
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        self.editGradeButtonPressed(sender)
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
                            
                            if let records = localData["record"].array {
                                var localR:[String: String] = [:]
                                for record in records {
                                    if let title = record["title"].string, let code = record["code"].string {
                                        localR.updateValue(code, forKey: title)
                                    }
                                }
                                
                                self.showChooseGradeDialog(localR)
                            }
                            break
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    // empty array received --> do nothing
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
            }) { (error) in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                })
                
                if self.retryCounter < CONNECTION_MAX_RETRY {
                    self.retryCounter += 1
                    self.editGradeButtonPressed(sender)
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
                            //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                            //                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            //                            self.postProfile()
                            //                        })
                        //                    })
                        default:
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                            })
                        }
                    }
                }
        }
    }

    
    @IBAction func inviteFriendsButtonPressed(sender: UIButton) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.performSegueWithIdentifier("InviteFriendsVCSegue", sender: self)
        }
    }
    
    @IBAction func FreeMemoryButtonPressed(sender: UIButton) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            AlertClass.showAlertMessageCustom(viewController: self, title: "آیا مطمینید؟", message: "تنها اطلاعات محصولات حذف خواهند شد و مجددا قابل بارگذاری است", yesButtonTitle: "بله", noButtonTitle: "خیر", completion: {
                
                self.freeMemory()
            }, noCompletion: nil)
        }
    }
    
    @IBAction func helpButtonPressed(sender: UIBarButtonItem) {
        self.loadUrlString = UrlMakerSingleton.sharedInstance.getHelpUrl()!
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.performSegueWithIdentifier("SettingsWebviewVCSegue", sender: self)
        })        
    }
    
    public func reloadForSync() {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.tableView.reloadData()
        })
    }
    
    private func showChooseGradeDialog(values: [String:String]) {
        let alert = SimpleAlert.Controller(title: "متقاضی آزمون؟", message: "لطفا یکی از گزینه های زیر را انتخاب نمایید", style: .ActionSheet)
        alert.configContentView = { sview in
            if let v = sview as? SimpleAlert.ContentView {
                v.titleLabel.font = UIFont(name: "IRANSansMobile-Bold", size: 14)!
                v.messageLabel.font = UIFont(name: "IRANSansMobile", size: 12)!
                v.messageLabel.textColor = UIColor.darkGrayColor()
            }
        }
        
        alert.configContainerCornerRadius = {
            return 10.0
        }
        
//        for value in GradeTypeEnum.allValues {
//            let action = SimpleAlert.Action(title: value.toString(), style: .Default, handler: { (action) in
//                
//                self.changeGrade(title: value.rawValue)
//            })
//            
//            alert.addAction(action)
//            action.button.setTitleColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
//            action.button.titleLabel?.font = UIFont(name: "IRANSansMobile-Bold", size: 14)!
//        }
        for val in values {
            let action = SimpleAlert.Action(title: val.0, style: .Default, handler: { (action) in
                
                self.changeGrade(title: val.1, titleString: val.0)
            })
            
            alert.addAction(action)
            action.button.setTitleColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
            action.button.titleLabel?.font = UIFont(name: "IRANSansMobile-Bold", size: 14)!
        }
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    private func acquireButtonPressed(isLogout: Bool = false) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        DeviceRestAPIClass.deviceAcquire({ (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.acquireButtonPressed(isLogout)
                } else {
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        self.acquireButtonPressed(isLogout)
                        
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
                            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                            
                            var device_name = "ios"
                            var device_model = UIDevice.currentDevice().model
                            var isMe = true
                            
                            
                            if let device_name1 = localData["data"]["device_name"].string, let device_model1 = localData["data"]["device_model"].string {
                                
                                device_name = device_name1
                                device_model = device_model1
                                isMe = false
                            }
                            
                            DeviceInformationSingleton.sharedInstance.setDeviceState(username, device_name: device_name, device_model: device_model, state: false, isMe: isMe)
                            
                            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("StartupVC") as? StartupViewController {
                                SynchronizationSingleton.sharedInstance.stopSync()
                                vc.returnFormVC = .FromLock
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.presentViewController(vc, animated: true, completion: nil)
                                })
                                
                            }                            
                            
                            break
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
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
                            break
                        default:
                            break
                        }
                    }
                }
                
                if (isLogout) {
                    let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                    if KeyChainAccessProxy.clearAllValue() && UserDefaultsSingleton.sharedInstance.clearAll() {
                        
                        TokenHandlerSingleton.sharedInstance.invalidateTokens()
                        DeviceInformationSingleton.sharedInstance.clearAll(username)
                        
                        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("StartupVC") as? StartupViewController {
                            SynchronizationSingleton.sharedInstance.stopSync()
                            
                            vc.returnFormVC = .FromLock
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.presentViewController(vc, animated: true, completion: nil)
                            })
                        }
                    }
                    
                }
            }
            
            }) { (error) in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    AlertClass.hideLoaingMessage(progressHUD: self.loading)
                })
                
                if self.retryCounter < CONNECTION_MAX_RETRY {
                    self.retryCounter += 1
                    self.acquireButtonPressed(isLogout)
                    
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
                            //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                            //                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            //                            self.postProfile()
                            //                        })
                        //                    })
                        default:
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                            })
                        }
                    }
                    
                    if (isLogout) {
                        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                        if KeyChainAccessProxy.clearAllValue() && UserDefaultsSingleton.sharedInstance.clearAll() {
                            
                            TokenHandlerSingleton.sharedInstance.invalidateTokens()
                            DeviceInformationSingleton.sharedInstance.clearAll(username)
                            
                            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("StartupVC") as? StartupViewController {
                                SynchronizationSingleton.sharedInstance.stopSync()
                                vc.returnFormVC = .FromLock
                                
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.presentViewController(vc, animated: true, completion: nil)
                                })
                            }
                        }
                        
                    }
                }
        }
        
    }
    
    @IBAction func logoutSystemPressed(sender: UIButton) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            AlertClass.showAlertMessageCustom(viewController: self, title: "آیا مطمینید!؟", message: "خروج موقت از سیستم", yesButtonTitle: "بله", noButtonTitle: "خیر", completion: {
    
                NSOperationQueue.mainQueue().addOperationWithBlock {
//                    let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                    
//                    let purchasedItems = PurchasedModelHandler.getAllPurchased(username: username)
//                    for item in purchasedItems {
//                        self.deletePurchaseData(uniqueId: item.productUniqueId)
//                    }
                    
                    self.acquireButtonPressed(true)
                }
            }, noCompletion: nil)
        }
    }
    
    // MARK: - Functions
    func contactsSelected(list list: [(fullname: String, email: String)]) {
        var emails: [String] = []
        for item in list {
            emails.append(item.email)
        }
        
        SettingsRestAPIClass.inviteFriends(emails: emails, completion: { (data, error) in
            if error != HTTPErrorType.Success {
                // sometimes happened
                if error == HTTPErrorType.Refresh {
                    self.contactsSelected(list: list)
                } else {
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        self.contactsSelected(list: list)
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
                            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                AlertClass.showAlertMessage(viewController: self, messageType: "ActionResult", messageSubType: "InviteSuccess", type: "success", completion: nil)
                            })
                        default:
                            break
                        }
                    }
                }
            }            
        }) { (error) in
            if self.retryCounter < CONNECTION_MAX_RETRY {
                self.retryCounter += 1
                self.contactsSelected(list: list)
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
    }
    
    private func freeMemory() {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
            
            let purchasedItems = PurchasedModelHandler.getAllPurchased(username: username)
            for item in purchasedItems {
                self.deletePurchaseData(uniqueId: item.productUniqueId, username: username)
            
                if PurchasedModelHandler.resetDownloadFlags(username: username, id: item.id) == true {
                    
                    if item.productType == "Entrance" {
                        EntrancePackageHandler.removePackage(username: username, entranceUniqueId: item.productUniqueId)
                        EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId, username: username)
                        EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId, username: username)
                        EntranceQuestionCommentModelHandler.removeAllCommentOfEnrance(entranceUniqueId: item.productUniqueId, username: username)
                        
                        EntranceLastVisitInfoModelHandler.removeByEntranceId(username: username, uniqueId: item.productUniqueId)
                        EntranceQuestionCommentModelHandler.removeAllCommentOfEnrance(entranceUniqueId: item.productUniqueId, username: username)
                        EntranceLessonExamModelHandler.removeAllExamsByEntranceId(username: username, entranceUniqueId: item.productUniqueId)
                        EntranceQuestionExamStatModelHandler.removeAllStatsByEntranceId(username: username, entranceUniqueId: item.productUniqueId)
                        
                    }
                }
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
                AlertClass.showTopMessage(viewController: self, messageType: "ActionResult", messageSubType: "FreeMemorySuccess", type: "success", completion: nil)
            })            
        }
    }
    
    private func deletePurchaseData(uniqueId uniqueId: String, username: String) {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        
        let pathAdd = "\(username)_\(uniqueId)"
        var newDir = docsDir.stringByAppendingPathComponent(pathAdd)
        
        var isDir: ObjCBool = false
        if filemgr.fileExistsAtPath(newDir, isDirectory: &isDir) == true {
            if isDir {
            }
        } else {
            newDir = docsDir.stringByAppendingPathComponent(uniqueId)
        }
        
        do {
            
            try filemgr.removeItemAtPath(newDir)
        } catch {}
    }
    
    
    
    
    private func changeGrade(title title: String, titleString: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        ProfileRestAPIClass.putProfileGrade(grade: title, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.changeGrade(title: title, titleString: titleString)
                } else {
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        self.changeGrade(title: title, titleString: titleString)
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
                            var modified = NSDate()
                            if let m = localData["modified"].string {
                                modified = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(m)!
                            }
                            
                            // update user defaults
                            UserDefaultsSingleton.sharedInstance.updateGrade(grade: title, gradeString: titleString, modified: modified)
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                self.tableView.reloadData()
                            })
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "UserNotExist":
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
            
            if self.retryCounter < CONNECTION_MAX_RETRY {
                self.retryCounter += 1
                self.changeGrade(title: title, titleString: titleString)
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
                        //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        //                        NSOperationQueue.mainQueue().addOperationWithBlock({
                        //                            self.postProfile()
                        //                        })
                    //                    })
                    default:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            fallthrough
        case 2:
            let v = UIView(frame: CGRectMake(0, 0, self.tableView.frame.width, 30))
            v.backgroundColor = UIColor(white:0.95, alpha: 1.0)
            return v
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0
        case 1:
            fallthrough
        case 2:
            return 30.0
        default:
            return 0.0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if self.inEditingMode {
                return 6
            }
            return 5
        case 2:
            return 3
        default:
            break
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_HEADER", forIndexPath: indexPath) as? SettingsHeaderTableViewCell {
                    
                    if let item = UserDefaultsSingleton.sharedInstance.getProfile() {
                        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                    
                        cell.configureCell(fullname: "\((item.firstname)) \((item.lastname))", username: username, lastChanged: (item.modified), isEditing: self.inEditingMode)
                        
                        cell.editButton.addTarget(self, action: #selector(self.editButtonPressed(_:)), forControlEvents: .TouchUpInside)
                    }
                    return cell
                }
            }
        case 1:
            switch indexPath.row {
            case 0:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_GRADE", forIndexPath: indexPath) as? SettingsGradeTableViewCell {
                    
                    if let item = UserDefaultsSingleton.sharedInstance.getProfile() {
                        
    //                    let gradeStr = GradeTypeEnum.selectWithString((item?.grade)!).toString()
                        let gradeStr = item.gradeString
                        cell.configureCell(gradeTitle: gradeStr, isEditing: self.inEditingMode)
                        
                        cell.changeButton.addTarget(self, action: #selector(self.editGradeButtonPressed(_:)), forControlEvents: .TouchUpInside)
                    }
                    
                    return cell
                }
            case 1:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_WALLET", forIndexPath: indexPath) as? SettingsWalletTableViewCell {
                    
                    var cost = 0
                    if UserDefaultsSingleton.sharedInstance.hasProfile() {
                        if UserDefaultsSingleton.sharedInstance.hasWallet() {
                            cost = UserDefaultsSingleton.sharedInstance.getWalletInfo()!.cash
                        }
                        
                    }
                    
                    cell.configureCell(cost: cost)
                    return cell
                }
            case 2:
                if self.inEditingMode {
                    if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_‌OPTION", forIndexPath: indexPath) as? SettingsOptionTableViewCell {
                        
                        cell.configureCell(optionTitle: "تغییر گذرواژه", type: "option", showAccessory: false, iconName: "PasswordFilled")
                        return cell
                    }
                } else {
                    if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_‌OPTION", forIndexPath: indexPath) as? SettingsOptionTableViewCell {
                        
                        cell.configureCell(optionTitle: "درباره ما", type: "normal", showAccessory: true, iconName: "AboutFilled")
                        return cell
                    }
                }
            case 3:
                if self.inEditingMode {
                    if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_‌OPTION", forIndexPath: indexPath) as? SettingsOptionTableViewCell {
                        
                        cell.configureCell(optionTitle: "پاک کردن حافظه نهانی", type: "option", showAccessory: false, iconName: "HousekeepingFilled")
                        return cell
                    }
                } else {
                    if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_‌OPTION", forIndexPath: indexPath) as? SettingsOptionTableViewCell {
                        
                        cell.configureCell(optionTitle: "پیشنهاد و انتقاد", type: "normal", showAccessory: true, iconName: "BugFilled")
                        return cell
                    }
                }
            case 4:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_‌OPTION", forIndexPath: indexPath) as? SettingsOptionTableViewCell {
                    
                    cell.configureCell(optionTitle: "قفل کردن دستگاه", type: "option", showAccessory: false, iconName: "PhonelinkLockFilled")
                    return cell
                }
            case 5:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_LOGOUT", forIndexPath: indexPath) as? SettingsLogoutTableViewCell {
                    
                    cell.configureCell(optionTitle: "خروج از سیستم", iconName: "LogoutFilled")
                    cell.optionButton.addTarget(self, action: #selector(self.logoutSystemPressed(_:)), forControlEvents: .TouchUpInside)
                    
                    return cell
                }
                
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_‌OPTION", forIndexPath: indexPath) as? SettingsOptionTableViewCell {
                    
                    cell.configureCell(optionTitle: "گزارش خطا", type: "normal", showAccessory: true, iconName: "BugFilled")
                    return cell
                }
            case 1:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_‌OPTION", forIndexPath: indexPath) as? SettingsOptionTableViewCell {
                    
                    cell.configureCell(optionTitle: "درباره ما", type: "normal", showAccessory: true, iconName: "AboutFilled")
                    return cell
                }
            case 2:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_LOGOUT", forIndexPath: indexPath) as? SettingsLogoutTableViewCell {
                    
                    cell.configureCell(optionTitle: "خروج از سیستم", iconName: "LogoutFilled")
                    cell.optionButton.addTarget(self, action: #selector(self.logoutSystemPressed(_:)), forControlEvents: .TouchUpInside)
                    
                    return cell
                }
            default:
                break
            }
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 120.0
        case 1:
            if indexPath.row == 0 {
                return 55.0
            } else {
                return 45.0
            }
        case 2:
            return 45.0
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 2:
                if self.inEditingMode {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.performSegueWithIdentifier("ChangePasswordVCSegue", sender: self)
                    })
                } else {
                    self.loadUrlString = UrlMakerSingleton.sharedInstance.getAboutUrl()!
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.performSegueWithIdentifier("SettingsWebviewVCSegue", sender: self)
                    })
                }
            case 3:
                if self.inEditingMode {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        AlertClass.showAlertMessageCustom(viewController: self, title: "آیا مطمینید؟", message: "تنها اطلاعات محصولات حذف خواهند شد و مجددا قابل بارگذاری است", yesButtonTitle: "بله", noButtonTitle: "خیر", completion: {
                            
                            self.freeMemory()
                            }, noCompletion: nil)
                    }
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.performSegueWithIdentifier("SettingsReportBugVCSegue", sender: self)
                    })
                }
            case 4:
                self.acquireButtonPressed()
                //                NSOperationQueue.mainQueue().addOperationWithBlock {
                //                    self.performSegueWithIdentifier("InviteFriendsVCSegue", sender: self)
            //                }
            default:
                break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    self.performSegueWithIdentifier("SettingsReportBugVCSegue", sender: self)
                })
            case 1:
                self.loadUrlString = UrlMakerSingleton.sharedInstance.getAboutUrl()!
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    self.performSegueWithIdentifier("SettingsWebviewVCSegue", sender: self)
                })
            default:
                break
            }
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SettingsWebviewVCSegue" {
            if let vc = segue.destinationViewController as? SettingsWebviewViewController {
                vc.loadingAddress = self.loadUrlString
                vc.hidesBottomBarWhenPushed = true
            }
        } else if segue.identifier == "InviteFriendsVCSegue" {
            if let vc = segue.destinationViewController as? ContactsTableViewController {
                vc.navigationItem.setHidesBackButton(true, animated: true)
                vc.delegate = self
            }
        }
    }

}
