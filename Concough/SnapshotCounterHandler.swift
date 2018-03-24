//
//  SnapshotCounterHandler.swift
//  Concough
//
//  Created by Owner on 2018-01-12.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class SnapshotCounterHandler {
    class func add(username username: String, productUniqueId: String, productType: String, timeCreated: String) -> Bool {
        
        let counter = SnapshotCounter()
        counter.productType = productType
        counter.productUniqueId = productUniqueId
        counter.snapshotCount = 0
        counter.timeCreated = timeCreated
        counter.username = username
     
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({ 
                RealmSingleton.sharedInstance.DefaultRealm.add(counter)
            })
            return true
        } catch(let  exc as NSError) {
//            print(exc)
        }
        
        return false
    }
    
    class func countUpAndCheck(username username: String, productUniqueId: String, productType: String, time: String) -> (Bool, Bool) {
        if let counter = SnapshotCounterHandler.getByUsernameAndProductId(username: username, productUniqueId: productUniqueId, productType: productType) {
            
            do {
                var count = counter.snapshotCount
                if counter.timeCreated == time {
                    count += 1
                } else {
                    count = 1
                }
                
                var blocked_to: NSDate? = nil
                var must_blocked = false
                if count >= 3 {
                    blocked_to = NSDate().dateByAddingTimeInterval(3600 * 24 * 3)
                    must_blocked = true
                }
                
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    counter.snapshotCount = count
                    counter.blockTo = blocked_to
                    counter.timeCreated = time
                })
                
                return (true, must_blocked)
                
            } catch ( _ as NSError) {
                
            }
        } else {
            let result = SnapshotCounterHandler.add(username: username, productUniqueId: productUniqueId, productType: productType, timeCreated: time)
            return (result, false)
        }
        
        return (false, false)
    }

    class func getByUsernameAndProductId(username username: String, productUniqueId: String, productType: String) -> SnapshotCounter? {

        return RealmSingleton.sharedInstance.DefaultRealm.objects(SnapshotCounter.self).filter("username = '\(username)' AND productUniqueId = '\(productUniqueId)' AND productType = '\(productType)'").first
    }
    
    class func deleteAllValue() {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(SnapshotCounter.self)
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(items)
            })
        } catch(_ as NSError) {
            
        }
    }
}
