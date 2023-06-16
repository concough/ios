//
//  EntranceLastVisitInfoModelHandler.swift
//  Concough
//
//  Created by Owner on 2018-03-29.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceLastVisitInfoModelHandler {
    class func update(username username: String, uniqueId: String, bookletIndex: Int, lessonIndex: Int, index: String, updated: NSDate, showType: String) -> Bool {
        
        if let elv = EntranceLastVisitInfoModelHandler.get(username: username, uniqueId: uniqueId, showType: showType) {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    elv.bookletIndex = bookletIndex
                    elv.lessonIndex = lessonIndex
                    elv.index = index
                    elv.updated = updated
                })
                return true
            } catch (let error as NSError) {
                //                print("\(error)")
            }
        } else {
            let elv = EntranceLastVisitInfoModel()
            elv.username = username
            elv.entranceUniqueId = uniqueId
            elv.bookletIndex = bookletIndex
            elv.lessonIndex = lessonIndex
            elv.index = index
            elv.updated = updated
            elv.showType = showType
            
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    RealmSingleton.sharedInstance.DefaultRealm.add(elv)
                })
                
                return true
            } catch (let error as NSError) {
                //            print("\(error)")
            }
            
        }
        
        return false
    }
    
    class func get(username username: String, uniqueId: String, showType: String) -> EntranceLastVisitInfoModel? {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceLastVisitInfoModel.self).filter("username = '\(username)' AND entranceUniqueId = '\(uniqueId)' AND showType = '\(showType)'").first
    }
    
    class func removeByEntranceId(username username: String, uniqueId: String) -> Bool {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceLastVisitInfoModel.self).filter("username = '\(username)' AND entranceUniqueId = '\(uniqueId)'")
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(items)
            })
        } catch (let error as NSError) {
            //                print("\(error)")
            return false
        }
        
        return true
    }
}
