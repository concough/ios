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
        return value
    }
    
    class func setValue(key: String, value: NSCoding) -> Bool {
        return KeychainWrapper.defaultKeychainWrapper().setObject(value, forKey: key)
    }
    
    class func removeValue(key: String) -> Bool {
        return KeychainWrapper.defaultKeychainWrapper().removeObjectForKey(key)
    }
    
    class func clearAllValue() -> Bool {
        return KeychainWrapper.defaultKeychainWrapper().removeAllKeys()
    }
}
