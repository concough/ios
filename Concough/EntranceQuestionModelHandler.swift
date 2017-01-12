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
}
