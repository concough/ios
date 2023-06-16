//
//  EntranceQuestionCommentModelHandler.swift
//  Concough
//
//  Created by Owner on 2018-03-31.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class EntranceQuestionCommentModelHandler {
    class func add(entranceUniqueId entranceUniqueId: String, username: String, questionId: String, commentType: String, commentData: String) -> EntranceQuestionCommentModel? {
        
        if let question = EntranceQuestionModelHandler.getQuestionById(entranceId: entranceUniqueId, questionId: questionId, username: username) {
            
            let comment = EntranceQuestionCommentModel()
            comment.created = NSDate()
            comment.entranceUniqueId = entranceUniqueId
            comment.username = username
            comment.commentType = commentType
            comment.commentData = commentData
            comment.uniqueId = NSUUID().UUIDString
            comment.question = question
            
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    RealmSingleton.sharedInstance.DefaultRealm.add(comment)
                })
                return comment
            } catch(let error as NSError) {
                //            print("\(error)")
            }
        }
        
        
        return nil
    }
    
    class func getAllComments(entranceUniqueId entranceUniqueId: String, questionId: String, username: String) -> Results<EntranceQuestionCommentModel> {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionCommentModel.self).filter("username = '\(username)' AND entranceUniqueId = '\(entranceUniqueId)' AND question.uniqueId = '\(questionId)'").sorted("created", ascending: false)
    }
    
    class func getLastComment(entranceUniqueId entranceUniqueId: String, questionId: String, username: String) -> EntranceQuestionCommentModel? {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionCommentModel.self).filter("username = '\(username)' AND entranceUniqueId = '\(entranceUniqueId)' AND question.uniqueId = '\(questionId)'").sorted("created", ascending: false).first
    }
    
    class func getCommentsCount(entranceUniqueId entranceUniqueId: String, questionId: String, username: String) -> Int {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionCommentModel.self).filter("username = '\(username)' AND entranceUniqueId = '\(entranceUniqueId)' AND question.uniqueId = '\(questionId)'").count
    }
    
    class func removeOneComment(username username: String, commentId: String) -> Bool {
        let comment = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionCommentModel.self).filter("username = '\(username)' AND uniqueId = '\(commentId)'").first
        
        if comment != nil {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    RealmSingleton.sharedInstance.DefaultRealm.delete(comment!)
                })
            } catch (let error as NSError) {
                //                print("\(error)")
                return false
            }
        }
        
        return true
    }
    
    class func removeAllCommentOfEnrance(entranceUniqueId entranceUniqueId: String, username: String) -> Bool {
        let comments = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionCommentModel.self).filter("username = '\(username)' AND entranceUniqueId = '\(entranceUniqueId)'")
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(comments)
            })
        } catch (let error as NSError) {
            //                print("\(error)")
            return false
        }
        
        return true
    }

    class func removeAllCommentOfUsername(username username: String) -> Bool {
        let comments = RealmSingleton.sharedInstance.DefaultRealm.objects(EntranceQuestionCommentModel.self).filter("username = '\(username)'")
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.delete(comments)
            })
        } catch (let error as NSError) {
            //                print("\(error)")
            return false
        }
        
        return true
    }

}
