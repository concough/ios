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
    
    class func getAllLessons(username username: String) -> [EntranceLessonModel] {
        var items: [EntranceLessonModel] = []
        let entrances = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceModel.self).filter("username = '\(username)'")
        if entrances.count > 0 {
            for entrance in entrances {
                for booklet in entrance.booklets {
                    for lesson in booklet.lessons {
                        items.append(lesson)
                    }
                }
            }
        }
        return items
        
    }
    
    class func getOneLessonByTitleAndOrder(username username: String, entranceUniqueId: String, lessonTitle: String, lessonOrder: Int) -> EntranceLessonModel? {
        if let entrance = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceModel.self).filter("username = '\(username)' AND uniqueId = '\(entranceUniqueId)'").first {
            for booklet in entrance.booklets {
                for lesson in booklet.lessons {
                    if lesson.fullTitle == lessonTitle && lesson.order == lessonOrder {
                        return lesson
                    }
                }
            }
        }
        
        return nil
    }
}
