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

public func questionAnswerToString(key: Int)-> String {
    return answers[key]!
}
