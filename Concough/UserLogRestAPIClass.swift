//
//  UserLogRestAPIClass.swift
//  Concough
//
//  Created by Owner on 2018-05-24.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UserLogRestAPIClass {
    class func syncUpWithManager(manager manager: Alamofire.Manager, data: [AnyObject], completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.getUserLogSyncUpUrl() else {
            return
        }
        
        // get additional headers from oauth
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                var uuid: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
                if let temp = KeyChainAccessProxy.getValue(IDENTIFIER_FOR_VENDOR_KEY) as? String {
                    uuid = temp
                }
                
                // make parameters
                let parameters: [String : AnyObject] = ["device_name": "ios",
                    "device_unique_id": uuid,
                    "data": data
                ]
                
                manager.request(.POST, fullPath, parameters: parameters as [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                    
                    switch response.result {
                    case .Success:
                        //debugPrint(response)
                        let statusCode = response.response?.statusCode
                        let errorType = HTTPErrorType.toType(statusCode!)
                        
                        switch errorType {
                        case .Success:
                            if let json = response.result.value {
                                let jsonData = JSON(json)
                                
                                
                                completion(data: jsonData, error: .Success)
                            }
                        case .UnAuthorized:
                            fallthrough
                        case .ForbidenAccess:
                            TokenHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, err) in
                                if authenticated && error == .Success {
                                    completion(data: nil, error: HTTPErrorType.Refresh)
                                }
                                }, failure: { (error) in
                                    failure(error: error)
                            })
                        default:
                            completion(data: nil, error: errorType)
                        }
                    case .Failure(let error):
                        failure(error: NetworkErrorType.toType(error))
                    }
                }
            } else {
                completion(data: nil, error: error)
            }
            
            }, failure: { (error) in
                failure(error: error)
        })
    }
    
}
