//
//  EntranceBookletModel.swift
//  Concough
//
//  Created by Owner on 2017-01-11.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceBookletModel: Object {
    dynamic var uniqueId: String = ""
    dynamic var title: String = ""
    dynamic var lessonCount: Int = 0
    dynamic var duration: Int = 0
    dynamic var isOptional: Bool = false
    dynamic var order: Int = 0

    let entrance = LinkingObjects(fromType: EntranceModel.self, property: "booklets")
    let lessons = List<EntranceLessonModel>()
    
    override static func primaryKey() -> String? {
        return "uniqueId"
    }
}
