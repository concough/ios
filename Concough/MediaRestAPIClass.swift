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
    
    
    class func downloadEsetImage(imageId: Int, completion: (fullUrl: String?, data: NSData?, error: HTTPErrorType?) -> ()) {
        if let fullPath = MediaRestAPIClass.makeEsetImageUri(imageId) {
            
            
            
            // get additional headers from oauth
            OAuthHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
                if authenticated && error == nil {
                    let headers = OAuthHandlerSingleton.sharedInstance.getHeader()
                    
                    Alamofire.request(.GET ,fullPath, parameters: nil, encoding: .URL, headers: headers).responseData() { response in
                        //print("download index:\(imageId)")
                        let statusCode = response.response?.statusCode
                        let errorType = HTTPErrorType.toType(statusCode!)

                        
                        switch errorType {
                        case .Success:
                            guard let data = response.result.value else {
                                return
                            }
                            // call callback function
                            completion(fullUrl: fullPath, data: data, error: nil)
                        case .ForbidenAccess:
                            OAuthHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, error) in
                                if authenticated && error == nil {
                                    completion(fullUrl: fullPath, data: nil, error: error)
                                }
                            })
                            break
                        default:
                            // failure occured --> in future must be replace with error detector
                            completion(fullUrl: fullPath, data: nil, error: errorType)
                        }
                    }
                } else {
                    completion(fullUrl: fullPath, data: nil, error: error)
                }
            })
        } else {
            // can not make url --> must return an error
        }
    }
}
