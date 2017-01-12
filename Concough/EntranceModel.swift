//
//  EntranceModel.swift
//  Concough
//
//  Created by Owner on 2017-01-10.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceModel: Object {
    dynamic var username: String = ""
    dynamic var uniqueId: String = ""
    dynamic var type: String = ""
    dynamic var organization: String = ""
    dynamic var group: String = ""
    dynamic var set: String = ""
    dynamic var setId: Int = 0
    dynamic var extraData: String = ""
    dynamic var bookletsCount: Int = 0
    dynamic var year: Int = 0
    dynamic var duration: Int = 0
    dynamic var lastPublished: NSDate = NSDate()
    
    let booklets = List<EntranceBookletModel>()
    
    override static func primaryKey() -> String? {
        return "uniqueId"
    }
}
