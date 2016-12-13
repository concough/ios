//
//  AuthRestAPIClass.swift
//  Concough
//
//  Created by Owner on 2016-12-04.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AuthRestAPIClass {
    class func checkUsername(username username: String, completion: (data: JSON?, error: HTTPErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.checkUsername() else {
            return
        }

        let parameteres: [String: String] = ["username": username]
        let headers: [String: String] = ["Content-Type": "application/json",
                                             "Accept": "application/json"]
            
        Alamofire.request(.POST, fullPath, parameters: parameteres, encoding: .JSON, headers: headers).responseJSON { response in
            
            //debugPrint(response)
            let statusCode = response.response?.statusCode
            let errorType = HTTPErrorType.toType(statusCode!)
            
            switch errorType {
            case .Success:
                if let json = response.result.value {
                    let jsonData = JSON(json)
                    
                    completion(data: jsonData, error: .Success)
                }
            default:
                completion(data: nil, error: errorType)
            }
        }
        
    }
    
    class func preSignup(username username: String, email: String, completion: (data: JSON?, error: HTTPErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.preSignupUrl() else {
            return
        }
        
        let parameters: [String: String] = ["username": username,
                                            "email": email]
        let headers: [String: String] = ["Content-Type": "application/json",
                                         "Accept": "application/json"]
        
        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            
            let statusCode = response.response?.statusCode
            let errorType = HTTPErrorType.toType(statusCode!)
            
            switch errorType {
            case .Success:
                if let json = response.result.value {
                    let jsonData = JSON(json)
                    
                    completion(data: jsonData, error: .Success)
                }
            default:
                completion(data: nil, error: errorType)
            }
            
        }
    }
    
    class func signup(username username: String, id: Int, code: Int, email: String, password: String, completion: (data: JSON?, error: HTTPErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.signupUrl() else {
            return
        }
        
        let parameters: [String: AnyObject] = ["username": username,
                                               "email": email,
                                               "password": password,
                                            "id": id,
                                            "code": code]
        let headers: [String: String] = ["Content-Type": "application/json",
                                         "Accept": "application/json"]
        
        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            
            let statusCode = response.response?.statusCode
            let errorType = HTTPErrorType.toType(statusCode!)
            
            switch errorType {
            case .Success:
                if let json = response.result.value {
                    let jsonData = JSON(json)
                    
                    completion(data: jsonData, error: .Success)
                }
            default:
                completion(data: nil, error: errorType)
            }
        }
    }
    
    class func forgotPassword(username username: String, completion: (data: JSON?, error: HTTPErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.forgotPassword() else {
            return
        }
        
        let parameters: [String: String] = ["username": username]
        let headers: [String: String] = ["Content-Type": "application/json",
                                         "Accept": "application/json"]
        
        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            
            let statusCode = response.response?.statusCode
            let errorType = HTTPErrorType.toType(statusCode!)
            
            switch errorType {
            case .Success:
                if let json = response.result.value {
                    let jsonData = JSON(json)
                    
                    completion(data: jsonData, error: .Success)
                }
            default:
                completion(data: nil, error: errorType)
            }
        }
    }

    class func resetPassword(username username: String, id: Int, password: String, rpassword: String, code: Int, completion: (data: JSON?, error: HTTPErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.resetPassword() else {
            return
        }
        
        let parameters: [String: AnyObject] = ["username": username,
                                            "password": password,
                                            "rpassword": rpassword,
                                            "id": id,
                                            "code": code]
        let headers: [String: String] = ["Content-Type": "application/json",
                                         "Accept": "application/json"]
        
        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            
            let statusCode = response.response?.statusCode
            let errorType = HTTPErrorType.toType(statusCode!)
            
            switch errorType {
            case .Success:
                if let json = response.result.value {
                    let jsonData = JSON(json)
                    
                    completion(data: jsonData, error: .Success)
                }
            default:
                completion(data: nil, error: errorType)
            }
            
        }
    }
    
}
