//
//  MediaCacheSingleton.swift
//  Concough
//
//  Created by Owner on 2016-11-23.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import UIKit

class MediaCacheSingleton {
    private let cache: NSCache!
    
    static let sharedInstance: MediaCacheSingleton = {
        let instance = MediaCacheSingleton()
        
        return instance
    }()
    
    private init() {
        cache = NSCache()
        cache.countLimit = MEDIA_CACHE_COUNT
        cache.name = "Media Cache"
        cache.totalCostLimit = MEDIA_CACHE_SIZE
    }
    
    internal subscript(x: String) -> NSData? {
        get {
            return self.cache.objectForKey(x) as? NSData
        }
        set {
            guard self.cache.objectForKey(x) != nil else {
                self.cache.setObject(newValue!, forKey: x)
                return
            }
        }
    }
    
    internal func clear() {
        self.cache.removeAllObjects()
    }
}
