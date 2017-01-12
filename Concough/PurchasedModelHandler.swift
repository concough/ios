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
    class func add(id id: Int, username: String, isDownloaded: Bool, isImageDownlaoded: Bool, purchaseType: String, purchaseUniqueId: String, created: NSDate) -> Bool {
        
        let purchased = PurchasedModel()
        purchased.created = created
        purchased.id = id
        purchased.isDownloaded = isDownloaded
        purchased.productType = purchaseType
        purchased.productUniqueId = purchaseUniqueId
        purchased.username = username
        purchased.isImageDownloaded = isImageDownlaoded
        
        do {
            try RealmSingleton.sharedInstance.DefaultRealm.write({
                RealmSingleton.sharedInstance.DefaultRealm.add(purchased, update: true)
            })
            return true
        } catch(let error as NSError) {
            print("\(error)")
        }
        return false
    }
    
    class func removeById(username username: String, id: Int) -> Bool {
        let purchased = RealmSingleton.sharedInstance.DefaultRealm.objects(PurchasedModel.self).filter("username = \(username) AND id = \(id)").first
        
        if purchased != nil {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({ 
                    RealmSingleton.sharedInstance.DefaultRealm.delete(purchased!)
                })
            } catch (let error as NSError) {
                print("\(error)")
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
                })
                return true
            } catch (let error as NSError) {
                print("\(error)")
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
                print("\(error)")
            }
        }
        return false
    }
    
    class func getByUsernameAndId(id id: Int, username: String) -> PurchasedModel? {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(PurchasedModel.self).filter("username = \(username) AND id = \(id)").first
    }
    
    class func getByProductId(productType pt: String, productId: String, username: String) -> PurchasedModel? {
        return RealmSingleton.sharedInstance.DefaultRealm.objects(PurchasedModel.self).filter("username = \(username) AND productType = \(pt) AND productUniqueId = \(productId)").first
    }
}
