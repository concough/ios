//
//  HttpStatusType.swift
//  Concough
//
//  Created by Owner on 2016-11-29.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

enum HTTPErrorType: Int, ErrorType {
    case Success = 200
    case UnAuthorized = 401
    case ForbidenAccess = 403
    case NotFound = 404
    case ServerInternalError = 500
    case UnKnown = 0
    
    static func toType(item: Int) -> HTTPErrorType {
        switch item {
        case 200...209:
            return .Success
        case 401:
            return .UnAuthorized
        case 403:
            return .ForbidenAccess
        case 404:
            return .NotFound
        case 500:
            return .ServerInternalError
        default:
            return .UnKnown
        }
    }
}
