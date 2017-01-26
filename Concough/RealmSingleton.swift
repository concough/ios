//
//  RealmSingleton.swift
//  Concough
//
//  Created by Owner on 2017-01-10.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import RealmSwift

class RealmSingleton {
    static let sharedInstance = RealmSingleton()
    
    private var realm: Realm!
    
    private init() {
        
        let config = Realm.Configuration()
        
        print("\(config.fileURL)")
        self.realm = try! Realm(configuration: config)
        
        // to Background App Refresh
        let folderPath = self.realm.configuration.fileURL!.URLByDeletingLastPathComponent!.path
        print("Realm Path: \(folderPath!)")
        try! NSFileManager.defaultManager().setAttributes([NSFileAttributeKey.init(string: NSFileProtectionKey) as String: NSFileProtectionNone], ofItemAtPath: folderPath!)
    }
    
    // Properties
    internal var DefaultRealm: Realm {
        get {
            return self.realm
        }
    }
    
    // Methods
    internal func deleteDefaultRealm() {
        let realmUrl = self.realm.configuration.fileURL!
        let realmURLS = [
            realmUrl,
            realmUrl.URLByAppendingPathExtension("lock"),
            realmUrl.URLByAppendingPathExtension("log_a"),
            realmUrl.URLByAppendingPathExtension("log_b"),
            realmUrl.URLByAppendingPathExtension("note"),
        ]
        
        for url in realmURLS {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(url!)
            } catch {
                print("Cannot delete Realm Files ...")
            }
        }
    }
}
