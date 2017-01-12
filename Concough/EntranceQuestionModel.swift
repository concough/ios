//
//  EntranceQuestionModel.swift
//  Concough
//
//  Created by Owner on 2017-01-11.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceQuestionModel: Object {
    dynamic var uniqueId: String = ""
    dynamic var number: Int = 0
    dynamic var answer: Int = 0
    dynamic var images: String = ""
    dynamic var isDownloaded: Bool = false
    dynamic var entrance: EntranceModel?
    
    let lesson = LinkingObjects(fromType: EntranceLessonModel.self, property: "questions")
    
    override static func primaryKey() -> String? {
        return "uniqueId"
    }
    
}
