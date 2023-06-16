//
//  EntranceStarredQuestionModel.swift
//  Concough
//
//  Created by Owner on 2017-01-19.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceStarredQuestionModel: Object {
    
    dynamic var question: EntranceQuestionModel?
    dynamic var created: NSDate = NSDate()
    dynamic var entranceUniqueId: String?
    dynamic var username: String = ""
}
