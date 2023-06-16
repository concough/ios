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
    class func checkUsername(username username: String, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.checkUsername() else {
            return
        }

        let parameteres: [String: String] = ["username": username]
        let headers: [String: String] = ["Content-Type": "application/json",
                                             "Accept": "application/json"]
            
        Alamofire.request(.POST, fullPath, parameters: parameteres, encoding: .JSON, headers: headers).responseJSON { response in
            
            //debugPrint(response)
            switch response.result {
            case .Success:
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
            case .Failure(let error):
                failure(error: NetworkErrorType.toType(error))
            }
        }
        
    }
    
    class func preSignup(username username: String, send_type: String, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.preSignupUrl() else {
            return
        }
        
        let parameters: [String: String] = ["username": username,
                                            "type": send_type]
        let headers: [String: String] = ["Content-Type": "application/json",
                                         "Accept": "application/json"]
        
        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            
            switch response.result {
            case .Success:
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
            case .Failure(let error):
                failure(error: NetworkErrorType.toType(error))
            }
        }
    }
//    class func preSignup(username username: String, email: String, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
//        
//        guard let fullPath = UrlMakerSingleton.sharedInstance.preSignupUrl() else {
//            return
//        }
//        
//        let parameters: [String: String] = ["username": username,
//                                            "email": email]
//        let headers: [String: String] = ["Content-Type": "application/json",
//                                         "Accept": "application/json"]
//        
//        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
//            
//            switch response.result {
//            case .Success:
//                let statusCode = response.response?.statusCode
//                let errorType = HTTPErrorType.toType(statusCode!)
//                
//                switch errorType {
//                case .Success:
//                    if let json = response.result.value {
//                        let jsonData = JSON(json)
//                        
//                        completion(data: jsonData, error: .Success)
//                    }
//                default:
//                    completion(data: nil, error: errorType)
//                }
//            case .Failure(let error):
//                failure(error: NetworkErrorType.toType(error))
//            }
//        }
//    }
    
    class func signup(username username: String, id: Int, code: Int, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.signupUrl() else {
            return
        }
        
        let parameters: [String: AnyObject] = ["username": username,
                                            "id": id,
                                            "code": code]
        let headers: [String: String] = ["Content-Type": "application/json",
                                         "Accept": "application/json"]
        
        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in

            switch response.result {
            case .Success:
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
            case .Failure(let error):
                failure(error: NetworkErrorType.toType(error))
            }
        }
    }
    
    class func forgotPassword(username username: String, send_type: String, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.forgotPassword() else {
            return
        }
        
        let parameters: [String: String] = ["username": username,
                                            "type": send_type]
        let headers: [String: String] = ["Content-Type": "application/json",
                                         "Accept": "application/json"]
        
        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in

            switch response.result {
            case .Success:
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
            case .Failure(let error):
                failure(error: NetworkErrorType.toType(error))
            }
        }
    }

    class func resetPassword(username username: String, id: Int, password: String, rpassword: String, code: Int, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
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
            
            switch response.result {
            case .Success:
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
            case .Failure(let error):
                failure(error: NetworkErrorType.toType(error))
            }
        }
    }
    
    class func changePassword(oldPassword pass1: String, newPassword pass2: String, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.changePassword() else {
            return
        }
        
        // get additional headers from oauth
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                let parameters: [String: AnyObject] = ["oldPass": pass1,
                                                    "newPass": pass2
                ]
                
                Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
                    
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
