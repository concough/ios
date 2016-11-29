//
//  DataRestAPIClass.swift
//  Concough
//
//  Created by Owner on 2016-11-24.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DataRestAPIClass {
    class func updateActivity(next next: String?, completion: (refresh: Bool, data: JSON?, error: HTTPErrorType?) -> ()) {
        guard var fullPath = UrlMakerSingleton.sharedInstance.activityUrl() else {
            return
        }
        
        var hasNext = false
        if let nextStr = next where nextStr != "" {
            if let path = UrlMakerSingleton.sharedInstance.activityUrlWithNext(nextStr) {
                fullPath = path
                hasNext = true
                
            } else {
                return
            }
        }
        
        // get additional headers from oauth
        OAuthHandlerSingleton.sharedInstance.assureAuthorized { (authenticated, error) in
            if authenticated && error == nil {
                
                let headers = OAuthHandlerSingleton.sharedInstance.getHeader()
                
                Alamofire.request(.GET, fullPath, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
                    
                    //debugPrint(response)
                    let statusCode = response.response?.statusCode
                    let errorType = HTTPErrorType.toType(statusCode!)
                    
                    switch errorType {
                    case .Success:
                        if let json = response.result.value {
                            let jsonData = JSON(json)
                            
                            completion(refresh: !hasNext, data: jsonData, error: .Success)
                        }
                    case .UnAuthorized:
                        fallthrough
                    case .ForbidenAccess:
                        OAuthHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, error) in
                            if authenticated && error == nil {
                                completion(refresh: false, data: nil, error: errorType)
                            }
                        })
                    default:
                        completion(refresh: false, data: nil, error: errorType)
                    }
                }
            } else {
                completion(refresh: false, data: nil, error: error)
            }
        }
    }
}
