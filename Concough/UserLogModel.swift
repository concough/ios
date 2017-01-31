//
//  UserLogModel.swift
//  Concough
//
//  Created by Owner on 2017-01-30.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class UserLogModel: Object {
    dynamic var uniqueId: String = ""
    dynamic var username: String = ""
    dynamic var created: NSDate = NSDate()
    dynamic var logType: String = ""
    dynamic var extraData: String = ""
    dynamic var isSynced: Bool = false
    
    override static func primaryKey() -> String? {
        return "uniqueId"
    }
}
