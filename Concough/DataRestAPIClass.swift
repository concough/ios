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
    class func updateActivity(next next: String?, completion: (refresh: Bool, data: JSON?, error: NSError?) -> ()) {
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
        
        Alamofire.request(.GET, fullPath).validate().responseJSON { response in
            
            //debugPrint(response)
            switch response.result {
            case .Success:
                if let json = response.result.value {
                    let jsonData = JSON(json)
                    
                    completion(refresh: !hasNext, data: jsonData, error: nil)
                }
                
            case .Failure(let error):
                completion(refresh: !hasNext, data: nil, error: error)
            }
        }
    }
}
