//
//  EntranceLessonExamStruct.swift
//  Concough
//
//  Created by Owner on 2018-04-07.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation

struct EntranceLessonExamStructure {
    var title: String?
    var order: Int?
    var bookletOrder: Int?
    var started: NSDate?
    var finished: NSDate?
    var qCount: Int?
    var answers: [Int: Int] = [:]
    var trueAnswer: Int = 0
    var falseAnswer: Int = 0
    var noAnswer: Int = 0
    var withTime: Bool = false
    var duration: Int?
    var percentage: Double = 0.0
}
