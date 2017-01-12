//
//  PurchasedModel.swift
//  Concough
//
//  Created by Owner on 2017-01-10.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class PurchasedModel: Object {
    dynamic var id: Int = 0
    dynamic var username: String = ""
    dynamic var isDownloaded: Bool = false
    dynamic var isImageDownloaded: Bool = false
    dynamic var isLocalDBCreated: Bool = false
    dynamic var productType: String = "Entrance"
    dynamic var productUniqueId: String = ""
    dynamic var created: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
