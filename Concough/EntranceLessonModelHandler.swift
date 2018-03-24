//
//  EntranceLessonModelHandler.swift
//  Concough
//
//  Created by Owner on 2017-01-11.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceLessonModelHandler {
    class func add(uniqueId uniqueId: String, title: String, fullTitle: String, qStart: Int, qEnd: Int, qCount: Int, order: Int, duration: Int) -> EntranceLessonModel? {
        
        let lesson = EntranceLessonModel()
        lesson.duration = duration
        lesson.fullTitle = fullTitle
        lesson.order = order
        lesson.qCount = qCount
        lesson.qEnd = qEnd
        lesson.qStart = qStart
        lesson.title = title
        lesson.uniqueId = uniqueId
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.add(lesson)
            })
            return lesson
        } catch(let error as NSError) {
//            print("\(error)")
        }
        return nil
    }
}
