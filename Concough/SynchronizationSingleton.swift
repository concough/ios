//
//  SynchronizationSingleton.swift
//  Concough
//
//  Created by Owner on 2018-05-24.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SynchronizationSingleton {
    private let DELAY_TIMER_DOWN: NSTimeInterval = SYNC_INTERVAL
    private let DELAY_TIMER_LOG: NSTimeInterval = SYNC_LOG_INTERVAL
    static let sharedInstance = SynchronizationSingleton()
    
    private var filemgr: NSFileManager!
    private var queue: NSOperationQueue
    private var syncDownTimer: NSTimer!
    private var syncLogTimer: NSTimer!
    private var i = 0
    private var retryCounterArray: [String: Int] = [:]
    private var retryCounterLog = 0
    private var direction = "UP"
    private var sessionCounter:UInt = 0
    
    private init() {
        self.filemgr = NSFileManager.defaultManager()
        self.queue = NSOperationQueue()
        self.queue.maxConcurrentOperationCount = 1
        
        for item in SYNC_LIST {
            self.retryCounterArray.updateValue(0, forKey: item)
        }
    }
    
    internal func startSync() {
        self.queue.addOperationWithBlock({
            self.checkVersion()
        })
        
        self.syncDownTimerTick()
        self.syncLogTimerTick()

        self.syncDownTimer = NSTimer.scheduledTimerWithTimeInterval(self.DELAY_TIMER_DOWN, target: self, selector: #selector(self.syncDownTimerTick), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(self.syncDownTimer, forMode: NSRunLoopCommonModes)

        self.syncLogTimer = NSTimer.scheduledTimerWithTimeInterval(self.DELAY_TIMER_LOG, target: self, selector: #selector(self.syncLogTimerTick), userInfo: nil, repeats: true)

        NSRunLoop.mainRunLoop().addTimer(self.syncLogTimer, forMode: NSRunLoopCommonModes)
    }

    internal func stopSync() {
        self.syncDownTimer.invalidate()
        self.syncLogTimer.invalidate()
    }
    
    @objc private func syncDownTimerTick() {
//        self.queue.cancelAllOperations()
        
        for item in SYNC_LIST {
            switch item {
            case "FAVOURITES":
                self.queue.addOperationWithBlock({
                    self.syncWithServer()
                })
            case "LOCK":
                self.queue.addOperationWithBlock({
                    self.checkDeviceStateWithServer()
                })
            case "WALLET":
                self.queue.addOperationWithBlock({
                    self.createWallet()
                })
//            case "CHECK_VERSION":
//                self.queue.addOperationWithBlock({
//                    self.checkVersion()
//                })
            default:
                break
            }
        }
    }
    
    @objc private func syncLogTimerTick() {
        if self.direction == "UP" {
            self.syncLogWithServerUP()
        }
    }
    
    internal var logbackgroundCompletionHandler: (() -> Void)? {
        get {
            return self.logBackgroundManager.backgroundCompletionHandler
        }
        set {
            self.logBackgroundManager.backgroundCompletionHandler = newValue
        }
    }
    
    private lazy var logBackgroundManager: Alamofire.Manager = {
        let bundle = "Synchronization:log"
        
        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundle)
        
        config.discretionary = true
        config.allowsCellularAccess = true
        config.sessionSendsLaunchEvents = true
        
        var manager = Alamofire.Manager(configuration: config)
        manager.delegate.sessionDidFinishEventsForBackgroundURLSession = { session in
            if let compl = self.logbackgroundCompletionHandler {
                compl()
                self.logbackgroundCompletionHandler = nil
            }
        }
        return manager
    }()

    internal var favbackgroundCompletionHandler: (() -> Void)? {
        get {
            return self.favBackgroundManager.backgroundCompletionHandler
        }
        set {
            self.favBackgroundManager.backgroundCompletionHandler = newValue
        }
    }
    
    private lazy var favBackgroundManager: Alamofire.Manager = {
        let bundle = "Synchronization:fav"
        
        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundle)
        
        config.discretionary = true
        config.allowsCellularAccess = true
        config.sessionSendsLaunchEvents = true
        
        var manager = Alamofire.Manager(configuration: config)
        manager.delegate.sessionDidFinishEventsForBackgroundURLSession = { session in
            if let compl = self.favbackgroundCompletionHandler {
                compl()
                self.favbackgroundCompletionHandler = nil
            }
        }
        return manager
    }()
    
    
    internal var verbackgroundCompletionHandler: (() -> Void)? {
        get {
            return self.verBackgroundManager.backgroundCompletionHandler
        }
        set {
            self.verBackgroundManager.backgroundCompletionHandler = newValue
        }
    }
    
    private lazy var verBackgroundManager: Alamofire.Manager = {
        let bundle = "Synchronization:ver"
        
        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundle)
        
        config.discretionary = true
        config.allowsCellularAccess = true
        config.sessionSendsLaunchEvents = true
        
        var manager = Alamofire.Manager(configuration: config)
        manager.delegate.sessionDidFinishEventsForBackgroundURLSession = { session in
            if let compl = self.verbackgroundCompletionHandler {
                compl()
                self.verbackgroundCompletionHandler = nil
            }
        }
        return manager
    }()

    internal var lockbackgroundCompletionHandler: (() -> Void)? {
        get {
            return self.lockBackgroundManager.backgroundCompletionHandler
        }
        set {
            self.lockBackgroundManager.backgroundCompletionHandler = newValue
        }
    }
    
    private lazy var lockBackgroundManager: Alamofire.Manager = {
        let bundle = "Synchronization:lock"
        
        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundle)
        
        config.discretionary = true
        config.allowsCellularAccess = true
        config.sessionSendsLaunchEvents = true
        
        var manager = Alamofire.Manager(configuration: config)
        manager.delegate.sessionDidFinishEventsForBackgroundURLSession = { session in
            if let compl = self.lockbackgroundCompletionHandler {
                compl()
                self.lockbackgroundCompletionHandler = nil
            }
        }
        return manager
    }()

    internal var walletbackgroundCompletionHandler: (() -> Void)? {
        get {
            return self.walletBackgroundManager.backgroundCompletionHandler
        }
        set {
            self.walletBackgroundManager.backgroundCompletionHandler = newValue
        }
    }
    
    private lazy var walletBackgroundManager: Alamofire.Manager = {
        let bundle = "Synchronization:wallet"
        
        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundle)
        
        config.discretionary = true
        config.allowsCellularAccess = true
        config.sessionSendsLaunchEvents = true
        
        var manager = Alamofire.Manager(configuration: config)
        manager.delegate.sessionDidFinishEventsForBackgroundURLSession = { session in
            if let compl = self.walletbackgroundCompletionHandler {
                compl()
                self.walletbackgroundCompletionHandler = nil
            }
        }
        return manager
    }()
    
    
    private func checkVersion() {
        SettingsRestAPIClass.appLastVersionWithManager(manager: self.verBackgroundManager, completion: { (data, error) in
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.checkVersion()
                }
                
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            // profile exist
                            if let version = localData["version"].int, let released = localData["released"].string, let link = localData["link"].string {
                                
                                var showMsg = false
                                
                                if version > APP_VERSION {
                                    kCFNumberFormatterAlwaysShowDecimalSeparator
                                    if let existVer = DeviceInformationSingleton.sharedInstance.getLastAppVersion() {
                                        if version > existVer {
                                            showMsg = true
                                        } else {
                                            let count = DeviceInformationSingleton.sharedInstance.getLastAppVersionCount(version)
                                            
                                            if count <= 3 {
                                                showMsg = true
                                            }
                                        }
                                        
                                    } else {
                                        showMsg = true
                                    }
                                    DeviceInformationSingleton.sharedInstance.putLastAppVersion(version)
                                }
                                
                                if showMsg {
                                    let (title, _, _) = AlertClass.convertMessage(messageType: "DeviceAction", messageSubType: "UpdateApp")
                                    
                                    let date = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(released)
                                    
                                    
                                    let newMsg: String = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(version)!
                                    let persianDate: String = FormatterSingleton.sharedInstance.IRDateFormatter.stringFromDate(date!)
                                    
                                    let msg = " نسخه\(newMsg) منتشر شده است\nتاریخ: \(persianDate)"
                                    
                                    if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                                        while let presentedViewController = topController.presentedViewController {
                                            topController = presentedViewController
                                        }

                                        AlertClass.showSuccessMessageCustom(viewController: topController, title: title, message: msg, yesButtonTitle: "دانلود", noButtonTitle: "بعدا", completion: {
                                            
                                            UIApplication.sharedApplication().openURL(NSURL(string: link)!)
                                            
                                            }, noCompletion: {
                                        })
                                    }
                                }
                            }
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    // profile not exist --> perform navigation
                                    fallthrough
                                default:
                                    break
                                }
                            }
                            fallthrough
                        default:
                            break
                        }
                    }
                }
            }
        }) { (error) in
        }
    }
    
    private func syncLogWithServerUP() {
        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
        let (items, count) = UserLogModelHandler.list(username: username)
        
        var limit = SYNC_LOG_LIMIT
        if count < limit {
            limit = count
        }
        
        var jsonArray: [AnyObject] = []
        for i in 0..<limit {
            let item = items[i]
            
            let encodedString : NSData = (item.extraData as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
            
            let d: [String: AnyObject] = [
                "uniqueId": item.uniqueId,
                "logType": item.logType,
                "extra": JSON.init(data: encodedString).dictionaryObject!,
                "time": item.created.timeIntervalSince1970
            ]
            
            jsonArray.append(d)
        }
        
        if jsonArray.count == 0 {
            return
        }
        UserLogRestAPIClass.syncUpWithManager(manager: self.logBackgroundManager, data: jsonArray, completion: { (data, error) in
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.syncLogWithServerUP()
                } else {
                    if self.retryCounterLog < CONNECTION_MAX_RETRY {
                        self.retryCounterLog += 1
                            self.syncLogWithServerUP()
                    } else {
                        self.retryCounterLog = 0
                    }
                }
            } else {
                self.retryCounterLog = 0
                
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            if let records = localData["records"].array {
                                for rec in records {
                                    let id = rec.stringValue
                                    UserLogModelHandler.removeByUniqueId(username: username, uniqueId: id)
                                }
                            }
                            break
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
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
            
            if self.retryCounterLog < CONNECTION_MAX_RETRY {
                self.retryCounterLog += 1
                    self.syncLogWithServerUP()
            } else {
                self.retryCounterLog = 0
            }
        }
    
    }
    
    private func syncWithServer() {
        PurchasedRestAPIClass.getPurchasedListWithManager(manager: self.favBackgroundManager, completion: { (data, error) in
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.syncWithServer()
                    })
                    self.queue.addOperation(operation)
                    
                } else {
                    if self.retryCounterArray["FAVOURITES"] < CONNECTION_MAX_RETRY {
                        self.retryCounterArray["FAVOURITES"]! += 1

                        let operation = NSBlockOperation(block: {
                            self.syncWithServer()
                        })
                        self.queue.addOperation(operation)
                        
                    } else {
                        self.retryCounterArray["FAVOURITES"] = 0
                        
                    }
                }
            } else {
                self.retryCounterArray["FAVOURITES"] = 0
                
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            
                            var purchasedId: [Int] = []
                            var images: [String: [Int:NSDate]] = [:]
                            images.updateValue([:], forKey: "Entrance")
                            
                            let records = localData["records"].arrayValue
                            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                            for record in records {
                                let id = record["id"].intValue
                                let downloaded = record["downloaded"].intValue
                                let createdStr = record["created"].stringValue
                                let created = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(createdStr)
                                
                                if PurchasedModelHandler.getByUsernameAndId(id: id, username: username) != nil {
                                    PurchasedModelHandler.updateDownloadTimes(username: username, id: id, newDownloadTimes: downloaded)
                                    
                                    let target = record["target"]
                                    let targetType = target["product_type"].stringValue
                                    
                                    if targetType == "Entrance" {
                                        let uniqueId = target["unique_key"].stringValue
                                        let month = target["month"].intValue
                                        
                                        if let item = EntranceModelHandler.getByUsernameAndId(id: uniqueId, username: username) {
                                            if item.month != month {
                                                EntranceModelHandler.correctMonthOfEntrance(id: uniqueId, username: username, month: month)
                                            }
                                            
                                            
                                        }

                                        let setId = target["entrance_set"]["id"].intValue
                                        let setUpdatedStr = target["entrance_set"]["updated"].stringValue
                                        let setUpdated = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(setUpdatedStr)
                                        
                                        images["Entrance"]?.updateValue(setUpdated!, forKey: setId)
                                    }
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
                                            let month = target["month"].intValue
                                            let extraData = JSON(data: target["extra_data"].stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
                                            
                                            let lastPablishedStr = target["last_published"].stringValue
                                            let lastPublished = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(lastPablishedStr)
                                            
                                            let setUpdatedStr = target["entrance_set"]["updated"].stringValue
                                            let setUpdated = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(setUpdatedStr)
                                            
                                            images["Entrance"]?.updateValue(setUpdated!, forKey: setId)
                                            
                                            if EntranceModelHandler.getByUsernameAndId(id: uniqueId, username: username) == nil {
                                                let entrance = EntranceStructure(entranceTypeTitle: type, entranceOrgTitle: org, entranceGroupTitle: group, entranceSetTitle: setName, entranceSetId: setId, entranceExtraData: extraData, entranceBookletCounts: bookletsCount, entranceYear: year, entranceMonth: month, entranceDuration: duration, entranceUniqueId: uniqueId, entranceLastPublished: lastPublished)
                                                
                                                EntranceModelHandler.add(entrance: entrance, username: username)
                                                
                                            }
                                        }
                                    }
                                }
                                
                                purchasedId.append(id)
                            }
                            
                            // delete all that does not exist
                            let deletedItems = PurchasedModelHandler.getAllPurchasedNotIn(username: username, ids: purchasedId)
                            
                            if deletedItems.count > 0 {
                                for item in deletedItems {
                                    self.deletePurchaseData(uniqueId: item.productUniqueId, username: username)
                                    
                                    // delete product and purchase
                                    if item.productType == "Entrance" {
                                        if EntranceModelHandler.removeById(id: item.productUniqueId, username: username) == true {
                                            
                                            EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId, username: username)
                                            EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId, username: username)
                                            PurchasedModelHandler.removeById(username: username, id: item.id)
                                            
                                        }
                                    }
                                }
                            }
                            
                            if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                                while let presentedViewController = topController.presentedViewController {
                                    topController = presentedViewController
                                }
                                
                                if let vc = topController as? FavoritesTableViewController {
                                    vc.reloadData()
                                }
                            }
                            
                            self.downloadImages(purchasedId, images: images)
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    // All purchased must be deleted
                                    let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                                    let items = PurchasedModelHandler.getAllPurchased(username: username)
                                    for item in items {
                                        self.deletePurchaseData(uniqueId: item.productUniqueId, username: username)
                                        
                                        // delete product and purchase
                                        if item.productType == "Entrance" {
                                            if EntranceModelHandler.removeById(id: item.productUniqueId, username: username) == true {
                                                
                                                EntranceOpenedCountModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId, username: username)
                                                EntranceQuestionStarredModelHandler.removeByEntranceId(entranceUniqueId: item.productUniqueId, username: username)
                                                PurchasedModelHandler.removeById(username: username, id: item.id)
                                                
                                            }
                                        }
                                    }
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
            
            if self.retryCounterArray["FAVOURITES"] < CONNECTION_MAX_RETRY {
                self.retryCounterArray["FAVOURITES"]! += 1

                let operation = NSBlockOperation(block: {
                    self.syncWithServer()
                })
                self.queue.addOperation(operation)

            } else {
                self.retryCounterArray["FAVOURITES"] = 0
            }
        }
    }
    
    private func createWallet() {
        WalletRestAPIClass.infoWithManager(manager: self.walletBackgroundManager, completion: { (data, error) in
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    let operation = NSBlockOperation(block: {
                        self.createWallet()
                    })
                    self.queue.addOperation(operation)
                    
                } else {
                    if self.retryCounterArray["WALLET"] < CONNECTION_MAX_RETRY {
                        self.retryCounterArray["WALLET"]! += 1
                        let operation = NSBlockOperation(block: {
                            self.createWallet()
                        })
                        self.queue.addOperation(operation)
                    } else {
                        self.retryCounterArray["WALLET"] = 0
                    }
                }
            } else {
                self.retryCounterArray["WALLET"] = 0
                
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            let wallet_record = localData["record"]
                            let cash = wallet_record["cash"].intValue
                            
                            var updated = NSDate()
                            if let m = wallet_record["updated"].string {
                                updated = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(m)!
                            }
                            
                            UserDefaultsSingleton.sharedInstance.setWalletInfo(cash: cash, updated: updated)
                            
                            if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                                while let presentedViewController = topController.presentedViewController {
                                    topController = presentedViewController
                                }
                                
                                if let vc = topController as? SettingsTableViewController {
                                    vc.reloadForSync()
                                }
                            }
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
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
            
            if self.retryCounterArray["WALLET"] < CONNECTION_MAX_RETRY {
                self.retryCounterArray["WALLET"]! += 1
                let operation = NSBlockOperation(block: {
                    self.createWallet()
                })
                self.queue.addOperation(operation)
            } else {
                self.retryCounterArray["WALLET"] = 0
            }
        }
    }
    
    private func checkDeviceStateWithServer() {
        DeviceRestAPIClass.deviceStateWithManager(manager: self.lockBackgroundManager, completion: { (data, error) in
            if error != HTTPErrorType.Success {
                // sometimes happened
                if error == HTTPErrorType.Refresh {
                    self.checkDeviceStateWithServer()
                } else {
                    if self.retryCounterArray["LOCK"] < CONNECTION_MAX_RETRY {
                        self.retryCounterArray["LOCK"]! += 1
                        self.checkDeviceStateWithServer()
                    } else {
                        self.retryCounterArray["LOCK"] = 0
                    }
                }
            } else {
                self.retryCounterArray["LOCK"] = 0
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            if let state = localData["data"]["state"].bool, let device_unique_id = localData["data"]["device_unique_id"].string {
                                
                                var uuid: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
                                if let temp = KeyChainAccessProxy.getValue(IDENTIFIER_FOR_VENDOR_KEY) as? String {
                                    uuid = temp
                                }
                                
                                if device_unique_id == uuid {
                                    // ok --> valid
                                    if state == false {
                                        let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                                        DeviceInformationSingleton.sharedInstance.setDeviceState(username, device_name: "ios", device_model: UIDevice.currentDevice().type.rawValue, state: false, isMe: true)
                                        self.setupLocked()
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
                                        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                                            while let presentedViewController = topController.presentedViewController {
                                                topController = presentedViewController
                                            }
                                            AlertClass.showAlertMessage(viewController: topController, messageType: "DeviceInfoError", messageSubType: errorType, type: "error", completion: {
                                                let error_data = localData["error_data"]
                                                let device_name = error_data["device_name"].string
                                                let device_model = error_data["device_model"].string
                                                
                                                if DeviceInformationSingleton.sharedInstance.setDeviceState(username, device_name: device_name!, device_model: device_model!, state: false, isMe: false) {
                                                }
                                                
                                                self.setupLocked()
                                            })
                                        }
                                        
                                    })
                                    break
                                case "UserNotExit": fallthrough
                                case "DeviceNotRegistered":
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
            if self.retryCounterArray["LOCK"] < CONNECTION_MAX_RETRY {
                self.retryCounterArray["LOCK"]! += 1
                self.checkDeviceStateWithServer()
            } else {
                self.retryCounterArray["LOCK"] = 0
                
                if TokenHandlerSingleton.sharedInstance.isAuthorized() && TokenHandlerSingleton.sharedInstance.isAuthenticated() {
                    let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                    if let device = DeviceInformationModelHandler.findByUniqueId(username) {
                        if device.state == false {
                            self.setupLocked()
                        }
                    } else {
                        self.setupLocked()
                    }
                }
            }
        }
        
    }
    
    private func setupLocked() {
        self.stopSync()
        if let vs = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StartupVC") as? StartupViewController {
            
            if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                self.stopSync()
                vs.returnFormVC = .FromLock
                topController.presentViewController(vs, animated: true, completion: nil)
                
            }
            
        }
    }
    
    
    private func downloadImages(ids: [Int], images: [String: [Int:NSDate]]) {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        let newDir = docsDir.stringByAppendingPathComponent("images")
        
        let username: String = UserDefaultsSingleton.sharedInstance.getUsername()!
        let purchased = PurchasedModelHandler.getAllPurchasedIn(username: username, ids: ids)
        for p in purchased {
            if p.productType == "Entrance" {
                if let entrance = EntranceModelHandler.getByUsernameAndId(id: p.productUniqueId, username: username) {
                    var updated: NSDate? = nil
                    if let d = images[p.productType]![entrance.setId] {
                        updated = d
                    }
                    
                    downloadEsetImage(esetId: entrance.setId, rootDirectory: newDir, updated: updated)
                }
            }
        }
    }
    
    private func downloadEsetImage(esetId esetId: Int, rootDirectory: String, updated: NSDate?) {
        var mustDownload = true
        let esetDir = (rootDirectory as NSString).stringByAppendingPathComponent("eset")
        let filePath = (esetDir as NSString).stringByAppendingPathComponent(String(esetId))
        
        do {
            if self.filemgr?.fileExistsAtPath(esetDir) == false {
                try self.filemgr?.createDirectoryAtPath(esetDir, withIntermediateDirectories: true, attributes: nil)
            }
            
            
            if self.filemgr?.fileExistsAtPath(filePath) == true {
                let attrs = try self.filemgr.attributesOfItemAtPath(filePath)
                if let fileDate = attrs[NSFileCreationDate] as? NSDate {
                    if updated != nil {
                        let interval = updated!.timeIntervalSinceDate(fileDate)
                        
                        if interval < 60 * 60 * 12 {
                            mustDownload = false
                        }
                    }
                }
                
            }
            
        } catch {
            return
        }
        
        if mustDownload {
            MediaRestAPIClass.downloadEsetImageLocal(esetId, completion: {
                fullPath, data, error in
                
                if error != .Success {
                    if error == HTTPErrorType.Refresh {
                        self.downloadEsetImage(esetId: esetId, rootDirectory: rootDirectory, updated: updated)
                    } else {
                        //                    print("error in downloaing image from \(fullPath!)")
                    }
                } else {
                    if let myData = data {
                        
                        do {
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
        
    }
    
    
    private func deletePurchaseData(uniqueId uniqueId: String, username: String) {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        
        let pathAdd = "\(username)_\(uniqueId)"
        var newDir = docsDir.stringByAppendingPathComponent(pathAdd)
        
        var isDir: ObjCBool = false
        if self.filemgr.fileExistsAtPath(newDir, isDirectory: &isDir) == true {
            if isDir {
            }
        } else {
            newDir = docsDir.stringByAppendingPathComponent(uniqueId)
        }
        do {
            
            try self.filemgr.removeItemAtPath(newDir)
        } catch {}
    }
    
}
