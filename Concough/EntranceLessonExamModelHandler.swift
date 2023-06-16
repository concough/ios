//
//  EntranceLessonExamModelHandler.swift
//  Concough
//
//  Created by Owner on 2018-04-07.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceLessonExamModelHandler {
    class func add(username username: String, entrancedUniqueId: String, examStruct: EntranceLessonExamStructure, created: NSDate, data: String) -> Bool {
        
        let exam = EntranceLessonExamModel()
        exam.username = username
        exam.entranceUniqueId = entrancedUniqueId
        exam.uniqueId = NSUUID().UUIDString
        exam.created = created
        exam.falseAnswer = examStruct.falseAnswer
        exam.finishedDate = examStruct.finished!
        exam.lessonOrder = examStruct.order!
        exam.lessonTitle = examStruct.title!
        exam.noAnswer = examStruct.noAnswer
        exam.questionCount = examStruct.qCount!
        exam.startedDate = examStruct.started!
        exam.trueAnswer = examStruct.trueAnswer
        exam.withTime = examStruct.withTime
        exam.examDuration = examStruct.duration!
        exam.examData = data
        exam.percentage = examStruct.percentage
        exam.bookletOrder = examStruct.bookletOrder!
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.add(exam)
            })
            return true
        } catch(let error as NSError) {
            //            print("\(error)")
        }
        
        return false
    }
    
    class func getLastExam(username username: String, entranceUniqueId: String, lessonTitle: String, lessonOrder: Int, bookletOrder: Int) -> EntranceLessonExamModel? {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceLessonExamModel.self).filter("entranceUniqueId = '\(entranceUniqueId)' AND username = '\(username)' AND lessonTitle = '\(lessonTitle)' AND lessonOrder = \(lessonOrder) AND bookletOrder = \(bookletOrder)").sorted("created", ascending: false).first
    }
    
    class func getAllExam(username username: String, entranceUniqueId: String, lessonTitle: String, lessonOrder: Int, bookletOrder: Int,  limit: Int?) -> Results<EntranceLessonExamModel> {
        
        return RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceLessonExamModel.self).filter("entranceUniqueId = '\(entranceUniqueId)' AND username = '\(username)' AND lessonTitle = '\(lessonTitle)' AND lessonOrder = \(lessonOrder) AND bookletOrder = \(bookletOrder)").sorted("created", ascending: false)
    }
    
    class func getExamsCount(username username: String, entranceUniqueId: String, lessonTitle: String, lessonOrder: Int, bookletOrder: Int) -> Int {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceLessonExamModel.self).filter("entranceUniqueId = '\(entranceUniqueId)' AND username = '\(username)' AND lessonTitle = '\(lessonTitle)' AND lessonOrder = \(lessonOrder) AND bookletOrder = \(bookletOrder)").count
    }
    
    class func getPercentageSum(username username: String, entranceUniqueId: String, lessonTitle: String, lessonOrder: Int, bookletOrder: Int) -> Double {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceLessonExamModel.self).filter("entranceUniqueId = '\(entranceUniqueId)' AND username = '\(username)' AND lessonTitle = '\(lessonTitle)' AND lessonOrder = \(lessonOrder) AND bookletOrder = \(bookletOrder)").sum("percentage")
    }
    
    class func removeAllExamsByEntranceId(username username: String, entranceUniqueId: String) -> Bool {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceLessonExamModel.self).filter("entranceUniqueId = '\(entranceUniqueId)' AND username = '\(username)'")
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(items)
            })
        } catch(let error as NSError) {
            //            print("\(error)")
            return false
        }

        return true
    }
    
    class func removeAllExamsByUsername(username username: String) -> Bool {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceLessonExamModel.self).filter("username = '\(username)'")
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(items)
            })
        } catch(let error as NSError) {
            //            print("\(error)")
            return false
        }
        
        return true
    }
    
    class func deleteAllExams() {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceLessonExamModel.self)
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(items)
            })
        } catch(let error as NSError) {
            //            print("\(error)")
        }

    }
}
