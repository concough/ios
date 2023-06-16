//
//  ArchiveRestAPIClass.swift
//  Concough
//
//  Created by Owner on 2016-12-21.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class ArchiveRestAPIClass {
    class func getEntranceTypes(completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
    
        guard let fullPath = UrlMakerSingleton.sharedInstance.archiveEntranceTypesUrl() else {
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

    class func getEntranceGroups(entranceTypeId etypeId: Int, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.archiveEntranceGroupsUrl(etypeId: etypeId) else {
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
    
    class func getEntranceSets(entranceGroupId egroupId: Int, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.archiveEntranceSetsUrl(egroupId: egroupId) else {
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

    class func getEntrances(entranceSetId esetId: Int, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.archiveEntrancesUrl(esetId: esetId) else {
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
    
}
