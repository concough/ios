//
//  EntranceOpenedCount.swift
//  Concough
//
//  Created by Owner on 2017-01-20.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceOpenedCountModel: Object {
    dynamic var entranceUniqueId: String = ""
    dynamic var count: Int = 1
    dynamic var type: String = ""
    dynamic var username: String = ""
}
