//
//  EntranceLastVisitInfoModel.swift
//  Concough
//
//  Created by Owner on 2018-03-29.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceLastVisitInfoModel: Object {
    dynamic var username: String = ""
    dynamic var entranceUniqueId: String = ""
    dynamic var updated: NSDate = NSDate()
    dynamic var bookletIndex: Int = 0
    dynamic var lessonIndex: Int = 0
    dynamic var index: String = ""
    dynamic var showType: String = ""
}
