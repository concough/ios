//
//  EntranceLessonExamModel.swift
//  Concough
//
//  Created by Owner on 2018-04-07.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceLessonExamModel: Object {
    dynamic var uniqueId: String = ""
    dynamic var username: String = ""
    dynamic var entranceUniqueId: String = ""
    dynamic var lessonTitle: String = ""
    dynamic var lessonOrder: Int = 0
    dynamic var bookletOrder: Int = 0
    dynamic var startedDate: NSDate = NSDate()
    dynamic var finishedDate: NSDate = NSDate()
    dynamic var withTime: Bool = false
    dynamic var questionCount: Int = 0
    dynamic var trueAnswer: Int = 0
    dynamic var falseAnswer: Int = 0
    dynamic var noAnswer: Int = 0
    dynamic var created: NSDate = NSDate()
    dynamic var examDuration: Int = 0
    dynamic var examData: String = ""
    dynamic var percentage: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "uniqueId"
    }
}
