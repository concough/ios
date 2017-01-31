//
//  UserLogModelHandler.swift
//  Concough
//
//  Created by Owner on 2017-01-30.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class UserLogModelHandler {
    class func add(username username: String, uniqueId: String, created: NSDate, logType: String, extraData: JSON) -> Bool {
        let log = UserLogModel()
        log.created = created
        log.extraData = extraData.rawString()!
        log.isSynced = false
        log.logType = logType
        log.uniqueId = uniqueId
        log.username = username
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.add(log)
            })
            return true
        } catch(let error as NSError) {
            print("\(error)")
        }
        return false
    }
}
