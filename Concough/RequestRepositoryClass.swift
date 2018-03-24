//
//  RequestRepositoryClass.swift
//  Concough
//
//  Created by Owner on 2016-12-03.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import Alamofire

class RequestRepositoryClass {
    private var repo: [String: Request]!
    private let lock: NSLock!
    
    init() {
        self.repo = [String: Request]()
        self.lock = NSLock();
    }
    
    func add(key key: String, value: Request) -> Bool {
        let result: Bool = synchronizedResult(self.lock) {
            if !self.repo.keys.contains(key) {
                self.repo.updateValue(value, forKey: key)
                return true
            }
            return false
        }
        
        return result
    }
    
    func remove(key key: String) -> Bool {
        let result: Bool = synchronizedResult(self.lock) {
            if self.repo.keys.contains(key) {
                self.repo.removeValueForKey(key)
                return true
            }
            
            return false
        }
        
        return result
    }
    
    func cancel(key key: String) -> Bool {
        let result: Bool = synchronizedResult(self.lock) {
            if let value = self.repo[key] {
                value.cancel()
                return true
            }
            return false
        }
        
        return result
    }
}
