//
//  EntranceQuestionModelHandler.swift
//  Concough
//
//  Created by Owner on 2017-01-11.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceQuestionModelHandler {
    class func add(uniqueId uniqueId: String, number: Int, answer: Int, images: String, isDownloaded: Bool, entrance: EntranceModel) -> EntranceQuestionModel? {
        
        let question = EntranceQuestionModel()
        question.answer = answer
        question.entrance = entrance
        question.images = images
        question.isDownloaded = isDownloaded
        question.number = number
        question.uniqueId = uniqueId
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.add(question)
            })
            return question
        } catch(let error as NSError) {
            print("\(error)")
        }
        return nil
    }
    
    class func bulkDelete(list list: List<EntranceQuestionModel>) -> Bool {
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(list)
            })
        } catch (let error as NSError) {
            print("\(error)")
            return false
        }
        return true
    }
    
    class func changeDownloadedToTrue(uniqueId uniqueId: String, entranceId: String) {
        if let question = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionModel.self).filter("uniqueId = '\(uniqueId)' AND entrance.uniqueId = '\(entranceId)' AND isDownloaded = false").first {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    question.isDownloaded = true
                })
            } catch (let error as NSError) {
                print("\(error)")
            }
        }
    }
    
    class func getQuestions(entranceId uniqueId: String) -> Results<EntranceQuestionModel> {
        let questions = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionModel.self).filter("entrance.uniqueId = '\(uniqueId)'").sorted("number", ascending: true)
        
        return questions
    }

    class func countQuestions(entranceId uniqueId: String) -> Int {
        let count = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionModel.self).filter("entrance.uniqueId = '\(uniqueId)'").count
        
        return count
    }
    
    class func getStarredQuestions(entranceId uniqueId: String, questions: [String]) -> Results<EntranceQuestionModel> {
        let questions = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionModel.self).filter("entrance.uniqueId = '\(uniqueId)' AND uniqueId IN %@", questions).sorted("number", ascending: true)
        
        return questions
    }
    
    class func getQuestionById(entranceId uniqueId: String, questionId: String) -> EntranceQuestionModel? {
        let question = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionModel.self).filter("entrance.uniqueId = '\(uniqueId)' AND uniqueId = '\(questionId)'").first
        
        return question
    }
    
    class func getQuestionsNotDwonloaded(entranceId uniqueId: String) -> Results<EntranceQuestionModel> {
        let questions = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionModel.self).filter("entrance.uniqueId = '\(uniqueId)' AND isDownloaded = false").sorted("number", ascending: true)
        
        return questions
    }
}
