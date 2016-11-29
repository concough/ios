//
//  OAuthHandlerSingleton.swift
//  Concough
//
//  Created by Owner on 2016-11-27.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

class OAuthHandlerSingleton {
    private var _token: String? = nil
    private var _refreshToken: String? = nil
    private var _username: String? = nil
    private var _password: String? = nil
    private var _tokenType: String = "Bearer"
    private var _lastTime: NSDate?
    private var _expiresIn: Int?
    
    static let sharedInstance = OAuthHandlerSingleton()
    
    func setUsernameAndPassword(username username: String, password: String) {
        self._username = username
        self._password = password
    }
    
    private init() {
        // initialize oauth tokens
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
    }
    
    func authorize(completion: (error: HTTPErrorType?) -> ()) {
        if _token ==  nil && _refreshToken == nil {
            // get Token Json from server
            //self.printData(when: "before")

            AccessTokenAdapter.authorize(username: self._username!, password: self._password!, completion: { data, statusCode, err in

                print ("OAuthHandlerSingleton --> authorize: \(statusCode) - \(err)\n")
                
                if statusCode == 401 {
                    // unauthorized access
                    completion(error: HTTPErrorType.UnAuthorized)
                    
                } else if statusCode == 404 {
                    // Url Not Found
                    completion(error: HTTPErrorType.NotFound)
                    
                } else if statusCode == 403 {
                    completion(error: HTTPErrorType.ForbidenAccess)
                    
                } else if statusCode == 200 {
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
                            
                            completion(error: nil)
                        }
                    }
                } else {
                    completion(error: HTTPErrorType.UnKnown)
                }
            })
        }
    }
    
    func refreshToken(completion: (error: HTTPErrorType?) -> ()) {
        if self._refreshToken != nil {
            // call refresh token method
            //self.printData(when: "before")

            AccessTokenAdapter.refreshToken(refToken: self._refreshToken!, completion: { (data, statusCode, err) in

                print ("OAuthHandlerSingleton --> refreshToken: \(statusCode) - \(err)\n")
                
                if statusCode == 401 {
                    self.authorize({ (error) in
                        completion(error: error)
                    })
                    // unauthorized access
                } else if statusCode == 403 {
                    completion(error: HTTPErrorType.ForbidenAccess)
                
                } else if statusCode == 200 {
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
                            
                            completion(error: nil)
                        }
                    }
                } else {
                    completion(error: HTTPErrorType.UnKnown)
                }
                
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
        return (self._token != nil && self._refreshToken != nil)
    }
    
    func isAuthenticated() -> Bool {
        return (self._username != nil && self._password != nil)
    }
    
    func assureAuthorized(refresh: Bool = false, completion: (authenticated: Bool, error: HTTPErrorType?) -> ()) {
        
        if self.isAuthorized() {
            print ("OAuthHandlerSingleton --> assureAuthorized: Authorized\n")
            if refresh {
                self.refreshToken({ (error) in
                    completion(authenticated: true, error: error)
                })
            } else {
                if let last_time = self._lastTime, let expiresIn = self._expiresIn {
                    let timeDiff = Int(NSDate().timeIntervalSinceDate(last_time))
                    if timeDiff >= expiresIn - 60 {
                        self.refreshToken({ (error) in
                            print ("OAuthHandlerSingleton --> assureAuthorized: Expired\n")
                            completion(authenticated: true, error: error)
                        })
                    } else {
                        completion(authenticated: true, error: nil)
                    }
                }
            }
        } else {
            if self.isAuthenticated() {
                print ("OAuthHandlerSingleton --> assureAuthorized: Not Authorized but Authenticated\n")
                self.authorize({ (error) in
                    completion(authenticated: true, error: error)
                })
            } else {
                print ("OAuthHandlerSingleton --> assureAuthorized: Not Authenticated\n")
                completion(authenticated: false, error: nil)
            }
        }
    }
    
    private func printData(when when: String) {
        print("oauth data \(when) --> \(self._token) - \(self._refreshToken)")
    }
}
