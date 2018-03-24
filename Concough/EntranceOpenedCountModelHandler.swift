//
//  EntranceOpenedCountModelHandler.swift
//  Concough
//
//  Created by Owner on 2017-01-20.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation

class EntranceOpenedCountModelHandler {
    class func update(entranceUniqueId id: String, type: String) -> Bool {
        if let record = EntranceOpenedCountModelHandler.getByType(entranceUniqueId: id, type: type) {
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
    
    class func getByType(entranceUniqueId id: String, type: String) -> EntranceOpenedCountModel? {
        let item = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceOpenedCountModel.self).filter("entranceUniqueId = '\(id)' AND type = '\(type)'").first
        return item
    }
    
    class func countByEntranceId(entranceUniqueId id: String) -> Int {
        let totalCount = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceOpenedCountModel.self).filter("entranceUniqueId = '\(id)'").reduce(0) { (total, item)  in
            return total + item.count
        }
        return totalCount
    }
    
    class func removeByEntranceId(entranceUniqueId id: String) -> Bool {
        let eopened = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceOpenedCountModel.self).filter("entranceUniqueId = '\(id)'")
        
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
