//
//  EntrancePackageDownloader.swift
//  Concough
//
//  Created by Owner on 2017-01-11.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import UIKit
import RNCryptor
import SwiftyJSON
import RealmSwift
import Alamofire

class EntrancePackageDownloader: Manager.SessionDelegate {
    internal var viewController: UIViewController!
    private var entranceUniqueId: String!
    private var imagesList: [String: String]!
    private var questionsList: [String: [(id: String, dl: Bool)]]!
    private var vcType: String!
    private var username: String!
    private var indexPath: NSIndexPath?
    private var savingDirectory: String! = ""
    private var retry_counter = 0
    
    private var operationQueue: NSOperationQueue!
    private var fileManager: NSFileManager!
    
    internal private (set) var DownloadCount: Int = 0
    internal var backgroundCompletionHandler: (() -> Void)? {
        get {
            return self.backgroundManager.backgroundCompletionHandler
        }
        set {
            backgroundManager.backgroundCompletionHandler = newValue
        }
    }
    
    private lazy var backgroundManager: Alamofire.Manager = {
        let bundle = "Entrance:\(self.entranceUniqueId)"

        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundle)
        var manager = Alamofire.Manager(configuration: config)
        return manager
    }()
    
    
    internal func initialize(entranceUniqueId uniqueId: String, viewController: UIViewController, vcType: String, username: String, indexPath: NSIndexPath? = nil) {
        self.entranceUniqueId = uniqueId
        self.viewController = viewController
        self.vcType = vcType
        self.username = username
        self.indexPath = indexPath
    }
    
    internal func registerVC(viewController viewController: UIViewController, vcType: String, indexPath: NSIndexPath? = nil) {
        self.viewController = viewController
        self.vcType = vcType
        self.indexPath = indexPath
    }
    
    internal func downloadPackageImages() {
        self.operationQueue.addOperationWithBlock {
            self.processNextMulti(saveDirectory: self.savingDirectory)
        }
    }
    
    internal func downloadPackageImages(saveDirectory saveDirectory: String) {
        self.fileManager = NSFileManager.defaultManager()
        self.operationQueue = NSOperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
        self.savingDirectory = saveDirectory
        
        self.downloadPackageImages()
    }
        
    internal func fillImagesArray(completion: (result: Bool) -> ()) {
        // query db for questions
        NSOperationQueue.mainQueue().addOperationWithBlock {
            let questions = EntranceQuestionModelHandler.getQuestionsNotDwonloaded(entranceId: self.entranceUniqueId)
            if questions.count > 0 {
                self.questionsList = [:]
                self.imagesList = [:]
                
                for q in questions {
                    if let imagesArray = JSON(data: q.images.dataUsingEncoding(NSUTF8StringEncoding)!).array {
                        for item in imagesArray {
                            let imageUniqueId = item["unique_key"].stringValue
                            
                            self.imagesList.updateValue(q.uniqueId, forKey: imageUniqueId)
                            if self.questionsList[q.uniqueId] == nil {
                                self.questionsList[q.uniqueId] = []
                            }
                            self.questionsList[q.uniqueId]!.append((id: imageUniqueId, dl: false))
                        }
                    }
                }
                self.DownloadCount = self.imagesList.count
                
                completion(result: true)
            }
            completion(result: false)
        }
    }
    
    private func processNext(saveDirectory saveDirectory: String) {
        if let item = self.imagesList.popFirst() {
            self.downloadOneImage(saveDirectory: saveDirectory, imageId: item.0, questionId: item.1)
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if self.verifyDownload() == true {
                    // ok --> downloaded successfully
                    PurchasedModelHandler.setIsDownloadedTrue(productType: "Entrance", productId: self.entranceUniqueId, username: self.username)
                    DownloaderSingleton.sharedInstance.setDownloaderFinished(uniqueId: self.entranceUniqueId)
                    
                    if let entrance = EntranceModelHandler.getByUsernameAndId(id: self.entranceUniqueId, username: self.username) {
                        let title = "دانلود آزمون به اتمام رسید"
                        let message = "\(entrance.type) سال \(entrance.year)\n" + "\(entrance.set) (\(entrance.group))"
                        
                        LocalNotificationsSingleton.sharedInstance.createNotification(alertTitle: title, alertBody: message, fireDate: NSDate())
                        
                    }
                    
                    if self.vcType == "ED" {
                        let vc = self.viewController as! EntranceDetailTableViewController
                        vc.downloadImagesFinished(result: true)
                    } else if self.vcType ==  "F" {
                        let vc = self.viewController as! FavoritesTableViewController
                        vc.downloadImagesFinished(result: true, indexPath: self.indexPath!)
                    }
                    
                } else {
                    // some not downloaded
                    if self.vcType == "ED" {
                        let vc = self.viewController as! EntranceDetailTableViewController
                        vc.downloadImagesFinished(result: false)
                    } else if self.vcType ==  "F" {
                        let vc = self.viewController as! FavoritesTableViewController
                        vc.downloadImagesFinished(result: false, indexPath: self.indexPath!)
                    }
                    
                }
            }
        }
    }

    private func processNextMulti(saveDirectory saveDirectory: String) {
        var ids: [String: String] = [:]
        for _ in 1...DOWNLOAD_IMAGE_COUNT {
            if let item = self.imagesList.popFirst() {
                ids.updateValue(item.1, forKey: item.0)
            } else {
                break
            }
        }
        
        if ids.count > 0 {
            self.downloadMultiImage(saveDirectory: saveDirectory, ids: ids)
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if self.verifyDownload() == true {
                    // ok --> downloaded successfully
                    PurchasedModelHandler.setIsDownloadedTrue(productType: "Entrance", productId: self.entranceUniqueId, username: self.username)
                    DownloaderSingleton.sharedInstance.setDownloaderFinished(uniqueId: self.entranceUniqueId)
                    
                    if let entrance = EntranceModelHandler.getByUsernameAndId(id: self.entranceUniqueId, username: self.username) {
                        let title = "دانلود آزمون به اتمام رسید"
                        let message = "\(entrance.type) سال \(entrance.year)\n" + "\(entrance.set) (\(entrance.group))"
                        
                        LocalNotificationsSingleton.sharedInstance.createNotification(alertTitle: title, alertBody: message, fireDate: NSDate())
                        
                    }
                    
                    if self.vcType == "ED" {
                        let vc = self.viewController as! EntranceDetailTableViewController
                        vc.downloadImagesFinished(result: true)
                    } else if self.vcType ==  "F" {
                        let vc = self.viewController as! FavoritesTableViewController
                        vc.downloadImagesFinished(result: true, indexPath: self.indexPath!)
                    }
                    
                } else {
                    // some not downloaded
                    if self.vcType == "ED" {
                        let vc = self.viewController as! EntranceDetailTableViewController
                        vc.downloadImagesFinished(result: false)
                    } else if self.vcType ==  "F" {
                        let vc = self.viewController as! FavoritesTableViewController
                        vc.downloadImagesFinished(result: false, indexPath: self.indexPath!)
                    }
                    
                }
            }
        }
    }
    
    
    internal func downloadOneImage(saveDirectory saveDirectory: String, imageId: String, questionId: String) {
        MediaRestAPIClass.downloadEntranceQuestionImage(manager: self.backgroundManager, uniqueId: self.entranceUniqueId, imageId: imageId, completion: { (fullUrl, data, error) in
            if error != .Success {
                if error == HTTPErrorType.Refresh {
                    self.downloadOneImage(saveDirectory: saveDirectory, imageId: imageId, questionId: questionId)
                }
//                print("error in downloaing image from \(fullUrl!)")
                
            } else {
                if let myData = data {
                    let filePath = (saveDirectory as NSString).stringByAppendingPathComponent(imageId)
                    
                    if !self.fileManager.fileExistsAtPath(filePath) {
                        self.fileManager.createFileAtPath(filePath, contents: myData, attributes: nil)
                    }
                    
                    var index: Int? = nil
                    for item in self.questionsList[questionId]! {
                        // find it
                        index = self.questionsList[questionId]!.indexOf({ (t) -> Bool in
                            if t.id == item.id {
                                return true
                            }
                            return false
                        })
                        
                        // set to true
                        if index != nil {
                            
                            let item = self.questionsList[questionId]![index!]
                            let newItem = (id: item.id, dl: true)
                            self.questionsList[questionId]![index!] = newItem
                        }
                    }
                    
                    var downloadComplete = true
                    for item in self.questionsList[questionId]! {
                        if item.dl == false {
                            downloadComplete = false
                        }
                    }
                    
                    if downloadComplete == true {
                        // Save in db
                        EntranceQuestionModelHandler.changeDownloadedToTrue(uniqueId: questionId, entranceId: self.entranceUniqueId)
                    }
                    
                    if self.vcType == "ED" {
                        let vc = self.viewController as! EntranceDetailTableViewController
                        vc.downloadProgress(value: self.imagesList.count)
                    } else if self.vcType == "F" {
                        let vc = self.viewController as! FavoritesTableViewController
                        vc.downloadProgress(value: self.imagesList.count, totalCount: self.DownloadCount, indexPath: self.indexPath!)
                    }
                    
                }
            }
            self.operationQueue.addOperationWithBlock {
                self.processNext(saveDirectory: saveDirectory)
            }
            
//            self.processNext(saveDirectory: saveDirectory)
        }) { (error) in
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    fallthrough
                case .HostUnreachable:
                    AlertClass.showTopMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    
//                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                        self.downloadOneImage(saveDirectory: saveDirectory, imageId: imageId, questionId: questionId)
//                    })
                default:
                    AlertClass.showTopMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
//                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                        if self.vcType == "ED" {
//                            let vc = self.viewController as! EntranceDetailTableViewController
//                            vc.downloadProgress(value: -1)
//                        } else if self.vcType == "F" {
//                            let vc = self.viewController as! FavoritesTableViewController
//                            vc.downloadProgress(value: -1, totalCount: self.DownloadCount, indexPath: self.indexPath!)
//                        }
//                    
//                    })
                }
                if self.vcType == "ED" {
                    let vc = self.viewController as! EntranceDetailTableViewController
                    vc.downloadPaused()
                } else if self.vcType == "F" {
                    let vc = self.viewController as! FavoritesTableViewController
                    vc.downloadPaused(indexPath: self.indexPath!)
                }
                
            }
        }
    }

    internal func downloadMultiImage(saveDirectory saveDirectory: String, ids: [String: String]) {
        MediaRestAPIClass.downloadEntranceQuestionBulkImages(manager: self.backgroundManager, uniqueId: self.entranceUniqueId, questionsId: Array(ids.keys), completion: { (fullUrl, data, error) in
            if error != .Success {
                if error == HTTPErrorType.Refresh {
                    self.downloadMultiImage(saveDirectory: saveDirectory, ids: ids)
                } else {
                    if self.retry_counter < CONNECTION_MAX_RETRY {
                        self.retry_counter += 1
                        self.downloadMultiImage(saveDirectory: saveDirectory, ids: ids)
                    } else {
                        if self.vcType == "ED" {
                            let vc = self.viewController as! EntranceDetailTableViewController
                            vc.downloadPaused()
                        } else if self.vcType == "F" {
                            let vc = self.viewController as! FavoritesTableViewController
                            vc.downloadPaused(indexPath: self.indexPath!)
                        }
                    }
                }
                
            } else {
                self.retry_counter = 0
                if let myData = data {
                    let qs_string = String(data: myData, encoding: NSUTF8StringEncoding)
                    let qs = qs_string?.componentsSeparatedByString("$$$$$$$#$$$$$$$$")
                    for q in qs! {
                        let parts = q.componentsSeparatedByString("@@@@@@@#@@@@@@@@")
                        
                        if ids.keys.contains(parts[0]) {
                            let questionId = ids[parts[0]]!
                            let filePath = (saveDirectory as NSString).stringByAppendingPathComponent(parts[0])
                            
                            if !self.fileManager.fileExistsAtPath(filePath) {
                                self.fileManager.createFileAtPath(filePath, contents: parts[1].dataUsingEncoding(NSUTF8StringEncoding), attributes: nil)
                            }
                            
                            var index: Int? = nil
                            for item in self.questionsList[questionId]! {
                                // find it
                                index = self.questionsList[questionId]!.indexOf({ (t) -> Bool in
                                    if t.id == item.id {
                                        return true
                                    }
                                    return false
                                })
                                
                                // set to true
                                if index != nil {
                                    
                                    let item = self.questionsList[questionId]![index!]
                                    let newItem = (id: item.id, dl: true)
                                    self.questionsList[questionId]![index!] = newItem
                                }
                            }
                            
                            var downloadComplete = true
                            for item in self.questionsList[questionId]! {
                                if item.dl == false {
                                    downloadComplete = false
                                }
                            }
                            
                            if downloadComplete == true {
                                // Save in db
                                EntranceQuestionModelHandler.changeDownloadedToTrue(uniqueId: questionId, entranceId: self.entranceUniqueId)
                            }
                            
                        }
                    }
                    
                    

                    
                    if self.vcType == "ED" {
                        let vc = self.viewController as! EntranceDetailTableViewController
                        vc.downloadProgress(value: self.imagesList.count)
                    } else if self.vcType == "F" {
                        let vc = self.viewController as! FavoritesTableViewController
                        vc.downloadProgress(value: self.imagesList.count, totalCount: self.DownloadCount, indexPath: self.indexPath!)
                    }
                    
                }
            }
            self.operationQueue.addOperationWithBlock {
                self.processNextMulti(saveDirectory: saveDirectory)
            }
            
            //            self.processNext(saveDirectory: saveDirectory)
        }) { (error) in
            if let err = error {
                if self.retry_counter < CONNECTION_MAX_RETRY {
                    self.retry_counter += 1
                    self.downloadMultiImage(saveDirectory: saveDirectory, ids: ids)
                } else {
                    switch err {
                    case .NoInternetAccess:
                        fallthrough
                    case .HostUnreachable:
                        AlertClass.showTopMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                        
                        //                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        //                        self.downloadOneImage(saveDirectory: saveDirectory, imageId: imageId, questionId: questionId)
                    //                    })
                    default:
                        AlertClass.showTopMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                        //                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        //                        if self.vcType == "ED" {
                        //                            let vc = self.viewController as! EntranceDetailTableViewController
                        //                            vc.downloadProgress(value: -1)
                        //                        } else if self.vcType == "F" {
                        //                            let vc = self.viewController as! FavoritesTableViewController
                        //                            vc.downloadProgress(value: -1, totalCount: self.DownloadCount, indexPath: self.indexPath!)
                        //                        }
                        //
                        //                    })
                    }
                    if self.vcType == "ED" {
                        let vc = self.viewController as! EntranceDetailTableViewController
                        vc.downloadPaused()
                    } else if self.vcType == "F" {
                        let vc = self.viewController as! FavoritesTableViewController
                        vc.downloadPaused(indexPath: self.indexPath!)
                    }
                }
            }
        }
    }
    
    
    internal func verifyDownload() -> Bool {
        let questions = EntranceQuestionModelHandler.getQuestionsNotDwonloaded(entranceId: self.entranceUniqueId)
        if questions.count == 0 {
            return true
        }
        return false
    }
    
    internal func downloadInitialData(queue: NSOperationQueue, completion: (result: Bool, indexPath: NSIndexPath?) -> ()) {
        EntranceRestAPIClass.getEntrancePackageDataInit(uniqueId: self.entranceUniqueId, completion: { (data, error) in
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.downloadInitialData(queue, completion: completion)
                } else {
                    if self.retry_counter < CONNECTION_MAX_RETRY {
                       self.retry_counter += 1
                       self.downloadInitialData(queue, completion: completion)
                    } else {
                        AlertClass.showTopMessage(viewController: self.viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                    }
                }
            } else {
                self.retry_counter = 0
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            let packageStr = localData["package"].stringValue
                            let decodedData = NSData(base64EncodedString: packageStr, options: NSDataBase64DecodingOptions.init(rawValue: 0))
                            
                            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                            do {
                                let hash_str = username + ":" + SECRET_KEY
                                let hash_key = MD5Digester.digest(hash_str)
                                
                            
                                let originalText = try RNCryptor.decryptData(decodedData!, password: hash_key)
                                
                                let content = JSON(data: originalText)
                                let initData = content["init"]
                                
                                let (valid, imagesList, questionsList) = EntrancePackageHandler.savePackage(username: username, entranceUniqueId: self.entranceUniqueId, initData: initData)
                                if valid == true {
                                    self.imagesList = imagesList
                                    self.questionsList = questionsList
                                    self.DownloadCount = self.imagesList.count
                                    
                                    completion(result: true, indexPath: self.indexPath)
                                } else {
                                    EntrancePackageHandler.removePackage(username: username, entranceUniqueId: self.entranceUniqueId)
                                }
                                
                            } catch(let error as NSError) {
//                                print("\(error)")
                            }
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "PackageNotExist":
                                    break
                                case "EntranceNotExist":
                                    // No Entrance data exist --> pop this
                                    AlertClass.showTopMessage(viewController: self.viewController, messageType: "EntranceResult", messageSubType: "EntranceNotExist", type: "error", completion: nil)

                                    if self.vcType == "ED" {
                                        NSOperationQueue.mainQueue().addOperationWithBlock({
                                            self.viewController.dismissViewControllerAnimated(true, completion: nil)
                                        })
                                    }
//                                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "EntranceResult", messageSubType: "EntranceNotExist", completion: {
//                                        
//                                        NSOperationQueue.mainQueue().addOperationWithBlock({
//                                            self.viewController.dismissViewControllerAnimated(true, completion: nil)
//                                        })
//                                    })
                                default:
                                    break
//                                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                            
                        default:
                            break
                        }
                    }
                }
            }
        }) { (error) in
            if let err = error {
                if self.retry_counter < CONNECTION_MAX_RETRY {
                    self.retry_counter += 1
                    self.downloadInitialData(queue, completion: completion)
                } else {

                    switch err {
                    case .HostUnreachable:
                        fallthrough
                    case .NoInternetAccess:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                        })
                        
    //                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
    //                        let operation = NSBlockOperation(block: {
    //                            self.downloadInitialData(queue, completion: completion)
    //                        })
    //                        queue.addOperation(operation)
    //                    })
                    default:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                        })
    //                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                    }

                    if self.vcType == "ED" {
                        let vc = self.viewController as! EntranceDetailTableViewController
                        vc.downloadPaused()
                    } else if self.vcType == "F" {
                        let vc = self.viewController as! FavoritesTableViewController
                        vc.downloadPaused(indexPath: self.indexPath!)
                    }
                }
            }
        }
        
        completion(result: false, indexPath: nil)
    }
}
