//
//  EntranceQuestionStarredModelHandler.swift
//  Concough
//
//  Created by Owner on 2017-01-20.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceQuestionStarredModelHandler {
    class func add(entranceUniqueId id: String, questionId: String, username: String) -> Bool {
        if EntranceQuestionStarredModelHandler.get(entranceUniqueId: id, questionId: questionId, username: username) != nil {
            return true
        }

        if let question = EntranceQuestionModelHandler.getQuestionById(entranceId: id, questionId: questionId, username: username) {
            let star = EntranceStarredQuestionModel()
            star.entranceUniqueId = id
            star.question = question
            star.username = username
            
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    RealmSingleton.sharedInstance.DefaultRealm.add(star)
                })
                return true
            } catch(let error as NSError) {
//                print("\(error)")
            }
        }
        return false
    }

    class func getStarredQuestions(entranceUniqueId id: String, username: String) -> Results<EntranceStarredQuestionModel> {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceStarredQuestionModel.self).filter("entranceUniqueId = '\(id)' AND username = '\(username)'")
    }
    
    class func remove(entranceUniqueId id: String, questionId: String, username: String) -> Bool {
        if let star = EntranceQuestionStarredModelHandler.get(entranceUniqueId: id, questionId: questionId, username: username) {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    RealmSingleton.sharedInstance.DefaultRealm.delete(star)
                })
                return true
            } catch(let error as NSError) {
//                print("\(error)")
            }
        }
        return false
    }
    
    class func get(entranceUniqueId id: String, questionId: String, username: String) -> EntranceStarredQuestionModel? {
        let item = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceStarredQuestionModel.self).filter("entranceUniqueId = '\(id)' AND question.uniqueId = '\(questionId)' AND username = '\(username)'").first
        return item
    }
    
    class func countByEntranceId(entranceUniqueId id: String, username: String) -> Int {
        return self.getStarredQuestions(entranceUniqueId: id, username: username).count
    }
    
    class func removeByEntranceId(entranceUniqueId id: String, username: String) -> Bool {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceStarredQuestionModel.self).filter("entranceUniqueId = '\(id)' AND username = '\(username)'")
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(items)
            })
        } catch (let error as NSError) {
//            print("\(error)")
            return false
        }
        
        return true
        
    }
    
}
