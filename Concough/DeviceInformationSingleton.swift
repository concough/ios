//
//  DeviceInformationSingleton.swift
//  Concough
//
//  Created by Owner on 2017-09-26.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation

class DeviceInformationSingleton {
    private var _settings: NSUserDefaults!
    
    static let sharedInstance = DeviceInformationSingleton()
    
    private init() {
        let l = NSUserDefaults.securedUserDefaults().setSecretKey(SECRET_KEY)
        l.addSuiteNamed("device")
        self._settings = l
        
    }
    
    private func setValue(value: AnyObject, key: String) {
        self._settings.setObject(value, forKey: key)
    }
    
    private func getValue(key key: String) -> AnyObject? {
        return self._settings.objectForKey(key)
    }
    
    func touch() {}
    
    func clearAll(username: String?) -> Bool {
        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        self._settings.removePersistentDomainForName(appDomain)
        
        DeviceInformationModelHandler.removeDevicePerUser(username!)
        return true
    }
    
    func getLastAppVersion() -> Int? {
        
        if let version = self.getValue(key: "AppVersion") as? Int {
            return version
        }
        
        return nil
    }

    func getLastAppVersionCount(version: Int) -> Int {
        
        if let count = self.getValue(key: "AppVersion.\(version)_count") as? Int {
            return count
        }
        
        return 0
    }

    func putLastAppVersion(version: Int) {
        self.setValue(version, key: "AppVersion")
        let count = self.getLastAppVersionCount(version)
        if count == 0 {
            self.setValue(1, key: "AppVersion.\(version)_count")
        } else {
            self.setValue(count + 1, key: "AppVersion.\(version)_count")
        }
    }
    
    func setDeviceState(username: String, device_name: String, device_model: String, state: Bool, isMe: Bool) -> Bool {
        return  DeviceInformationModelHandler.update(username, deviceName: device_name, deviceModel: device_model, state: state, isMe: isMe)
    }
    
    func getDeviceState(username: String) -> (String, String, Bool)? {
        
        if let device = DeviceInformationModelHandler.findByUniqueId(username) {
            return (device.device_name, device.device_model, device.state)
        }
        return nil
    }
    
}

