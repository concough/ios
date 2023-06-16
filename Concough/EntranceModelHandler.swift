//
//  EntranceModelHandler.swift
//  Concough
//
//  Created by Owner on 2017-01-10.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceModelHandler {
    class func add(entrance e: EntranceStructure, username: String) -> Bool {
        let entrance = EntranceModel()
        entrance.bookletsCount = e.entranceBookletCounts!
        entrance.duration = e.entranceDuration!
        entrance.extraData = e.entranceExtraData!.rawString()!
        entrance.group = e.entranceGroupTitle!
        entrance.lastPublished = e.entranceLastPublished!
        entrance.organization = e.entranceOrgTitle!
        entrance.set = e.entranceSetTitle!
        entrance.setId = e.entranceSetId!
        entrance.type = e.entranceTypeTitle!
        entrance.uniqueId = e.entranceUniqueId!
        entrance.year = e.entranceYear!
        entrance.month = e.entranceMonth!
        entrance.username = username
        entrance.pUniqueId = "\(username)-\(NSUUID().UUIDString.lowercaseString)"
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({ 
                RealmSingleton.sharedInstance.DefaultRealm.add(entrance, update: true)
            })
            
            return true
        } catch (let error as NSError) {
//            print("\(error)")
        }
        return false
    }
    
    class func existById(id id: String, username: String) -> Bool {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceModel).filter("username = '\(username)' AND uniqueId = '\(id)'")
        if items.count > 0 {
            return true
        }
        
        return false
    }
    
    class func getByUsernameAndId(id id: String, username: String) -> EntranceModel? {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceModel.self).filter("username = '\(username)' AND uniqueId = '\(id)'")
        if items.count > 0 {
            return items.first
        }
        return nil
    }
    
    class func correctMonthOfEntrance(id id: String, username: String, month: Int) -> Bool {
        if let entrance = EntranceModelHandler.getByUsernameAndId(id: id, username: username) {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({ 
                    entrance.month = month
                })
                return true
            } catch(let error as NSError) {
                
            }
        }
        
        return false
    }
    
    class func removeById(id id: String, username: String) -> Bool {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceModel.self).filter("username = '\(username)' AND uniqueId = '\(id)'")
        
        if items.count > 0 {
            let entrance = items.first
            if entrance != nil {
                do {
                    try RealmSingleton.sharedInstance.DefaultRealm.write({
                        RealmSingleton.sharedInstance.DefaultRealm.delete(entrance!)
                    })
                    
                } catch(let error as NSError) {
//                    print("\(error)")
                    return false
                }
            }
        }
        return true
    }
}
