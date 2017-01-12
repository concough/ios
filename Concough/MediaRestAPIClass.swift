//
//  MediaRestAPIClass.swift
//  Concough
//
//  Created by Owner on 2016-11-24.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import Alamofire

class MediaRestAPIClass {
    
    class func makeEsetImageUri(imageId: Int) -> String? {
        guard let fullPath = UrlMakerSingleton.sharedInstance.mediaUrlFor("eset", mediaId: imageId) else {
            return nil
        }
        return fullPath
    }
    
    
    class func downloadEsetImage(localName name: String, indexPath: NSIndexPath, imageId: Int, completion: (fullUrl: String?, data: NSData?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        if let fullPath = MediaRestAPIClass.makeEsetImageUri(imageId) {
            
            
            
            // get additional headers from oauth
            TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
                if authenticated && error == .Success {
                    let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                    
                    let request = Alamofire.request(.GET ,fullPath, parameters: nil, encoding: .URL, headers: headers).responseData() { response in
                        //print("download index:\(imageId)")
                        
                        switch response.result {
                        case .Success:
                            let statusCode = response.response?.statusCode
                            let errorType = HTTPErrorType.toType(statusCode!)

                            
                            switch errorType {
                            case .Success:
                                guard let data = response.result.value else {
                                    return
                                }
                                // call callback function
                                completion(fullUrl: fullPath, data: data, error: .Success)
                            case .ForbidenAccess:
                                TokenHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, err) in
                                    if authenticated && error == .Success {
                                        completion(fullUrl: fullPath, data: nil, error: err)
                                    }
                                }, failure: { (error) in
                                    failure(error: error)
                                })
                                break
                            default:
                                // failure occured --> in future must be replace with error detector
                                completion(fullUrl: fullPath, data: nil, error: errorType)
                            }
                        case .Failure(let error):
                            failure(error: NetworkErrorType.toType(error))
                        }
                    }
                    
                    // cache Request for future use
                    let key = "\(name):\(indexPath.section):\(indexPath.row):\(fullPath)"
                    MediaRequestRepositorySingleton.sharedInstance.add(key: key, value: request)
                    
                } else {
                    completion(fullUrl: fullPath, data: nil, error: error)
                }
            }, failure: { (error) in
                failure(error: error)
            })
        } else {
            // can not make url --> must return an error
        }
    }
    
    
}
