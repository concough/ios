//
//  DeviceRestAPIClass.swift
//  Concough
//
//  Created by Owner on 2017-09-28.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DeviceRestAPIClass {
    class func deviceCreate(completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.getDeviceCreateUrl() else {
            return
        }
        
        // get additional headers from oauth
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                var uuid: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
                if let temp = KeyChainAccessProxy.getValue(IDENTIFIER_FOR_VENDOR_KEY) as? String {
                    uuid = temp
                }
                KeyChainAccessProxy.setValue(IDENTIFIER_FOR_VENDOR_KEY, value: uuid)
                
                // make parameters
                let parameters: [String : AnyObject] = ["device_name": "ios",
                    "device_model": UIDevice.currentDevice().type.rawValue,
                    "device_unique_id": uuid
                ]
                
                Alamofire.request(.POST, fullPath, parameters: parameters as [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                    
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
 
    class func deviceLock(force: Bool, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.getDeviceLockUrl() else {
            return
        }
        
        // get additional headers from oauth
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                var uuid: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
                if let temp = KeyChainAccessProxy.getValue(IDENTIFIER_FOR_VENDOR_KEY) as? String {
                    uuid = temp
                }
                
                // make parameters
                let parameters: [String : AnyObject] = ["device_name": "ios",
                    "device_model": UIDevice.currentDevice().type.rawValue,
                    "device_unique_id": uuid,
                    "force": force
                ]
                
                Alamofire.request(.POST, fullPath, parameters: parameters as [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                    
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

    class func deviceAcquire(completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.getDeviceAcquireUrl() else {
            return
        }
        
        // get additional headers from oauth
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                var uuid: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
                if let temp = KeyChainAccessProxy.getValue(IDENTIFIER_FOR_VENDOR_KEY) as? String {
                    uuid = temp
                }
                
                // make parameters
                let parameters: [String : AnyObject] = ["device_name": "ios",
                    "device_unique_id": uuid
                ]
                
                Alamofire.request(.POST, fullPath, parameters: parameters as [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                    
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

    class func deviceState(completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        guard let fullPath = UrlMakerSingleton.sharedInstance.getDeviceStateUrl() else {
            return
        }
        
        // get additional headers from oauth
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                var uuid: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
                if let temp = KeyChainAccessProxy.getValue(IDENTIFIER_FOR_VENDOR_KEY) as? String {
                    uuid = temp
                }
                
                // make parameters
                let parameters: [String : AnyObject] = ["device_name": "ios",
                    "device_unique_id": uuid
                ]
                
                Alamofire.request(.POST, fullPath, parameters: parameters as [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                    
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
