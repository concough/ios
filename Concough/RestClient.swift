//
//  RestClient.swift
//  Concough
//
//  Created by Owner on 2016-02-13.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

class RestClient {
    class func Get(url: String, callback: (JSON?, NSError?)->()) {
        let url = NSURL(string: url)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) in
            
            if let err = error {
                callback(nil, err)
            }

            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // attempt to parse
                    var parseError: NSError?
                    
                    let parsedData = JSONParser.parse(data!, error: &parseError)
                    if let err = parseError {
                        callback(nil, err)
                    }
                    
                    callback(parsedData, nil)
                } else {
                    callback(nil, nil)
                }
            }
        }
        
        task.resume()
    }

    class func GetFile(url: String, callback: (NSData?, NSError?)->()) {
        let url = NSURL(string: url)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) in
            
            if let err = error {
                callback(nil, err)
            }
            
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    callback(data, nil)
                } else {
                    callback(nil, nil)
                }
            }
        }
        
        task.resume()
    }
    
    class func Post(url: String, data: [String: AnyObject], callback: (JSON?, NSError?)->()) {
        let url = NSURL(string: url)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let paramData = try NSJSONSerialization.dataWithJSONObject(data, options: [])
            request.HTTPBody = paramData
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                (data, response, error) in
                
                if let err = error {
                    callback(nil, err)
                }
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        var parseError: NSError?
                        
                        let parsedData = JSONParser.parse(data!, error: &parseError)
                        if let err = parseError {
                            callback(nil, err)
                        }
                        
                        callback(parsedData, nil)
                        
                    } else {
                        callback(nil, nil)
                    }
                }
            }
            
            task.resume()
            
        } catch _ as NSError {
            
        }
    }
}