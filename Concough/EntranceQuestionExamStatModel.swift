//
//  EntranceQuestionExamStatModel.swift
//  Concough
//
//  Created by Owner on 2018-04-07.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceQuestionExamStatModel: Object {
    dynamic var username: String = ""
    dynamic var entranceUniqueId: String = ""
    dynamic var questionNo: Int = 0
    dynamic var totalCount: Int = 0
    dynamic var trueCount: Int = 0
    dynamic var falseCount: Int = 0
    dynamic var emptyCount: Int = 0
    dynamic var created: NSDate = NSDate()
    dynamic var updated: NSDate = NSDate()
    dynamic var statData: String = ""    
}
