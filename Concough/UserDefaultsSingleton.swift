//
//  UserDefaultsSingleton.swift
//  Concough
//
//  Created by Owner on 2016-12-07.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

class UserDefaultsSingleton {
    private var _settings: NSUserDefaults!
    
    static let sharedInstance = UserDefaultsSingleton()
        
    private init() {
        self._settings = NSUserDefaults.standardUserDefaults()
    }
    
    private func setValue(value: AnyObject, key: String) {
        self._settings.setObject(value, forKey: key)
    }
    
    private func getValue(key key: String) -> AnyObject? {
        return self._settings.objectForKey(key)
    }
    
    func clearAll() -> Bool {
        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        self._settings.removePersistentDomainForName(appDomain)
        return true
    }
    
    func hasProfile() -> Bool {
        if let value = self.getValue(key: "Profile.Created") as? Bool {
            return value
        }
        return false
    }
    
    func createProfile(firstname firstname: String, lastname: String, grade: String, gender: String, birthday: NSDate, modified: NSDate) {
        self.setValue(firstname, key: "Profile.Firstname")
        self.setValue(lastname, key: "Profile.Lastname")
        self.setValue(grade, key: "Profile.Grade")
        self.setValue(gender, key: "Profile.Gender")
        self.setValue(birthday, key: "Profile.Birthday")
        self.setValue(modified, key: "Profile.Modified")
        self.setValue(true, key: "Profile.Created")
    }
    
    func getProfile() -> (String, String, String, String, NSDate, NSDate)? {
        if let firstname = self.getValue(key: "Profile.Firstname") as? String,
            let lastname = self.getValue(key: "Profile.Lastname") as? String,
            let grade = self.getValue(key: "Profile.Grade") as? String,
            let gender = self.getValue(key: "Profile.Gender") as? String,
            let birthday = self.getValue(key: "Profile.Birthday") as? NSDate,
            let modified = self.getValue(key: "Profile.Modified") as? NSDate {
            
            return (firstname, lastname, grade, gender, birthday, modified)
        }
        
        return nil
    }
    
    func getUsername() -> String? {
        return TokenHandlerSingleton.sharedInstance.getUsername()
    }
}
