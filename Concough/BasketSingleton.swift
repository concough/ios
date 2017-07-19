//
//  BasketSingleton.swift
//  Concough
//
//  Created by Owner on 2017-01-03.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import MBProgressHUD

class BasketSingleton {
    static let sharedInstance = BasketSingleton()
    
    private let _lock: NSLock!
    private var _queue: NSOperationQueue
    private var _basketId: String? = nil
    private var _totalCost: Int = 0
    private var _sales: [(id: Int, created: NSDate, cost: Int, target: Any, type: String)] = []
    
    private init() {
        self._queue = NSOperationQueue()
        self._lock = NSLock()
    }
    
    // MARK: - Properties
    internal var BasketId: String? {
        get {
            return self._basketId
        }
        set {
            self._basketId = newValue
        }
    }
    
    internal var SalesCount: Int {
        get {
            return self._sales.count
        }
    }
    
    internal var TotalCost: Int {
        get {
            return self._totalCost
        }
    }
    
    // MARK: - Functions
    internal func loadBasketItems(viewController viewController: UIViewController, completion: ((count: Int) -> ())?) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            if let vc = viewController as? BasketCheckoutTableViewController {
                vc.loading = AlertClass.showLoadingMessage(viewController: viewController)
            }
        }
        BasketRestAPIClass.loadBasketItems({ (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if let vc = viewController as? BasketCheckoutTableViewController {
                    AlertClass.hideLoaingMessage(progressHUD: vc.loading)
                }
            }
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.loadBasketItems(viewController: viewController, completion: completion)
                } else {
                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
                }
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            let basket_uid = localData["basket_uid"].stringValue
                            self._basketId = basket_uid
                            
                            if localData["records"] != nil {
                                let records = localData["records"]
                                
                                var localSales:[(id: Int, created: NSDate, cost: Int, target: Any, type: String)] = []
                                var localCost: Int = 0
                                
                                for (_, item) in records {
                                    let sale_id = item["id"].intValue
                                    let cost = item["pay_amount"].intValue
                                    let created_str = item["created"].stringValue
                                    let created = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(created_str)!
                                    
                                    // lets creat target
                                    let target = item["target"]
                                    let product_type = target["product_type"].stringValue
                                    
                                    if product_type == "Entrance" {
                                        var entrance = EntranceStructure()
                                        entrance.entranceBookletCounts = target["booklets_count"].intValue
                                        entrance.entranceDuration = target["duration"].intValue
                                        entrance.entranceExtraData = JSON(data: target["extra_data"].stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
                                        entrance.entranceGroupTitle = target["entrance_set"]["group"]["title"].stringValue
                                        entrance.entranceLastPublished = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(target["last_published"].stringValue)
                                        entrance.entranceOrgTitle = target["organization"]["title"].stringValue
                                        entrance.entranceSetId = target["entrance_set"]["id"].intValue
                                        entrance.entranceSetTitle = target["entrance_set"]["title"].stringValue
                                        entrance.entranceTypeTitle = target["entrance_type"]["title"].stringValue
                                        entrance.entranceUniqueId = target["unique_key"].stringValue
                                        entrance.entranceYear = target["year"].intValue
                                        
                                        localCost += cost
                                        localSales.append((id: sale_id, created: created, cost: cost, target: entrance, type: "Entrance"))
                                    }
                                }
                                synchronized(self._lock, criticalSection: { 
                                    self._sales = localSales
                                    self._totalCost = localCost
                                })
                            }
                            if let compl = completion {
                                compl(count: self._sales.count)
                            }
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    if let compl = completion {
                                        compl(count: 0)
                                    }
                                default:
                                    break
//                                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "ErrorResult", messageSubType: errorType, completion: {
//
//                                        if let compl = completion {
//                                            compl(count: 0)
//                                        }
//                                    })
                                }
                            }
                            
                        default:
                            break
                        }
                    }
                }
            }
            
            // In Any Way completes
            
        }) { (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if let vc = viewController as? BasketCheckoutTableViewController {
                    AlertClass.hideLoaingMessage(progressHUD: vc.loading)
                }
            }
            
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    fallthrough
                case .HostUnreachable:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    })
                    
