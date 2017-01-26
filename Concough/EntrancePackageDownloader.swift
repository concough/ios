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

class EntrancePackageDownloader {
    private var entranceUniqueId: String!
    private var imagesList: [String: String]!
    private var questionsList: [String: [(id: String, dl: Bool)]]!
    private var vcType: String!
    private var username: String!
    private var indexPath: NSIndexPath?
    internal var viewController: UIViewController!
    
    private var fileManager: NSFileManager!
    
    internal private (set) var DownloadCount: Int = 0
        
    
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
    
    internal func downloadPackageImages(saveDirectory saveDirectory: String) {
        self.fileManager = NSFileManager.defaultManager()
        self.processNext(saveDirectory: saveDirectory)
    }
        
    internal func fillImagesArray() -> Bool {
        // query db for questions
        let questions = EntranceQuestionModelHandler.getQuestions(entranceId: self.entranceUniqueId)
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
            return true
        }
        
        return false
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
                    
                    if self.vcType == "ED" {
                        let vc = self.viewController as! EntranceDetailTableViewController
                        vc.downloadImagesFinished(result: true)
                    } else if self.vcType ==  "F" {
                        let vc = self.viewController as! FavoritesTableViewController
                        vc.downloadImagesFinished(result: true, indexPath: self.indexPath!)
                    }
                    
                } else {
                    // some not downloaded
                }
            }
        }
    }
    
    internal func downloadOneImage(saveDirectory saveDirectory: String, imageId: String, questionId: String) {
        MediaRestAPIClass.downloadEntranceQuestionImage(uniqueId: self.entranceUniqueId, imageId: imageId, completion: { (fullUrl, data, error) in
            if error != .Success {
                // print the error for now
                print("error in downloaing image from \(fullUrl!)")
                
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
                        vc.downloadProgress(value: self.DownloadCount)
                    } else if self.vcType == "F" {
                        let vc = self.viewController as! FavoritesTableViewController
                        vc.downloadProgress(value: self.imagesList.count, totalCount: self.DownloadCount, indexPath: self.indexPath!)
                    }
                    
                }
            }
            
            self.processNext(saveDirectory: saveDirectory)
        }) { (error) in
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        self.downloadOneImage(saveDirectory: saveDirectory, imageId: imageId, questionId: questionId)
                    })
                default:
                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        if self.vcType == "ED" {
                            let vc = self.viewController as! EntranceDetailTableViewController
                            vc.downloadProgress(value: -1)
                        } else if self.vcType == "F" {
                            let vc = self.viewController as! FavoritesTableViewController
                            vc.downloadProgress(value: -1, totalCount: self.DownloadCount, indexPath: self.indexPath!)
                        }
                    
                    })
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
                AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            //print(localData["package"].stringValue)
                            let packageStr = localData["package"].stringValue
                            //print(packageStr)
                            
                            //let p = try! localData["package"].rawData()
                            
                            //packageStr = ""
                            let decodedData = NSData(base64EncodedString: packageStr, options: NSDataBase64DecodingOptions.init(rawValue: 0))
                            
                            //let package = packageStr.dataUsingEncoding(NSUTF8StringEncoding)
                            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                            do {
                                let originalText = try RNCryptor.decryptData(decodedData!, password: username)
                                print(originalText)
                                
                                // update EntrancePurchase Realm Record --> set isDownloaded = true
                                //let valid = PurchasedModelHandler.setIsDownloadedTrue(productType: "Entrance", productId: self.entranceUniqueId, username: username)
                                let valid = true
                                
                                if valid == true {
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
                                }
                                
                            } catch(let error as NSError) {
                                print("\(error)")
                            }
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "PackageNotExist":
                                    break
                                case "EntranceNotExist":
                                    // No Entrance data exist --> pop this
                                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "EntranceResult", messageSubType: "EntranceNotExist", completion: {
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({
                                            self.viewController.dismissViewControllerAnimated(true, completion: nil)
                                        })
                                    })
                                default:
                                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
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
                switch err {
                case .NoInternetAccess:
                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        let operation = NSBlockOperation(block: {
                            self.downloadInitialData(queue, completion: completion)
                        })
                        queue.addOperation(operation)
                    })
                default:
                    AlertClass.showSimpleErrorMessage(viewController: self.viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                }
            }
        }
        
        completion(result: false, indexPath: nil)
    }
}
