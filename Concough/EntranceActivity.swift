//
//  EntranceActivity.swift
//  Concough
//
//  Created by Owner on 2016-11-09.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ConcoughActivity {
    var created: NSDate!
    var createdStr: String!
    var activityType: String!
    var target: JSON!
    
    init(created: NSDate, createdStr: String, activityType: String, target: JSON) {
        self.activityType = activityType
        self.created = created
        self.createdStr = createdStr
        self.target = target
    }
}