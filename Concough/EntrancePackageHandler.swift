//
//  EntrancePackageHandler.swift
//  Concough
//
//  Created by Owner on 2017-01-11.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class EntrancePackageHandler {
    class func savePackage(username username: String, entranceUniqueId: String, initData: JSON) -> (Bool, [String: String], [String: [(id: String, dl: Bool)]]) {
        
        var imagesList: [String: String] = [:]
        var qList: [String: [(id: String, dl: Bool)]] = [:]
        
        if let entrance = EntranceModelHandler.getByUsernameAndId(id: entranceUniqueId, username: username) {
            
            let bookletsArray = initData["entrance.booklets"].arrayValue
            for item in bookletsArray {
                let count = item["lessons.count"].intValue
                let title = item["title"].stringValue
                let duration = item["duration"].intValue
                let isOptional = item["is_optional"].boolValue
                let order = item["order"].intValue
                let uniqueId = NSUUID().UUIDString
                
                if let booklet = EntranceBookletModelHandler.add(uniqueId: uniqueId, title: title, lessonCount: count, duration: duration, isOptional: isOptional, order: order) {
                    
                    do {
                        try RealmSingleton.sharedInstance.DefaultRealm.write({
                            entrance.booklets.append(booklet)
                        })
                    } catch {
                        return (false, [:], [:])
                    }
                    
                    let lessonsArray = item["lessons"].arrayValue
                    for item2 in lessonsArray {
                        let fullTitle = item2["full_title"].stringValue
                        let qEnd = item2["q_end"].intValue
                        let ltitle = item2["title"].stringValue
                        let lduration = item2["duration"].intValue
                        let lorder = item2["order"].intValue
                        let qCount = item2["q_count"].intValue
                        let qStart = item2["q_start"].intValue
                        let lUniqueId = NSUUID().UUIDString
                        
                        if let lesson = EntranceLessonModelHandler.add(uniqueId: lUniqueId, title: ltitle, fullTitle: fullTitle, qStart: qStart, qEnd: qEnd, qCount: qCount, order: lorder, duration: lduration) {
                            
                            do {
                                try RealmSingleton.sharedInstance.DefaultRealm.write({
                                    booklet.lessons.append(lesson)
                                })
                            } catch {
                                return (false, [:], [:])
                            }
                            
                            let questionsArray = item2["questions"].arrayValue
                            for qitem in questionsArray {
                                let answer = qitem["answer_key"].intValue
                                let number = qitem["number"].intValue
                                let images = qitem["images"].rawString()!
                                let qUniqueId = NSUUID().UUIDString
                                
                                if let question = EntranceQuestionModelHandler.add(uniqueId: qUniqueId, number: number, answer: answer, images: images, isDownloaded: false, entrance: entrance) {
                                    
                                    do {
                                        try RealmSingleton.sharedInstance.DefaultRealm.write({
                                            lesson.questions.append(question)
                                        })
                                        
                                        // add to list for download
                                        if let imagesArray = JSON(data: images.dataUsingEncoding(NSUTF8StringEncoding)!).array {
                                            for item in imagesArray {
                                                let imageUniqueId = item["unique_key"].stringValue
                                                
                                                imagesList.updateValue(qUniqueId, forKey: imageUniqueId)
                                                if qList[qUniqueId] == nil {
                                                    qList[qUniqueId] = []
                                                }
                                                qList[qUniqueId]!.append((id: imageUniqueId, dl: false))
                                            }
                                        }
                                        
                                    } catch {
                                        return (false, [:], [:])
                                    }
                                } else {
                                    return (false, [:], [:])
                                }
                                
                            }
                        } else {
                            return (false, [:], [:])
                        }
                    }
                } else {
                    return (false, [:], [:])
                }
            }
            
        } else {
            return (false, [:], [:])
        }
        
        return (true, imagesList, qList)
    }
    
    class func removePackage(username username: String, entranceUniqueId: String) {
        if let entrance = EntranceModelHandler.getByUsernameAndId(id: entranceUniqueId, username: username) {
            
            let booklets = entrance.booklets
            for booklet in booklets {
                
                let lessons = booklet.lessons
                for lesson in lessons {
                    
                    do {
                        try RealmSingleton.sharedInstance.DefaultRealm.write({
                            RealmSingleton.sharedInstance.DefaultRealm.delete(lesson.questions)
                        })
                    } catch(let error as NSError) {
//                        print("\(error)")
                    }
                }
                
                do {
                    try RealmSingleton.sharedInstance.DefaultRealm.write({
                        RealmSingleton.sharedInstance.DefaultRealm.delete(lessons)
                    })
                } catch(let error as NSError) {
//                    print("\(error)")
                }
            }
            
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    RealmSingleton.sharedInstance.DefaultRealm.delete(booklets)
                })
            } catch(let error as NSError) {
//                print("\(error)")
            }
        }        
    }
    
}
