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

extension NSDate {
    func timeAgoSinceDate(lang lang: String = "fa", numericDates:Bool = false) -> String {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = now.earlierDate(self)
        let latest = (earliest == now) ? self : now
        let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
        
        if (components.year >= 2) {
            return timesAgoTranslate(lang: lang, key: "d_year_ago", params: components.year)
        } else if (components.year >= 1){
            if (numericDates){
                return timesAgoTranslate(lang: lang, key: "1_year_ago", params: 0)
            } else {
                return timesAgoTranslate(lang: lang, key: "last_year", params: 0)
            }
        } else if (components.month >= 2) {
            return timesAgoTranslate(lang: lang, key: "d_month_ago", params: components.month)
        } else if (components.month >= 1){
            if (numericDates){
                return timesAgoTranslate(lang: lang, key: "1_month_ago", params: 0)
            } else {
                return timesAgoTranslate(lang: lang, key: "last_month", params: 0)
            }
        } else if (components.weekOfYear >= 2) {
            return timesAgoTranslate(lang: lang, key: "d_week_ago", params: components.weekOfYear)
        } else if (components.weekOfYear >= 1){
            if (numericDates){
                return timesAgoTranslate(lang: lang, key: "1_week_ago", params: 0)
            } else {
                return timesAgoTranslate(lang: lang, key: "last_week", params: 0)
            }
        } else if (components.day >= 2) {
            return timesAgoTranslate(lang: lang, key: "d_day_ago", params: components.day)
        } else if (components.day >= 1){
            if (numericDates){
                return timesAgoTranslate(lang: lang, key: "1_day_ago", params: 0)
            } else {
                return timesAgoTranslate(lang: lang, key: "last_day", params: 0)
            }
        } else if (components.hour >= 2) {
            return timesAgoTranslate(lang: lang, key: "d_hour_ago", params: components.hour)
        } else if (components.hour >= 1){
            if (numericDates){
                return timesAgoTranslate(lang: lang, key: "1_hour_ago", params: 0)
            } else {
                return timesAgoTranslate(lang: lang, key: "last_hour", params: 0)
            }
        } else if (components.minute >= 2) {
            return timesAgoTranslate(lang: lang, key: "d_minute_ago", params: components.minute)
        } else if (components.minute >= 1){
            if (numericDates){
                return timesAgoTranslate(lang: lang, key: "1_minute_ago", params: 0)
            } else {
                return timesAgoTranslate(lang: lang, key: "last_minute", params: 0)
            }
        } else if (components.second >= 10) {
            return timesAgoTranslate(lang: lang, key: "d_second_ago", params: components.second)
        } else {
            return timesAgoTranslate(lang: lang, key: "just_now", params: 0)
        }
    }
}
