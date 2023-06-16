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
    
    
    class func downloadEsetImage(localName name: String, indexPath: NSIndexPath, imageId: Int, completion: (fullUrl: String?, data: NSData?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        if let fullPath = MediaRestAPIClass.makeEsetImageUri(imageId) {
            
            
            
            // get additional headers from oauth
            TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
                if authenticated && error == .Success {
                    let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                    
                    let request = Alamofire.request(.GET ,fullPath, parameters: nil, encoding: .URL, headers: headers).responseData() { response in
                        
                        switch response.result {
                        case .Success:
                            let statusCode = response.response?.statusCode
                            let errorType = HTTPErrorType.toType(statusCode!)

                            
                            switch errorType {
                            case .Success:
                                guard let data = response.result.value else {
                                    return
                                }
                                // call callback function
                                completion(fullUrl: fullPath, data: data, error: .Success)
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
                    
                    // cache Request for future use
                    let key = "\(name):\(indexPath.section):\(indexPath.row):\(fullPath)"
                    MediaRequestRepositorySingleton.sharedInstance.add(key: key, value: request)
                    
                } else {
                    completion(fullUrl: fullPath, data: nil, error: error)
                }
            }, failure: { (error) in
                failure(error: error)
            })
        } else {
            // can not make url --> must return an error
        }
    }

    class func downloadEsetImageLocal(imageId: Int, completion: (fullUrl: String?, data: NSData?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        if let fullPath = MediaRestAPIClass.makeEsetImageUri(imageId) {
            
            // get additional headers from oauth
            TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
                if authenticated && error == .Success {
                    let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                    
                    let request = Alamofire.request(.GET ,fullPath, parameters: nil, encoding: .URL, headers: headers).responseData() { response in
                        
                        switch response.result {
                        case .Success:
                            let statusCode = response.response?.statusCode
                            let errorType = HTTPErrorType.toType(statusCode!)
                            
                            
                            switch errorType {
                            case .Success:
                                guard let data = response.result.value else {
                                    return
                                }
                                // call callback function
                                completion(fullUrl: fullPath, data: data, error: .Success)
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
                                        
                } else {
                    completion(fullUrl: fullPath, data: nil, error: error)
                }
                }, failure: { (error) in
                    failure(error: error)
            })
        } else {
            // can not make url --> must return an error
        }
    }
    
    
    class func downloadEntranceQuestionImage(manager manager: Alamofire.Manager, uniqueId: String, imageId: String, completion: (fullUrl: String?, data: NSData?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        if let fullPath = UrlMakerSingleton.sharedInstance.mediaUrlForQuestion(uniqueId: uniqueId, mediaId: imageId) {
            // get additional headers from oauth
            TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
                if authenticated && error == .Success {
                    let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                    
                    manager.request(.GET ,fullPath, parameters: nil, encoding: .URL, headers: headers).responseData() { response in
                        
                        switch response.result {
                        case .Success:
                            let statusCode = response.response?.statusCode
                            let errorType = HTTPErrorType.toType(statusCode!)
                            
                            switch errorType {
                            case .Success:
                                guard let data = response.result.value else {
                                    return
                                }
                                // call callback function
                                completion(fullUrl: fullPath, data: data, error: .Success)
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
                    
                } else {
                    completion(fullUrl: fullPath, data: nil, error: error)
                }
                }, failure: { (error) in
                    failure(error: error)
            })
        } else {
            // can not make url --> must return an error
        }
    }

    class func downloadEntranceQuestionBulkImages(manager manager: Alamofire.Manager, uniqueId: String, questionsId: [String], completion: (fullUrl: String?, data: NSData?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        if let fullPath = UrlMakerSingleton.sharedInstance.mediaUrlForBulkQuestion(uniqueId: uniqueId) {
            // get additional headers from oauth
            TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
                if authenticated && error == .Success {
                    let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                    
                    var parameters: [String: AnyObject] = [:]
                    var query = ""
                    for (index, element) in questionsId.enumerate() {
                        if index != questionsId.count - 1 {
                            query += "\(element)$"
                        } else {
                            query += "\(element)"
                        }
                    }
                    parameters.updateValue(query, forKey: "ids")
                    
                    Alamofire.request(.GET ,fullPath, parameters: parameters, encoding: .URLEncodedInURL, headers: headers).responseData() { response in
                        
                        switch response.result {
                        case .Success:
                            let statusCode = response.response?.statusCode
                            let errorType = HTTPErrorType.toType(statusCode!)
                            
                            switch errorType {
                            case .Success:
                                guard let data = response.result.value else {
                                    return
                                }
                                // call callback function
                                completion(fullUrl: fullPath, data: data, error: .Success)
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
                    
                } else {
                    completion(fullUrl: fullPath, data: nil, error: error)
                }
                }, failure: { (error) in
                    failure(error: error)
            })
        } else {
            // can not make url --> must return an error
        }
    }

}
