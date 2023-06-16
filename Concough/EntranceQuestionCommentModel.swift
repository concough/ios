//
//  EntranceQuestionCommentModel.swift
//  Concough
//
//  Created by Owner on 2018-03-31.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceQuestionCommentModel: Object {
    dynamic var uniqueId: String = ""
    dynamic var question: EntranceQuestionModel?
    dynamic var created: NSDate = NSDate()
    dynamic var entranceUniqueId: String?
    dynamic var username: String = ""
    dynamic var commentType: String = ""
    dynamic var commentData: String = ""
    
    override static func primaryKey() -> String? {
        return "uniqueId"
    }
}
