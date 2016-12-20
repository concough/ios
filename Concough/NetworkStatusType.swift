//
//  NetworkStatusType.swift
//  Concough
//
//  Created by Owner on 2016-12-19.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

enum NetworkErrorType: String, ErrorType {
    case NoInternetAccess = "NoInternetAccess"
    case UnKnown = "UnKnown"
    
    static func toType(error: NSError) -> NetworkErrorType {
        if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
            return .NoInternetAccess
        }
        return .UnKnown
    }
    
}
