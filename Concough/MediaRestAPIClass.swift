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
    
    
    class func downloadEsetImage(imageId: Int, completion: (fullUrl: String?, data: NSData?, error: NSError?) -> ()) {
        if let fullPath = MediaRestAPIClass.makeEsetImageUri(imageId) {
            Alamofire.request(.GET ,fullPath).responseData() { response in
                print("download index:\(imageId)")
                
                switch response.result {
                case .Success:
                    guard let data = response.result.value else {
                        return
                    }
                    // call callback function
                    completion(fullUrl: fullPath, data: data, error: nil)
                    
                case .Failure(let err):
                    // failure occured --> in future must be replace with error detector
                    completion(fullUrl: fullPath, data: nil, error: err)
                }
            }
        } else {
            // can not make url --> must return an error
        }
    }
}
