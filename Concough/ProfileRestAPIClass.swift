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
    class func getProfileData(completion: (data: JSON?, error: HTTPErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.profileUrl() else {
            return
        }
        
        // get additional headers from oauth
        OAuthHandlerSingleton.sharedInstance.assureAuthorized { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = OAuthHandlerSingleton.sharedInstance.getHeader()
                
                Alamofire.request(.GET, fullPath, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
                    
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
                        OAuthHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, error) in
                            if authenticated && error == .Success {
                                completion(data: nil, error: error)
                            }
                        })
                    default:
                        completion(data: nil, error: errorType)
                    }
                }
            } else {
                completion(data: nil, error: error)
            }
        }
        
    }

    class func postProfileData(info info: SignupMoreInfoStruct, completion: (data: JSON?, error: HTTPErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.profileUrl() else {
            return
        }
        
        // get additional headers from oauth
        OAuthHandlerSingleton.sharedInstance.assureAuthorized { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = OAuthHandlerSingleton.sharedInstance.getHeader()
                
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
                        OAuthHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, err) in
                            if authenticated && error == .Success {
                                completion(data: nil, error: err)
                            }
                        })
                    default:
                        completion(data: nil, error: errorType)
                    }
                }
            } else {
                completion(data: nil, error: error)
            }
        }
        
    }

}
