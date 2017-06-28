//
//  TypeExtensions.swift
//  Concough
//
//  Created by Owner on 2016-12-10.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String? {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func base64Encoded() -> String {
        let plainData = dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    
    mutating func base64Decoded() -> String {
        let reminder = self.characters.count % 4
        if reminder > 0 {
            self = self.stringByPaddingToLength(self.characters.count + 4 - reminder, withString: "=", startingAtIndex: 0)
        }
        
        let decodedData = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions.init(rawValue: 0))
        let decodedString = String(data: decodedData!, encoding: NSUTF8StringEncoding)
        return decodedString!
    }

    mutating func base64DecodedUsingAscii() -> String {
        let reminder = self.characters.count % 4
        if reminder > 0 {
            self = self.stringByPaddingToLength(self.characters.count + 4 - reminder, withString: "=", startingAtIndex: 0)
        }
        let decodedData = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions.init(rawValue: 0))
        let decodedString = String(data: decodedData!, encoding: NSASCIIStringEncoding)
        return decodedString!
    }
    
    func base64Encoded() -> NSData {
        let plainData = dataUsingEncoding(NSUTF8StringEncoding)
        return plainData!
    }
    
    mutating func base64Decoded() -> NSData {
        let reminder = self.characters.count % 4
        if reminder > 0 {
            self = self.stringByPaddingToLength(self.characters.count + 4 - reminder, withString: "=", startingAtIndex: 0)
        }
        let decodedData = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions.init(rawValue: 0))
        return decodedData!
    }

}
