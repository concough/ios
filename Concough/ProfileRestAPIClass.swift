//
//  ProfileRestAPIClass.swift
//  Concough
//
//  Created by Owner on 2016-12-11.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ProfileRestAPIClass {
    class func getProfileData(completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.profileUrl() else {
            return
        }
        
        // get additional headers from oauth
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                Alamofire.request(.GET, fullPath, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
                    
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
                            TokenHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, error) in
                                if authenticated && error == .Success {
                                    completion(data: nil, error: error)
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

    class func postProfileData(info info: SignupMoreInfoStruct, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.profileUrl() else {
            return
        }
        
        // get additional headers from oauth
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                // make parameters
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components([.Day, .Month, .Year], fromDate: info.birthday!)
                
                let parameters = ["firstname": info.firstname!,
                                    "lastname": info.lastname!,
                                    "grade": info.grade!,
                                    "gender": info.gender!,
                                    "byear": components.year,
                                    "bmonth": components.month,
                                    "bday": components.day
                                ]
            
                Alamofire.request(.POST, fullPath, parameters: parameters as? [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                    
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
                                    completion(data: nil, error: err)
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
    
    class func putProfileGrade(grade grade: String, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.editGradeProfileUrl() else {
            return
        }
        
        // get additional headers from oauth
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                // make parameters
                let parameters: [String: AnyObject] = [
                    "grade": grade,
                ]
                
                Alamofire.request(.PUT, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
                    
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
                                    completion(data: nil, error: err)
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
