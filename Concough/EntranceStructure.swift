//
//  EntranceStructure.swift
//  Concough
//
//  Created by Owner on 2017-01-03.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import SwiftyJSON

struct EntranceStructure: Any {
    var entranceTypeTitle: String?
    var entranceOrgTitle: String?
    var entranceGroupTitle: String?
    var entranceSetTitle: String?
    var entranceSetId: Int?
    var entranceExtraData: JSON?
    var entranceBookletCounts: Int?
    var entranceYear: Int?
    var entranceMonth: Int?
    var entranceDuration: Int?
    var entranceUniqueId: String?
    var entranceLastPublished: NSDate?
}
