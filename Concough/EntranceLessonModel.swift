//
//  EntranceLessonModel.swift
//  Concough
//
//  Created by Owner on 2017-01-11.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceLessonModel: Object {
    dynamic var uniqueId: String = ""
    dynamic var title: String = ""
    dynamic var fullTitle: String = ""
    dynamic var qStart: Int = 0
    dynamic var qEnd: Int = 0
    dynamic var qCount: Int = 0
    dynamic var order: Int = 0
    dynamic var duration: Int = 0

    let booklet = LinkingObjects(fromType: EntranceBookletModel.self, property: "lessons")
    let questions = List<EntranceQuestionModel>()
    
    override static func primaryKey() -> String? {
        return "uniqueId"
    }
    
}
