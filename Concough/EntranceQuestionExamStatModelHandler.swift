//
//  EntranceQuestionExamStatModelHandler.swift
//  Concough
//
//  Created by Owner on 2018-04-07.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceQuestionExamStatModelHandler {
    class func update(username username: String, entranceUniqueId: String, questionNo: Int, answerState: Int) -> Bool {
        if let stat = EntranceQuestionExamStatModelHandler.getByNo(username: username, entranceUniqueId: entranceUniqueId, questionNo: questionNo) {
            
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    stat.updated = NSDate()
                    stat.totalCount += 1
                
                    switch answerState {
                    case 1:
                        stat.trueCount += 1
                    case 0:
                        stat.emptyCount += 1
                    case -1:
                        stat.falseCount += 1
                    default:
                        break
                    }
                    
                    stat.statData += ",\(answerState)"
                })
                return true
            } catch(let error as NSError) {
                //                print("\(error)")
            }
            
        } else {
            let stat = EntranceQuestionExamStatModel()
            stat.created = NSDate()
            stat.updated = NSDate()
            stat.totalCount = 1
            
            switch answerState {
            case 1:
                stat.trueCount = 1
            case 0:
                stat.emptyCount = 1
            case -1:
                stat.falseCount = 1
            default:
                break
            }
            
            stat.entranceUniqueId = entranceUniqueId
            stat.questionNo = questionNo
            stat.username = username
            stat.statData = "\(answerState)"
            
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    RealmSingleton.sharedInstance.DefaultRealm.add(stat)
                })
                return true
            } catch(let error as NSError) {
                //                print("\(error)")
            }
            
        }
        
        return false
    }
    
    class func getByNo(username username: String, entranceUniqueId: String, questionNo: Int) -> EntranceQuestionExamStatModel? {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionExamStatModel.self).filter("entranceUniqueId = '\(entranceUniqueId)' AND username = '\(username)' AND questionNo = \(questionNo)").first
    }
    
    class func removeAllStatsByEntranceId(username username: String, entranceUniqueId: String) -> Bool {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionExamStatModel.self).filter("entranceUniqueId = '\(entranceUniqueId)' AND username = '\(username)'")
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(items)
            })
            return true
        } catch(let error as NSError) {
            //            print("\(error)")
        }
        
        return false
    }
    
    class func removeAllStatsByUsername(username username: String) -> Bool {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionExamStatModel.self).filter("username = '\(username)'")
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(items)
            })
            return true
        } catch(let error as NSError) {
            //            print("\(error)")
        }
        
        return false
    }
    
    class func deleteAllStats() {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionExamStatModel.self)
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(items)
            })
        } catch(let error as NSError) {
            //            print("\(error)")
        }
        
    }
    
}
