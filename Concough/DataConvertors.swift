//
//  DataConvertors.swift
//  Concough
//
//  Created by Owner on 2017-10-04.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation

let answers: [Int: String] = [
    0: "هیچکدام",
    1: "۱",
    2: "۲",
    3: "۳",
    4: "۴",
    5: "۱و ۲",
    6: "۱ و ۳",
    7: "۱و ۴",
    8: "۲ و ۳",
    9: "۲ و ۴",
    10: "۳ و ۴"
]

let months: [Int: String] = [
    1: "فروردین",
    2: "اردیبهشت",
    3: "خرداد",
    4: "تیر",
    5: "مرداد",
    6: "شهریور",
    7: "مهر",
    8: "آبان",
    9: "آذر",
    10: "دی",
    11: "بهمن",
    12: "اسفند",
]

public func questionAnswerToString(key: Int)-> String {
    return answers[key]!
}

public func monthToString(key: Int)-> String {
    return months[key]!
}

public func timesAgoTranslate(lang lang: String, key: String, params: Int...) -> String {
    if lang == "fa" {
        var result = "چند لحظه پیش"
        switch key {
        case "1_year_ago":
            result = "یک سال پیش"
        case "last_year":
            result = "پارسال"
        case "d_year_ago":
            result = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(params[0])!) سال پیش"
        case "1_month_ago":
            result = "یک ماه پیش"
        case "last_month":
            result = "ماه پیش"
        case "d_month_ago":
            result = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(params[0])!) ماه پیش"
        case "1_week_ago":
            result = "یک هفته پیش"
        case "last_week":
            result = "هفته پیش"
        case "d_week_ago":
            result = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(params[0])!) هفته پیش"
        case "1_day_ago":
            result = "یک روز پیش"
        case "last_day":
            result = "دیروز"
        case "d_day_ago":
            result = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(params[0])!) روز پیش"
        case "1_hour_ago":
            result = "یک ساعت پیش"
        case "last_hour":
            result = "یک ساعت پیش"
        case "d_hour_ago":
            result = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(params[0])!) ساعت پیش"
        case "1_minute_ago":
            result = "یک دقیقه پیش"
        case "last_minute":
            result = "یک دقیقه پیش"
        case "d_minute_ago":
            result = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(params[0])!) دقیقه پیش"
        case "d_second_ago":
            result = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(params[0])!) ثانبه پیش"
        default:
            break
        }
        return result
    }
    
    return ""
}
