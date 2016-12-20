//
//  TokenHandlerSingleton.swift
//  Concough
//
//  Created by Owner on 2016-11-27.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

class TokenHandlerSingleton {
    private var _token: String? = nil
    private var _refreshToken: String? = nil
    private var _username: String? = nil
    private var _password: String? = nil
    private var _tokenType: String = "Bearer"
    private var _oauth_method: String = OAUTH_METHOD
    private var _lastTime: NSDate?
    private var _expiresIn: Int?
    
    static let sharedInstance = TokenHandlerSingleton()
    
    func setUsernameAndPassword(username username: String, password: String) {
        self._username = username
        self._password = password
    }
    
    private init() {
        // initialize oauth tokens
        if self._oauth_method == "oauth" {
            if let token = KeyChainAccessProxy.getValue(OAUTH_TOKEN_KEY) as? String, let rtoken = KeyChainAccessProxy.getValue(OAUTH_REFRESH_TOKEN_KEY) as? String, let username = KeyChainAccessProxy.getValue(USERNAME_KEY) as? String, let password = KeyChainAccessProxy.getValue(PASSWORD_KEY) as? String {
                
                if token != "" { self._token = token }
                if rtoken != "" { self._refreshToken = rtoken }
                if username != "" { self._username = username }
                if password != "" { self._password = password }
                
                self._lastTime = KeyChainAccessProxy.getValue(OAUTH_LAST_ACCESS_KEY) as? NSDate
                self._expiresIn = KeyChainAccessProxy.getValue(OAUTH_EXPIRES_IN_KEY) as? Int
                
            }
            if let tokenType = KeyChainAccessProxy.getValue(OAUTH_TOKEN_TYPE_KEY) as? String {
                self._tokenType = tokenType
            }
        } else if self._oauth_method == "jwt" {
            if let token = KeyChainAccessProxy.getValue(OAUTH_TOKEN_KEY) as? String, let username = KeyChainAccessProxy.getValue(USERNAME_KEY) as? String, let password = KeyChainAccessProxy.getValue(PASSWORD_KEY) as? String {
                
                if token != "" { self._token = token }
                if username != "" { self._username = username }
                if password != "" { self._password = password }
            }
            if let tokenType = KeyChainAccessProxy.getValue(OAUTH_TOKEN_TYPE_KEY) as? String {
                self._tokenType = tokenType

                self._lastTime = KeyChainAccessProxy.getValue(OAUTH_LAST_ACCESS_KEY) as? NSDate
                self._expiresIn = KeyChainAccessProxy.getValue(OAUTH_EXPIRES_IN_KEY) as? Int
            }
            
        }
    }
    
