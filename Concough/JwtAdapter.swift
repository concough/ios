//
//  JwtAdapter.swift
//  Concough
//
//  Created by Owner on 2016-12-19.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class JwtTokenAdapter {
    class func token(username username: String, password: String, completion: (data: JSON?, statusCode: Int, error: NSError?) -> (), failure: (error: NSError?) -> ()) {
        
        guard let fullPath = UrlMakerSingleton.sharedInstance.jwtTokenUrl() else {
            return
        }
        
        let parameters: [String: String] = [
                                            "username": username,
                                            "password": password]
        let headers: [String: String] = ["Content-Type": "application/json"]
        
        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON {
            response in
        
            switch (response.result) {
            case .Success:
                let statusCode = response.response?.statusCode
                let data = JSON(data: response.data!)
                
                completion(data: data, statusCode: statusCode!, error: nil)
                
                
            case .Failure(let error):
                // cannot access serever
                failure(error: error)
            }

        }
    }

    class func refreshToken(token token: String, completion: (data: JSON?, statusCode: Int, error: NSError?) -> (), failure: (error: NSError?) -> ()) {

        guard let fullPath = UrlMakerSingleton.sharedInstance.jwtRefreshTokenUrl() else {
            return
        }
        
        let parameters: [String: String] = [
            "token": token]
        let headers: [String: String] = ["Content-Type": "application/json"]
        
        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON {
            response in
            
            switch (response.result) {
            case .Success:
                let statusCode = response.response?.statusCode
                let data = JSON(data: response.data!)
                completion(data: data, statusCode: statusCode!, error: nil)
                
                
            case .Failure(let error):
                // cannot access serever
                failure(error: error)
            }
            
        }
        
    }
    
    class func verify(token token: String, completion: (data: JSON?, statusCode: Int, error: NSError?) -> (), failure: (error: NSError?) -> ()) {

        guard let fullPath = UrlMakerSingleton.sharedInstance.jwtVerifyTokenUrl() else {
            return
        }
        
        let parameters: [String: String] = [
            "token": token]
        let headers: [String: String] = ["Content-Type": "application/json"]
        
        Alamofire.request(.POST, fullPath, parameters: parameters, encoding: .JSON, headers: headers).responseJSON {
            response in
            
            switch (response.result) {
            case .Success:
                let statusCode = response.response?.statusCode
                let data = JSON(data: response.data!)
                completion(data: data, statusCode: statusCode!, error: nil)
                
                
            case .Failure(let error):
                // cannot access serever
                failure(error: error)
            }
            
        }
        
    }
}
