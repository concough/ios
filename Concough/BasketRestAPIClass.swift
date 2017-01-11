//
//  BasketRestAPIClass.swift
//  Concough
//
//  Created by Owner on 2017-01-04.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class BasketRestAPIClass {
    class func createBasket(completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.getCreateBasketUrl() else {
            return
        }
        
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                Alamofire.request(.POST, fullPath, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
                    
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
                
            }
            }, failure: { (error) in
                failure(error: error)
        })
    }
    
    class func addProductToBasket (basketId basketId: String, productId: String, productType: String, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.getAddEntranceToBasketUrl(basketId: basketId) else {
            return
        }
        
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                let parameters: [String: AnyObject] = ["product_id": productId,
                                                        "product_type": productType]
                
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
                
            }
            }, failure: { (error) in
                failure(error: error)
        })
    }
    
    class func removeSaleFormBasket (basketId basketId: String, saleId: Int, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.getRemoveSaleFormBasketUrl(basketId: basketId, saleId: saleId) else {
            return
        }
        
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                Alamofire.request(.DELETE, fullPath, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
                    
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
                
            }
            }, failure: { (error) in
                failure(error: error)
        })
    }

    class func loadBasketItems(completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.getLoadBasketItemsUrl() else {
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
                
            }
        }, failure: { (error) in
            failure(error: error)
        })
    }
    
    class func checkoutBasket(basketId basketId: String, completion: (data: JSON?, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.getCheckoutBasketUrl(basketId: basketId) else {
            return
        }
        
        TokenHandlerSingleton.sharedInstance.assureAuthorized(completion: { (authenticated, error) in
            if authenticated && error == .Success {
                
                let headers = TokenHandlerSingleton.sharedInstance.getHeader()
                
                Alamofire.request(.POST, fullPath, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
                    
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
                
            }
            }, failure: { (error) in
                failure(error: error)
        })
    }
}