    func authorize(completion: (error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {

        if self._oauth_method == "oauth" {
            AccessTokenAdapter.authorize(username: self._username!, password: self._password!, completion: { data, statusCode, err in

                //print ("TokenHandlerSingleton --> authorize: \(statusCode) - \(err)\n")
                if statusCode == 200 {
                    // extrace token and refresh_token from response
                    if let localData = data {
                        if let token = localData["access_token"].string where token != "", let rtoken = localData["refresh_token"].string where rtoken != "" {
                            
                            
                            self._token = token
                            self._refreshToken = rtoken
                            self._tokenType = localData["token_type"].stringValue
                            self._expiresIn = localData["expires_in"].intValue
                            self._lastTime = NSDate()
                            
                            //self.printData(when: "after")
                            
                            // set keychain value
                            KeyChainAccessProxy.setValue(OAUTH_TOKEN_KEY, value: self._token!)
                            KeyChainAccessProxy.setValue(OAUTH_REFRESH_TOKEN_KEY, value: self._refreshToken!)
                            KeyChainAccessProxy.setValue(OAUTH_TOKEN_TYPE_KEY, value: self._tokenType)
                            KeyChainAccessProxy.setValue(OAUTH_EXPIRES_IN_KEY, value: self._expiresIn!)
                            KeyChainAccessProxy.setValue(OAUTH_LAST_ACCESS_KEY, value: self._lastTime!)
                            
                            completion(error: HTTPErrorType.Success)
                        }
                    }
                } else {
                    completion(error: HTTPErrorType.toType(statusCode))
                }
            }, failure: { (error) in
                    failure(error: NetworkErrorType.toType(error!))
            })
        } else if self._oauth_method == "jwt" {
            JwtTokenAdapter.token(username: self._username!, password: self._password!, completion: { (data, statusCode, error) in
                
                if statusCode == 200 {
                    // extrace token and refresh_token from response
                    if let localData = data {
                        if let token = localData["token"].string where token != "" {
                            
                            self._token = token
                            self._tokenType = "JWT"
                            
                            // Get Exp Time
                            if let payload = JwtHandler.getPayloadData(token) {
                                let exp = payload["exp"].intValue
                                let orig_iat = payload["orig_iat"].intValue
                                self._expiresIn = exp - orig_iat
                                
                                let date = NSDate(timeIntervalSince1970: NSTimeInterval(orig_iat))
                                self._lastTime = date

                                KeyChainAccessProxy.setValue(OAUTH_EXPIRES_IN_KEY, value: self._expiresIn!)
                                KeyChainAccessProxy.setValue(OAUTH_LAST_ACCESS_KEY, value: self._lastTime!)
                            }
                            
                            // set keychain value
                            KeyChainAccessProxy.setValue(OAUTH_TOKEN_KEY, value: self._token!)
                            KeyChainAccessProxy.setValue(OAUTH_TOKEN_TYPE_KEY, value: self._tokenType)
                            
                            completion(error: HTTPErrorType.Success)
                        }
                    }
                } else {
                    completion(error: HTTPErrorType.toType(statusCode))
                }
                
                }, failure: { (error) in
                    // Network failure
                    failure(error: NetworkErrorType.toType(error!))
            })
        }
    }
    
    func refreshToken(completion: (error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        if self._oauth_method == "oauth" {
            if self._refreshToken != nil {
                // call refresh token method
                //self.printData(when: "before")

                AccessTokenAdapter.refreshToken(refToken: self._refreshToken!, completion: { (data, statusCode, err) in

                    //print ("TokenHandlerSingleton --> refreshToken: \(statusCode) - \(err)\n")
                    if statusCode == 200 {
                        // extrace token and refresh_token from response
                        if let localData = data {
                            if let token = localData["access_token"].string where token != "", let rtoken = localData["refresh_token"].string where rtoken != "" {
                                
                                
                                self._token = token
                                self._refreshToken = rtoken
                                self._tokenType = localData["token_type"].stringValue
                                self._expiresIn = localData["expires_in"].intValue
                                self._lastTime = NSDate()
                                
                                //self.printData(when: "after")
                                
                                // set keychain value
                                KeyChainAccessProxy.setValue(OAUTH_TOKEN_KEY, value: self._token!)
                                KeyChainAccessProxy.setValue(OAUTH_REFRESH_TOKEN_KEY, value: self._refreshToken!)
                                KeyChainAccessProxy.setValue(OAUTH_TOKEN_TYPE_KEY, value: self._tokenType)
                                KeyChainAccessProxy.setValue(OAUTH_EXPIRES_IN_KEY, value: self._expiresIn!)
                                KeyChainAccessProxy.setValue(OAUTH_LAST_ACCESS_KEY, value: self._lastTime!)
                                
                                completion(error: HTTPErrorType.Success)
                            }
                        }
                    } else {
                        completion(error: HTTPErrorType.toType(statusCode))
                    }
                    
                    }, failure: { (error) in
                        failure(error: NetworkErrorType.toType(error!))
                })
            }
        } else if self._oauth_method == "jwt" {
            JwtTokenAdapter.refreshToken(token: self._token!, completion: { (data, statusCode, error) in
                if statusCode == 200 {
                    // extrace token and refresh_token from response
                    if let localData = data {
                        if let token = localData["token"].string where token != "" {
                            
                            self._token = token
                            self._tokenType = "JWT"
                            
                            // Get Exp Time
                            if let payload = JwtHandler.getPayloadData(token) {
                                let exp = payload["exp"].intValue
                                let orig_iat = payload["orig_iat"].intValue
                                self._expiresIn = exp - orig_iat
                                
                                let date = NSDate(timeIntervalSince1970: NSTimeInterval(orig_iat))
                                self._lastTime = date
                                
                                KeyChainAccessProxy.setValue(OAUTH_EXPIRES_IN_KEY, value: self._expiresIn!)
                                KeyChainAccessProxy.setValue(OAUTH_LAST_ACCESS_KEY, value: self._lastTime!)
                            }
                            
                            // set keychain value
                            KeyChainAccessProxy.setValue(OAUTH_TOKEN_KEY, value: self._token!)
                            KeyChainAccessProxy.setValue(OAUTH_TOKEN_TYPE_KEY, value: self._tokenType)
                            
                            completion(error: HTTPErrorType.Success)
                        }
                    }
                } else {
                    completion(error: HTTPErrorType.toType(statusCode))
                }
                
                }, failure: { (error) in
                    failure(error: NetworkErrorType.toType(error!))
            })
        }
    }
    
    func getHeader() -> [String: String]? {
        if let token = self._token {
            let headers = ["Authorization": "\(self._tokenType) \(token)"]
            return headers
        }
        return nil
    }
    
    func isAuthorized() -> Bool {
        if self._oauth_method == "oauth" {
            return (self._token != nil && self._refreshToken != nil)
        }
        return self._token != nil
    }
    
    func isAuthenticated() -> Bool {
        return (self._username != nil && self._password != nil)
    }
    
    func assureAuthorized(refresh: Bool = false, completion: (authenticated: Bool, error: HTTPErrorType?) -> (), failure: (error: NetworkErrorType?) -> ()) {
        
        if self.isAuthorized() {
            //print ("TokenHandlerSingleton --> assureAuthorized: Authorized\n")
            if refresh {
                self.refreshToken({ (error) in
                    if error == .Success {
                        completion(authenticated: true, error: error)
                    } else {
                        if error == .BadRequest {
                            self.authorize({ (error) in
                                if error == .Success {
                                    completion(authenticated: true, error: error)
                                } else {
                                    completion(authenticated: false, error: error)
                                }
                            }, failure: { (error) in
                                failure(error: error)
                            })
                        }
                        completion(authenticated: false, error: error)
                    }
                }, failure: { (error) in
                    failure(error: error)
                })
            } else {
                if let last_time = self._lastTime, let expiresIn = self._expiresIn {
                    let timeDiff = Int(NSDate().timeIntervalSinceDate(last_time))
                    if timeDiff >= expiresIn - 60 {
                        self.refreshToken({ (error) in
                            //print ("TokenHandlerSingleton --> assureAuthorized: Expired\n")
                            if error == .Success {
                                completion(authenticated: true, error: error)
                            } else {
                                if error == .BadRequest {
                                    self.authorize({ (error) in
                                        if error == .Success {
                                            completion(authenticated: true, error: error)
                                        } else {
                                            completion(authenticated: false, error: error)
                                        }
                                        }, failure: { (error) in
                                            failure(error: error)
                                    })
                                }
                                completion(authenticated: false, error: error)
                            }
                        }, failure: { error in
                            failure(error: error)
                        })
                    } else {
                        completion(authenticated: true, error: .Success)
                    }
                }
            }
        } else {
            if self.isAuthenticated() {
                //print ("TokenHandlerSingleton --> assureAuthorized: Not Authorized but Authenticated\n")
                self.authorize({ (error) in
                    if error == .Success {
                        completion(authenticated: true, error: error)
                    } else {
                        completion(authenticated: false, error: error)
                    }
                }, failure: { error in
                    failure(error: error)
                })
            } else {
                //print ("TokenHandlerSingleton --> assureAuthorized: Not Authenticated\n")
                completion(authenticated: false, error: nil)
            }
        }
    }
    
    private func printData(when when: String) {
        print("oauth data \(when) --> \(self._token) - \(self._refreshToken)")
    }
}
