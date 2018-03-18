//
//  DeviceInformationModelHandler.swift
//  Concough
//
//  Created by Owner on 2017-09-28.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class DeviceInformationModelHandler {
    class func update(username: String, deviceName: String, deviceModel: String, state: Bool, isMe: Bool) -> Bool {
        if let device = self.findByUniqueId(username) {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    device.device_model = deviceModel
                    device.device_name = deviceName
                    device.state = state
                    device.isMe = isMe
                })
                return true
            } catch (let error as NSError) {
                print("\(error)")
            }
        } else {
            let device = DeviceInformationModel()
            device.device_name = deviceName
            device.device_model = deviceModel
            device.username = username
            device.state = state
            device.isMe = isMe
            
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    RealmSingleton.sharedInstance.DefaultRealm.add(device)
                })
                return true
            } catch(let error as NSError) {
                print("\(error)")
            }
            
        }
        return false
    }
    
    class func findByUniqueId(username: String) -> DeviceInformationModel? {
        let items = RealmSingleton.sharedInstance.DefaultRealm.objects(DeviceInformationModel.self).filter("username = '\(username)'")
        if items.count > 0{
            return items.first
        }
        return nil
    }
    
    class func removeDevicePerUser(username: String) -> Bool {
        if let device = self.findByUniqueId(username) {
            do {
                try RealmSingleton.sharedInstance.DefaultRealm.write({
                    RealmSingleton.sharedInstance.DefaultRealm.delete(device)
                })
                return true
            } catch (let error as NSError) {
                print("\(error)")
            }
        }
        return false
    }
}
