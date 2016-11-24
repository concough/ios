//
//  UrlMakerSingleton.swift
//  Concough
//
//  Created by Owner on 2016-11-24.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

class UrlMakerSingleton {
    private var _base_url: String!
    private var _api_version: String!
    private var _media_class_name: String!
    private var _activity_class_name: String!
    
    static let sharedInstance = UrlMakerSingleton()
    
    private init() {
        // in future must be read from user defaults
        self._base_url = BASE_URL
        self._api_version = API_VERSION
        self._media_class_name = MEDIA_CLASS_NAME
        self._activity_class_name = ACTIVITY_CLASS_NAME
    }
    
    internal func mediaUrlFor(type: String, mediaId: AnyObject) -> String? {
        let functionName = "\(type)/\(mediaId)"
        let fullPath = "\(self._base_url)\(self._api_version)/\(self._media_class_name)/\(functionName)"
        
        return fullPath
    }
    
    internal func activityUrl() -> String? {
        let fullPath = "\(self._base_url)\(self._api_version)/\(self._activity_class_name)/"
        return fullPath
    }
    
    internal func activityUrlWithNext(next: String) -> String? {
        if var path = UrlMakerSingleton.sharedInstance.activityUrl() {
            path += "next/\(next)"
            return path
        }
        return nil
    }
}
