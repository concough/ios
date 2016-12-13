//
//  AccessTokenAdapter.swift
//  Concough
//
//  Created by Owner on 2016-11-26.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AccessTokenAdapter {
    
    // Authorization Class Method
    class func authorize(username username: String, password: String, completion: (data: JSON?, statusCode: Int, error: NSError?) -> ()) {
        if let path = UrlMakerSingleton.sharedInstance.tokenUrl() {
        
            let parameters: [String: String] = ["grant_type": "password",
                                                "username": username,
                                                "password": password]
            
            let clientData: NSData = "\(CLIENT_ID):\(CLIENT_PASSWORD)".dataUsingEncoding(NSUTF8StringEncoding)!
            let client64String = clientData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0))

            let headers: [String: String] = ["Content-Type": "application/x-www-form-urlencoded",
                                             "Accept": "application/json",
                                             "Authorization": "Basic \(client64String)"]

            Alamofire.request(.POST, path, parameters: parameters, encoding: .URL, headers: headers).responseJSON {
                response in
                
                print(response)
                
                switch (response.result) {
                case .Success:
                    let statusCode = response.response?.statusCode
                    let data = JSON(data: response.data!)
                    completion(data: data, statusCode: statusCode!, error: nil)
                    
                    
                case .Failure(let error):
                    // cannot access serever
                    completion(data: nil, statusCode: 0, error: error)
                }
            }

        } else {
            // Cannot make path uri
            
        }
    }
    
    // Refresh Token Class Method
    class func refreshToken(refToken token: String, completion: (data: JSON?, statusCode: Int, error: NSError?) -> ()) {
        if let path = UrlMakerSingleton.sharedInstance.tokenUrl() {

            let parameters: [String: String] = ["grant_type": "refresh_token",
                                                "refresh_token": token]
            
            let clientData: NSData = "\(CLIENT_ID):\(CLIENT_PASSWORD)".dataUsingEncoding(NSUTF8StringEncoding)!
            let client64String = clientData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0))
            
            let headers: [String: String] = ["Content-Type": "application/x-www-form-urlencoded",
                                             "Accept": "application/json",
                                             "Authorization": "Basic \(client64String)"]
            
            Alamofire.request(.POST, path, parameters: parameters, encoding: .URL, headers: headers).responseJSON {
                response in
                
                switch (response.result) {
                case .Success:
                    let statusCode = response.response?.statusCode
                    let data = JSON(data: response.data!)
                    completion(data: data, statusCode: statusCode!, error: nil)
                    
                case .Failure(let error):
                    // cannot access serever
                    completion(data: nil, statusCode: 0, error: error)
                }
            }
            
        } else {
        // Cannot make path uri
        }
    }
}

