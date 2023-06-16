//
//  EntranceOpenedCountModelHandler.swift
//  Concough
//
//  Created by Owner on 2017-01-20.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation

class EntranceOpenedCountModelHandler {
    class func update(entranceUniqueId id: String, type: String, username: String) -> Bool {
        if let record = EntranceOpenedCountModelHandler.getByType(entranceUniqueId: id, type: type, username: username) {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    record.count += 1
                })
                return true
            } catch(let error as NSError) {
//                print("\(error)")
            }
            
        } else {
            // No Record Exist
            let record = EntranceOpenedCountModel()
            record.entranceUniqueId = id
            record.type = type
            record.count = 1
            record.username = username

            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    RealmSingleton.sharedInstance.DefaultRealm.add(record)
                })
                return true
            } catch(let error as NSError) {
//                print("\(error)")
            }
        }
        return false
    }
    
    class func getByType(entranceUniqueId id: String, type: String, username: String) -> EntranceOpenedCountModel? {
        let item = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceOpenedCountModel.self).filter("entranceUniqueId = '\(id)' AND type = '\(type)' AND username = '\(username)'").first
        return item
    }
    
    class func countByEntranceId(entranceUniqueId id: String, username: String) -> Int {
        let totalCount = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceOpenedCountModel.self).filter("entranceUniqueId = '\(id)' AND username = '\(username)'").reduce(0) { (total, item)  in
            return total + item.count
        }
        return totalCount
    }
    
    class func removeByEntranceId(entranceUniqueId id: String, username: String) -> Bool {
        let eopened = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceOpenedCountModel.self).filter("entranceUniqueId = '\(id)' AND username = '\(username)'")
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(eopened)
            })
        } catch (let error as NSError) {
//            print("\(error)")
            return false
        }
        
        return true
        
    }
}