//                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                        let operation = NSBlockOperation(block: {
//                            self.loadBasketItems(viewController: viewController, completion: completion)
//                        })
//                        self._queue.addOperation(operation)
//                    })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
//                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                }
            }
            
        }
    }
    
    internal func createBasket(viewController viewController: UIViewController, completion: (() -> ())?) {
        BasketRestAPIClass.createBasket({ (data, error) in
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.createBasket(viewController: viewController, completion: completion)
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                    })
                }
                
//                AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            if let basket_id = localData["basket_uid"].string {
                                self._basketId = basket_id
                                if let compl = completion {
                                    compl()
                                }
                            }
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "RemoteDBError":
                                    fallthrough
                                default:
                                    break
//                                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                            
                        default:
                            break
                        }
                    }
                }
            }
        }) { (error) in
            if let err = error {
                switch err {
                case .HostUnreachable:
                    fallthrough
                case .NoInternetAccess:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    })
                    
//                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                        let operation = NSBlockOperation(block: {
//                            self.createBasket(viewController: viewController, completion: completion)
//                        })
//                        self._queue.addOperation(operation)
//                    })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
                    
//                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                }
            }
            
        }
    }
    
    internal func addSale(saleId saleId: Int, created: NSDate, cost: Int, target: Any, type: String) {
        synchronized(self._lock, criticalSection: {
            var product_id: String? = nil
            if type == "Entrance" {
                if let entrance = target as? EntranceStructure {
                    product_id = entrance.entranceUniqueId!
                    
                    if self.findSaleByTargetId(targetId: product_id!, type: type) != nil {
                        return
                    } else {
                        self._sales.append((id: saleId, created: created, cost: cost, target: target, type: type))
                        self._totalCost += cost
                    }
                }
            }
        })
    }

    internal func addSale(viewController viewController: UIViewController, target: Any, type: String, completion: ((count: Int) -> ())?) {
        var product_id: String? = nil
        if type == "Entrance" {
            if let entrance = target as? EntranceStructure {
                product_id = entrance.entranceUniqueId!
                
                if self.findSaleByTargetId(targetId: product_id!, type: type) != nil {
                    return
                }
            }
        }
        if product_id != nil {
                BasketRestAPIClass.addProductToBasket(basketId: self._basketId!, productId: product_id!, productType: type, completion: { (data, error) in
                    if error != HTTPErrorType.Success {
                        if error == HTTPErrorType.Refresh {
                            self.addSale(viewController: viewController, target: target, type: type, completion: completion)
                        } else {
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                AlertClass.showTopMessage(viewController: viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                            })
                        }
                        
//                        AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
                    } else {
                        if let localData = data {
                            if let status = localData["status"].string {
                                switch status {
                                case "OK":
                                    let basket_id = localData["basket_uid"].stringValue
                                    if basket_id == self._basketId {
                                        if localData["records"] != nil {
                                            let sale = localData["records"]
                                            let cost = sale["pay_amount"].intValue
                                            let sale_id = sale["id"].intValue
                                            let target_product_unique_key = sale["target"]["unique_key"].stringValue
                                            let target_product_type = sale["target"]["sale_type"].stringValue
                                            
                                            let created_str = sale["created"].stringValue
                                            let created = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(created_str)!
                                            
                                            if target_product_unique_key == product_id! && target_product_type == type {
                                                // ok save it to local db
                                                synchronized(self._lock, criticalSection: {
                                                    self._sales.append((id: sale_id, created: created, cost: cost, target: target, type: type))
                                                    self._totalCost += cost
                                                })
                                                
                                                // notify upper class
                                                if let compl = completion {
                                                    compl(count: self._sales.count)
                                                }
                                            }
                                        }
                                    }
                                case "Error":
                                    if let errorType = localData["error_type"].string {
                                        switch errorType {
                                        case "DuplicateSale":
                                            // what i must doing here --> must user refresh table view --> for now show alert
                                            AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "BasketResult", messageSubType: errorType, completion: {
                                                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                                    // refresh sales here
                                                })
                                            })
                                            
                                        case "EntranceNotExist":
                                            AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "EntranceResult", messageSubType: errorType, completion: nil)
                                            break
                                        case "BadData":
                                            fallthrough
                                        case "RemoteDBError":
                                            fallthrough
                                        default:
                                            AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                        }
                                    }
                                    
                                default:
                                    break
                                }
                            }
                        }
                    }
                }, failure: { (error) in
                    if let err = error {
                        switch err {
                        case .HostUnreachable:
                            fallthrough
                        case .NoInternetAccess:
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                AlertClass.showTopMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                            })
                            
//                            AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                                let operation = NSBlockOperation(block: {
//                                    self.addSale(viewController: viewController, target: target, type: type, completion: completion)
//                                })
//                                self._queue.addOperation(operation)
//                            })
                        default:
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                AlertClass.showTopMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                            })
//                            AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                        }
                    }
                        
                })
        }
    }

    private func getSaleTypeById(saleId saleId: Int) -> String? {
        var local: String? = nil
        synchronized(self._lock, criticalSection: {
            for item in self._sales {
                if item.id == saleId {
                    local = item.type
                }
            }
        })
        return local
    }
    
    internal func getSaleById(saleId saleId: Int) -> Any? {
        var local: Any? = nil
        synchronized(self._lock, criticalSection: {
            for item in self._sales {
                if item.id == saleId {
                    local = item.target
                }
            }
        })
        return local
    }
    
    internal func getSaleByIndex(index index: Int) -> Any? {
        var local: Any? = nil
        synchronized(self._lock, criticalSection: {
            if index < self._sales.count {
                local = self._sales[index]
            }
        })
        return local
    }
    
    internal func removeSaleById(viewController viewController: UIViewController, saleId: Int, completion: ((count: Int) -> ())?) {
        if self.findSaleById(saleId: saleId) != nil {
            BasketRestAPIClass.removeSaleFormBasket(basketId: self._basketId!, saleId: saleId, completion: { (data, error) in
                if error != HTTPErrorType.Success {
                    if error == HTTPErrorType.Refresh {
                        self.removeSaleById(viewController: viewController, saleId: saleId, completion: completion)
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                        })
                    }
//                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
                } else {
                    if let localData = data {
                        if let status = localData["status"].string {
                            switch status {
                            case "OK":
                                synchronized(self._lock, criticalSection: { 
                                    self.removeSaleById(saleId: saleId)
                                })
                                
                                
                                if let compl = completion {
                                    compl(count: self._sales.count)
                                }
                            case "Error":
                                if let errorType = localData["error_type"].string {
                                    switch errorType {
                                    case "SaleNotExist":
                                        AlertClass.showTopMessage(viewController: viewController, messageType: "BasketResult", messageSubType: errorType, type: "error", completion: nil)
//                                        AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "BasketResult", messageSubType: errorType, completion: nil)
                                    case "RemoteDBError":
                                        fallthrough
                                    default:
                                        break
//                                        AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                    }
                                }
                                
                            default:
                                break
                            }
                        }
                    }
                }
            }, failure: { (error) in
                if let err = error {
                    switch err {
                    case .HostUnreachable:
                        fallthrough
                    case .NoInternetAccess:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                        })
                        
//                        AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                            let operation = NSBlockOperation(block: {
//                                self.removeSaleById(viewController: viewController, saleId: saleId, completion: completion)
//                            })
//                            self._queue.addOperation(operation)
//                        })
                    default:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                        })
//                        AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                    }
                }
                
            })
        }
    }

    internal func checkout(viewController viewController: UIViewController, completion: ((count: Int, purchased: [Int: (Int, Int, NSDate)]?) -> ())?) {
            BasketRestAPIClass.checkoutBasket(basketId: self._basketId!, completion: { (data, error) in
                if error != HTTPErrorType.Success {
                    if error == HTTPErrorType.Refresh {
                        self.checkout(viewController: viewController, completion: completion)
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                        })
                    }
                    
//                    AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "HTTPError", messageSubType: (error?.toString())!, completion: nil)
                } else {
                    if let localData = data {
                        if let status = localData["status"].string {
                            switch status {
                            case "OK":
                                if let purchased = localData["purchased"].array {
                                    
                                    let username: String? = UserDefaultsSingleton.sharedInstance.getUsername()
                                    var localPurchased: [Int: (Int, Int, NSDate)] = [:]
                                    for item in purchased {
                                        let saleId = item["sale_id"].intValue
                                        let purchaseId = item["purchase_id"].intValue
                                        let downloaded = item["downloaded"].intValue
                                        
                                        let purchased_time_str = item["purchase_time"].stringValue
                                        let purchasedTime = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(purchased_time_str)!
                                        
                                        // Update Realm Db
                                        if let saleType = self.getSaleTypeById(saleId: saleId) {
                                            if saleType == "Entrance" {
                                                let entrance = self.getSaleById(saleId: saleId) as! EntranceStructure
                                                if EntranceModelHandler.add(entrance: entrance, username: username!) == true {
                                                    if PurchasedModelHandler.add(id: purchaseId, username: username!, isDownloaded: false, downloadTimes: downloaded, isImageDownlaoded: false, purchaseType: "Entrance", purchaseUniqueId: entrance.entranceUniqueId!, created: purchasedTime) == false {
                                                    
                                                        // rollback entrance insert
                                                        EntranceModelHandler.removeById(id: entrance.entranceUniqueId!, username: username!)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        localPurchased.updateValue((purchaseId, downloaded, purchasedTime), forKey: saleId)
                                        self.removeSaleById(saleId: saleId)
                                    }
                                    
                                    self._basketId = nil
                                    if let compl = completion {
                                        compl(count: self._sales.count, purchased: localPurchased)
                                    }
                                }
                                break
                            case "Error":
                                if let errorType = localData["error_type"].string {
                                    switch errorType {
                                    case "EmptyBasket":
                                        NSOperationQueue.mainQueue().addOperationWithBlock({
                                            AlertClass.showTopMessage(viewController: viewController, messageType: "BasketResult", messageSubType: errorType, type: "error", completion: nil)
                                            
                                            self._basketId = nil
                                            self.removeAllSales()
                                            if let compl = completion {
                                                compl(count: 0, purchased: nil)
                                            }
                                        })
                                        
//                                        AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "BasketResult", messageSubType: errorType, completion: {
//                                            self._basketId = nil
//                                            self.removeAllSales()
//                                            NSOperationQueue.mainQueue().addOperationWithBlock({ 
//                                                if let compl = completion {
//                                                    compl(count: 0, purchased: nil)
//                                                }
//                                            })
//                                        })
                                    case "RemoteDBError":
                                        fallthrough
                                    default:
                                        break
//                                        AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                    }
                                }
                                
                            default:
                                break
                            }
                        }
                    }
                }
                }, failure: { (error) in
                    if let err = error {
                        switch err {
                        case .HostUnreachable:
                            fallthrough
                        case .NoInternetAccess:
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                AlertClass.showTopMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                            })
                            
//                            AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                                let operation = NSBlockOperation(block: {
//                                    self.checkout(viewController: viewController, completion: completion)
//                                })
//                                self._queue.addOperation(operation)
//                            })
                        default:
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                AlertClass.showTopMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                            })
                            
//                            AlertClass.showSimpleErrorMessage(viewController: viewController, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                        }
                    }
                    
            })
    }
    
    
    internal func findSaleByTargetId(targetId targetId: String, type: String) -> Int? {
        let index = self._sales.indexOf { (item) -> Bool in
            if item.type == type {
                switch type {
                case "Entrance":
                    let target = item.target as? EntranceStructure
                    if target!.entranceUniqueId == targetId {
                        return true
                    }
                    break
                default:
                    break
                }
            }
            return false
        }
        
        if let i = index {
            let item = self._sales[i].id
            return item
        }
        return nil
    }

    internal func findSaleById(saleId saleId: Int) -> Int? {
        let index = self._sales.indexOf { (item) -> Bool in
            if item.id == saleId {
                return true
            }
            return false
        }
        
        if let i = index {
            let item = self._sales[i].id
            return item
        }
        return nil
    }
    
    
    internal func removeSaleById(saleId saleId: Int) {
        let index = self._sales.indexOf({ (item) -> Bool in
            return item.id == saleId
        })
        if let i = index {
            synchronized(self._lock, criticalSection: {
                self._totalCost -= self._sales[i].cost
                self._sales.removeAtIndex(i)
            })
        }
        
        if self._sales.count == 0 {
            self._basketId = nil
            self._totalCost = 0
        }
    }
    
    internal func removeAllSales() {
        synchronized(self._lock, criticalSection: {
            self._sales.removeAll()
            self._totalCost = 0
            self._basketId = nil
        })
    }
    
}
