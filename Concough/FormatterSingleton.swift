//
//  FormatterSingleton.swift
//  Concough
//
//  Created by Owner on 2016-11-24.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

class FormatterSingleton {
    
    private let _IRdateFormatter: NSDateFormatter!
    private let _UTCdateFormatter: NSDateFormatter!
    private let _numberFormatter: NSNumberFormatter!
    
    static let sharedInstance = FormatterSingleton()
    
    private init() {
        self._IRdateFormatter = NSDateFormatter()
        self._IRdateFormatter.dateStyle = .MediumStyle
        self._IRdateFormatter.timeZone = NSTimeZone(name: "Asia/tehran")
        self._IRdateFormatter.locale = NSLocale(localeIdentifier: "fa_IR")
        
        self._UTCdateFormatter = NSDateFormatter()
        self._UTCdateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self._UTCdateFormatter.timeZone = NSTimeZone(name: "UTS")
        
        self._numberFormatter = NSNumberFormatter()
        self._numberFormatter.numberStyle = .NoStyle
        self._numberFormatter.locale = NSLocale(localeIdentifier: "fa")
    }
    
    var IRDateFormatter: NSDateFormatter {
        get {
            return self._IRdateFormatter
        }
    }
    
    var UTCDateFormatter: NSDateFormatter {
        get {
            return self._UTCdateFormatter
        }
    }
    
    var NumberFormatter: NSNumberFormatter {
        get {
            return self._numberFormatter
        }
    }
}
