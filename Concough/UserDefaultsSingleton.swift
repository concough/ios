//
//  UserDefaultsSingleton.swift
//  Concough
//
//  Created by Owner on 2016-12-07.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import NSUserDefaults_SevenSecurityLayers

class UserDefaultsSingleton {
    private var _settings: NSUserDefaults!
    
    static let sharedInstance = UserDefaultsSingleton()
        
    private init() {
        let l = NSUserDefaults.securedUserDefaults().setSecretKey(SECRET_KEY)
        self._settings = l
    }
    
    func touch() {}
    
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
    
    func createProfile(firstname firstname: String, lastname: String, grade: String, gradeString: String, gender: String, birthday: NSDate, modified: NSDate) {
        self.setValue(firstname, key: "Profile.Firstname")
        self.setValue(lastname, key: "Profile.Lastname")
        self.setValue(grade, key: "Profile.Grade")
        self.setValue(gradeString, key: "Profile.GradeString")
        self.setValue(gender, key: "Profile.Gender")
        self.setValue(birthday, key: "Profile.Birthday")
        self.setValue(modified, key: "Profile.Modified")
        self.setValue(true, key: "Profile.Created")
    }
    
    func getProfile() -> (firstname: String, lastname: String, grade: String, gradeString: String, gender: String, birthday: NSDate, modified: NSDate)? {
        if let firstname = self.getValue(key: "Profile.Firstname") as? String,
            let lastname = self.getValue(key: "Profile.Lastname") as? String,
            let grade = self.getValue(key: "Profile.Grade") as? String,
            let gender = self.getValue(key: "Profile.Gender") as? String,
            let birthday = self.getValue(key: "Profile.Birthday") as? NSDate,
            let modified = self.getValue(key: "Profile.Modified") as? NSDate,
            let gradeString = self.getValue(key: "Profile.GradeString") as? String {
            
            return (firstname: firstname, lastname: lastname, grade: grade, gradeString: gradeString, gender: gender, birthday: birthday, modified: modified)
        }
        
        return nil
    }
    
    func updateModified(modified modified: NSDate) {
        self.setValue(modified, key: "Profile.Modified")
        self._settings.synchronize()
    }
    
    func updateGrade(grade grade: String, gradeString: String, modified: NSDate) {
        self.setValue(grade, key: "Profile.Grade")
        self.setValue(gradeString, key: "Profile.GradeString")
        self.setValue(modified, key: "Profile.Modified")
    }
    
    func getUsername() -> String? {
        return TokenHandlerSingleton.sharedInstance.getUsername()
    }
    
    func chackPassword(password pass: String) -> Bool {
        if TokenHandlerSingleton.sharedInstance.getPassword() == pass {
            return true
        }
        return false
    }
}
