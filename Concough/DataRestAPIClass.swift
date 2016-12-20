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
    class func updateActivity(next next: String?, completion: (refresh: Bool, data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
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
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                Alamofire.request(.GET, fullPath, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
                    
                    //debugPrint(response)
                    switch response.result {
                    case .Success:
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
                            TokenHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, err) in
                                if authenticated && err == .Success {
                                    completion(refresh: false, data: nil, error: err)
                                }
                            }, failure: { (error) in
                                failure(error: error)
                            })
                        default:
                            completion(refresh: false, data: nil, error: errorType)
                        }
                    case .Failure(let error):
                        failure(error: NetworkErrorType.toType(error))
                    }
                }
            } else {
                completion(refresh: false, data: nil, error: error)
            }
        }, failure: { (error) in
            failure(error: error)
        })
    }
}
