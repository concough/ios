//
//  PurchasedModelHandler.swift
//  Concough
//
//  Created by Owner on 2017-01-10.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class PurchasedModelHandler {
    class func add(id id: Int, username: String, isDownloaded: Bool, downloadTimes: Int, isImageDownlaoded: Bool, purchaseType: String, purchaseUniqueId: String, created: NSDate) -> Bool {
        
        let purchased = PurchasedModel()
        purchased.created = created
        purchased.id = id
        purchased.isDownloaded = isDownloaded
        purchased.productType = purchaseType
        purchased.productUniqueId = purchaseUniqueId
        purchased.username = username
        purchased.isImageDownloaded = isImageDownlaoded
        purchased.downloadTimes = downloadTimes
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.add(purchased, update: true)
            })
            return true
        } catch(let error as NSError) {
//            print("\(error)")
        }
        return false
    }
    
    class func removeById(username username: String, id: Int) -> Bool {
        let purchased = RealmSingleton.sharedInstance.DefaultRealm.objects(PurchasedModel.self).filter("username = '\(username)' AND id = \(id)").first
        
        if purchased != nil {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({ 
                    RealmSingleton.sharedInstance.DefaultRealm.delete(purchased!)
                })
            } catch (let error as NSError) {
//                print("\(error)")
                return false
            }
        }
        
        return true
    }
    
    class func setIsDownloadedTrue(productType pt: String, productId: String, username: String) -> Bool {
        if let purchase = self.getByProductId(productType: pt, productId: productId, username: username) {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({ 
                    purchase.isDownloaded = true
                    purchase.isImageDownloaded = true
                })
                return true
            } catch (let error as NSError) {
//                print("\(error)")
            }
        }
        return false
    }
    
    class func setIsLocalDBCreatedTrue(productType pt: String, productId: String, username: String) -> Bool {
        if let purchase = self.getByProductId(productType: pt, productId: productId, username: username) {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    purchase.isLocalDBCreated = true
                })
                return true
            } catch (let error as NSError) {
//                print("\(error)")
            }
        }
        return false
    }

    class func isInitialDataDownloaded(productType pt: String, productId: String, username: String) -> Bool {
        if let purchase = PurchasedModelHandler.getByProductId(productType: pt, productId: productId, username: username) {
            if purchase.isLocalDBCreated == true {
                return true
            }
        }
        
        return false
    }
    
    class func updateDownloadTimes(username username: String, id: Int, newDownloadTimes: Int) {
        if let item = PurchasedModelHandler.getByUsernameAndId(id: id, username: username) {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    item.downloadTimes = newDownloadTimes
                })
            } catch (let error as NSError) {
//                print("\(error)")
            }
        }
    }
    
    class func resetDownloadFlags(username username: String, id: Int) -> Bool {
        if let item = PurchasedModelHandler.getByUsernameAndId(id: id, username: username) {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    item.isDownloaded = false
                    item.isImageDownloaded = false
                    item.isLocalDBCreated = false
                })
                return true
            } catch (let error as NSError) {
//                print("\(error)")
            }
        }
        return false
    }
    
    class func getAllPurchased(username username: String) -> Results<PurchasedModel> {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(PurchasedModel.self).filter("username = '\(username)'").sorted("created", ascending: false)
        //.so
        return items
    }

    class func getAllPurchasedNotIn(username username: String, ids: [Int]) -> Results<PurchasedModel> {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(PurchasedModel.self).filter("username = '\(username)' AND NOT id IN %@", ids).sorted("created", ascending: false)
        return items
    }

    class func getAllPurchasedIn(username username: String, ids: [Int]) -> Results<PurchasedModel> {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(PurchasedModel.self).filter("username = '\(username)' AND id IN %@", ids).sorted("created", ascending: false)
        return items
    }

    class func getByUsernameAndId(id id: Int, username: String) -> PurchasedModel? {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(PurchasedModel.self).filter("username = '\(username)' AND id = \(id)").first
    }
    
    class func getByProductId(productType pt: String, productId: String, username: String) -> PurchasedModel? {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(PurchasedModel.self).filter("username = '\(username)' AND productType = '\(pt)' AND productUniqueId = '\(productId)'").first
    }
    
}
