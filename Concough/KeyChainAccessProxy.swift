//
//  KeyChainAccess.swift
//  Concough
//
//  Created by Owner on 2016-11-27.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class KeyChainAccessProxy {
    class func getValue(key: String) -> NSCoding? {
        let value = KeychainWrapper.defaultKeychainWrapper().objectForKey(key)
        //print("keychain --> get value for \(key) \(value)")
        return value
    }
    
    class func setValue(key: String, value: NSCoding) -> Bool {
        //let val = value as! String
        //print("keychain --> set value for \(key): \(val)")
        return KeychainWrapper.defaultKeychainWrapper().setObject(value, forKey: key)
    }
    
    class func removeValue(key: String) -> Bool {
        return KeychainWrapper.defaultKeychainWrapper().removeObjectForKey(key)
    }
    
    class func clearAllValue() -> Bool {
        return KeychainWrapper.defaultKeychainWrapper().removeAllKeys()
    }
}
