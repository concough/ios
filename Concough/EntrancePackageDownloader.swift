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

class EntrancePackageDownloader {
    class func downloadInitialData(viewController viewController: UIViewController, uniqueId: String, queue: NSOperationQueue, completion: (result: Bool) -> ()) {
        EntranceRestAPIClass.getEntrancePackageDataInit(uniqueId: uniqueId, completion: { (data, error) in
            if error != HTTPErrorType.Success {
                AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            let package = localData["package"].stringValue.base64Decoded() as NSData
                            let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                            do {
                                let originalText = try RNCryptor.decryptData(package, password: username)
                                
                                // update EntrancePurchase Realm Record --> set isDownloaded = true
                                let username = UserDefaultsSingleton.sharedInstance.getUsername()!
                                let valid = PurchasedModelHandler.setIsDownloadedTrue(productType: "Entrance", productId: uniqueId, username: username)
                                
                                if valid == true {
                                    let content = JSON(data: originalText)
                                    let initData = content["init"]
                                    
                                    if EntrancePackageHandler.savePackage(username: username, entranceUniqueId: uniqueId, initData: initData) == true {
                                        
                                        completion(result: true)
                                    } else {
                                        EntrancePackageHandler.removePackage(username: username, entranceUniqueId: uniqueId)
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
                                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "EntranceResult", messageSubType: "EntranceNotExist", completion: {
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({
                                            viewController.dismissViewControllerAnimated(true, completion: nil)
                                        })
                                    })
                                default:
                                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
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
                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        let operation = NSBlockOperation(block: {
                            EntrancePackageDownloader.downloadInitialData(viewController: viewController, uniqueId: uniqueId, queue: queue, completion:  completion)
                        })
                        queue.addOperation(operation)
                    })
                default:
                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                }
            }
        }
        
        completion(result: false)
    }
    
    class func downloadEntranceImages
    
}
