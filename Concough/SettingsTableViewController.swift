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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.tableFooterView = UIView()
        
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "برای به روز رسانی به پایین بکشید", attributes: [NSFontAttributeName: UIFont(name: "IRANYekanMobile-Light", size: 12)!])
        }
        self.refreshControl?.addTarget(self, action: #selector(self.refreshTableView(_:)), forControlEvents: .ValueChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    @IBAction func shareButtonPressed(sender: UIBarButtonItem) {
        let first = "کنکوق"
        let second: NSURL = NSURL(string: BASE_URL)!
        let image: UIImage = UIImage(named: "dropbox")!
        
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
    
    @IBAction func editGradeButtonPressed(sender: UIButton) {
        let alert = SimpleAlert.Controller(title: "متقاضی کنکور؟", message: "لطفا یکی از گزینه های زیر را انتخاب نمایید", style: .ActionSheet)
        alert.configContentView = { sview in
            if let v = sview as? SimpleAlert.ContentView {
                v.titleLabel.font = UIFont(name: "IRANYekanMobile-Bold", size: 14)!
                v.messageLabel.font = UIFont(name: "IRANYekanMobile", size: 12)!
                v.messageLabel.textColor = UIColor.darkGrayColor()
            }
        }
        
        alert.configContainerCornerRadius = {
            return 10.0
        }
        
        for value in GradeTypeEnum.allValues {
            let action = SimpleAlert.Action(title: value.toString(), style: .Default, handler: { (action) in
                
                self.changeGrade(title: value.rawValue)
            })
            
            alert.addAction(action)
            action.button.setTitleColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
            action.button.titleLabel?.font = UIFont(name: "IRANYekanMobile-Bold", size: 14)!
        }
        
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.presentViewController(alert, animated: true, completion: nil)
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
            })
        }
    }
    
    @IBAction func helpButtonPressed(sender: UIBarButtonItem) {
        self.loadUrlString = UrlMakerSingleton.sharedInstance.getHelpUrl()!
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.performSegueWithIdentifier("SettingsWebviewVCSegue", sender: self)
        })        
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
                    
                    if KeyChainAccessProxy.clearAllValue() && UserDefaultsSingleton.sharedInstance.clearAll() {
                        TokenHandlerSingleton.sharedInstance.invalidateTokens()
                        
                        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("StartupVC") as? StartupViewController {
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.presentViewController(vc, animated: true, completion: nil)
                            })
                        }
                    }
                }
            })
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
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                    })
                }
            } else {
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
    
    private func freeMemory() {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
            
            let purchasedItems = PurchasedModelHandler.getAllPurchased(username: username)
            for item in purchasedItems {
                self.deletePurchaseData(uniqueId: item.productUniqueId)
            
                if PurchasedModelHandler.resetDownloadFlags(username: username, id: item.id) == true {
                    
                    EntrancePackageHandler.removePackage(username: username, entranceUniqueId: item.productUniqueId)
                    EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId)
                    EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId)
                }
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
                AlertClass.showTopMessage(viewController: self, messageType: "ActionResult", messageSubType: "FreeMemorySuccess", type: "success", completion: nil)
            })            
        }
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
    
    
    private func changeGrade(title title: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        ProfileRestAPIClass.putProfileGrade(grade: title, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.changeGrade(title: title)
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                    })
                }
            } else {
                if let localData = data {
                    print(localData)
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            var modified = NSDate()
                            if let m = localData["modified"].string {
                                modified = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(m)!
                            }
                            
                            print("--> \(modified)")
                            // update user defaults
                            UserDefaultsSingleton.sharedInstance.updateGrade(grade: title, modified: modified)
                            
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
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            fallthrough
        case 2:
            let v = UIView(frame: CGRectMake(0, 0, self.tableView.frame.width, 30))
            v.backgroundColor = UIColor.whiteColor()
            return v
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            fallthrough
        case 2:
            return 30.0
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 4
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
                    
                    let item = UserDefaultsSingleton.sharedInstance.getProfile()
                    cell.configureCell(fullname: "\((item?.firstname)!) \((item?.lastname)!)", lastChanged: (item?.modified)!)
                    return cell
                }
            }
        case 1:
            switch indexPath.row {
            case 0:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_GRADE", forIndexPath: indexPath) as? SettingsGradeTableViewCell {
                    
                    let item = UserDefaultsSingleton.sharedInstance.getProfile()
                    let gradeStr = GradeTypeEnum.selectWithString((item?.grade)!).toString()
                    cell.configureCell(gradeTitle: gradeStr)
                    
                    cell.changeButton.addTarget(self, action: #selector(self.editGradeButtonPressed(_:)), forControlEvents: .TouchUpInside)
                    
                    return cell
                }
            case 1:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_‌OPTION", forIndexPath: indexPath) as? SettingsOptionTableViewCell {
                    
                    cell.configureCell(optionTitle: "تغییر گذرواژه", type: "option", showAccessory: false, iconName: "PasswordFilled")
                    return cell
                }
            case 2:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_‌OPTION", forIndexPath: indexPath) as? SettingsOptionTableViewCell {
                    
                    cell.configureCell(optionTitle: "دعوت از دوستان", type: "option", showAccessory: false, iconName: "InviteFilled")
                    return cell
                }
            case 3:
                if let cell = self.tableView.dequeueReusableCellWithIdentifier("SETTINGS_‌OPTION", forIndexPath: indexPath) as? SettingsOptionTableViewCell {
                    
                    cell.configureCell(optionTitle: "پاک کردن حافظه نهانی", type: "option", showAccessory: false, iconName: "HousekeepingFilled")
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
            return 75.0
        case 1:
            if indexPath.row == 0 {
                return 45.0
            } else {
                return 35.0
            }
        case 2:
            return 40.0
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 1:
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    self.performSegueWithIdentifier("ChangePasswordVCSegue", sender: self)
                })
            case 2:
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("InviteFriendsVCSegue", sender: self)
                }
            case 3:
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    AlertClass.showAlertMessageCustom(viewController: self, title: "آیا مطمینید؟", message: "تنها اطلاعات محصولات حذف خواهند شد و مجددا قابل بارگذاری است", yesButtonTitle: "بله", noButtonTitle: "خیر", completion: {
                        
                        self.freeMemory()
                    })
                }
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
