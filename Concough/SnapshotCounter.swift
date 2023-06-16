//
//  SnapshotCounter.swift
//  Concough
//
//  Created by Owner on 2018-01-12.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class SnapshotCounter: Object {
    dynamic var username: String = ""
    dynamic var productUniqueId: String = ""
    dynamic var productType: String = ""
    dynamic var snapshotCount: Int = 0
    dynamic var timeCreated: String = ""
    dynamic var blockTo: NSDate? = nil
    
}
