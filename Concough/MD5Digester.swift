//
//  MD5Digester.swift
//  Concough
//
//  Created by Owner on 2017-01-31.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation

class MD5Digester {
    class func digest(text: String) -> String {
        guard let data = text.dataUsingEncoding(NSUTF8StringEncoding) else {
            return ""
        }
        var dige = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        CC_MD5(data.bytes, CC_LONG(data.length), &dige)
        
        var digeHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digeHex += String(format: "%02x", dige[index])
        }
        
        return digeHex
    }
}
