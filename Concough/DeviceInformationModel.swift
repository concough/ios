//
//  DeviceInformationModel.swift
//  Concough
//
//  Created by Owner on 2017-09-28.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation

import RealmSwift

class DeviceInformationModel: Object {
    dynamic var device_name: String = ""
    dynamic var device_model: String = ""
    dynamic var username: String = ""
    dynamic var state: Bool = true
    dynamic var isMe: Bool = false
    
    override static func primaryKey() -> String? {
        return "username"
    }
}
