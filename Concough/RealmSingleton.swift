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
        
        var config = Realm.Configuration(schemaVersion: 3, migrationBlock: { (migration, oldSchemaVersion) in
            if (oldSchemaVersion < 1) {
                migration.enumerate(DeviceInformationModel.className(), { (oldObject, newObject) in
                    newObject!["isMe"] = true
                })
            }
            
            if (oldSchemaVersion < 2) {
                migration.enumerate(EntranceModel.className(), { (oldObject, newObject) in
                    newObject!["pUniqueId"] = "\(oldObject!["username"])-\(oldObject!["uniqueId"])"
                })
            }
            
            if (oldSchemaVersion < 3) {
                migration.enumerate(EntranceModel.className(), { (oldObject, newObject) in
                    newObject!["month"] = 0
                })
            }
        })
        let key = SECRET_KEY.dataUsingEncoding(NSASCIIStringEncoding)?.subdataWithRange(NSRange(location: 0, length: 64))
        config.encryptionKey = key
        
        self.realm = try! Realm(configuration: config)
        
        // to Background App Refresh
        let folderPath = self.realm.configuration.fileURL!.URLByDeletingLastPathComponent!.path
        try! NSFileManager.defaultManager().setAttributes([NSFileAttributeKey.init(string: NSFileProtectionKey) as String: NSFileProtectionNone], ofItemAtPath: folderPath!)
    }
    
    // Properties
    internal var DefaultRealm: Realm {
        get {
            return self.realm
        }
    }
    
    // Methods
    func touch() {}
    
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
