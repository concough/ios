//
//  EntranceRestAPIClass.swift
//  Concough
//
//  Created by Owner on 2017-01-02.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class EntranceRestAPIClass {
    class func getEntranceWithBuyInfo(uniqueId uniqueId: String, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.getEnranceUrl(uniqueId: uniqueId) else {
            return
        }
        
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
    
    class func getEntrancePackageDataInit(uniqueId uniqueId: String, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.getEntrancePackageDataInitUrl(uniqueId: uniqueId) else {
            return
        }
        
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
                
            }
        }, failure: { (error) in
                failure(error: error)
        })
    }

    class func getEntrancePackageImage(uniqueId uniqueId: String, packageId: String, completion: (fullUrl: String?, data: NSData?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.getEntrancePackageImageUrl(uniqueId: uniqueId, packageId: packageId) else {
            return
        }
        
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                Alamofire.request(.GET, fullPath, parameters: nil, encoding: .URL, headers: headers).responseData { response in
                    
                    switch response.result {
                    case .Success:
                        //debugPrint(response)
                        let statusCode = response.response?.statusCode
                        let errorType = HTTPErrorType.toType(statusCode!)
                        
                        switch errorType {
                        case .Success:
                            guard let data = response.result.value else {
                                return
                            }
                            // call callback function
                            completion(fullUrl: fullPath, data: data, error: .Success)
                        case .UnAuthorized:
                            fallthrough
                        case .ForbidenAccess:
                            TokenHandlerSingleton.sharedInstance.assureAuthorized(true, completion: { (authenticated, err) in
                                if authenticated && error == .Success {
                                    completion(fullUrl: fullPath, data: nil, error: HTTPErrorType.Refresh)
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
                
            }
        }, failure: { (error) in
                failure(error: error)
        })
    }
}
