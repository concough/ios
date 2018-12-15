//
//  EntranceBookletModelHandler.swift
//  Concough
//
//  Created by Owner on 2017-01-11.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceBookletModelHandler {
    class func add(uniqueId uniqueId: String, title: String, lessonCount: Int, duration: Int, isOptional: Bool, order: Int) -> EntranceBookletModel? {
        let booklet = EntranceBookletModel()
        booklet.duration = duration
        booklet.isOptional = isOptional
        booklet.lessonCount = lessonCount
        booklet.order = order
        booklet.title = title
        booklet.uniqueId = uniqueId
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.add(booklet)
            })
            return booklet
        } catch(let error as NSError) {
//            print("\(error)")
        }
        return nil
    }
    
    class func getBookletsByEntranceId(uniqueId uniqueId: String, username: String) -> Results<EntranceBookletModel> {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceBookletModel.self).filter("entrance.uniqueId = '\(uniqueId)' AND entrance.username = '\(username)'").sorted("order", ascending: true)
        
        return items
    }
}
