//
//  DownloaderSingleton.swift
//  Concough
//
//  Created by Owner on 2017-01-16.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation

class DownloaderSingleton {
    static let sharedInstance = DownloaderSingleton()
    
    internal enum DownloaderState {
        case Initilize
        case Started
        case Finished
    }
    private var downloaders: [String: (type: String, object: AnyObject, state: DownloaderState)]
    
    private init() {
        self.downloaders = [:]
    }
    
    internal var AllDownloadersId: [String: (type: String, object: AnyObject, state: DownloaderState)] {
        get {
            return self.downloaders
        }
    }
    
    internal func getMeDownloader(type type: String, uniqueId: String) -> AnyObject? {
        if type == "Entrance" {
            if self.downloaders.keys.contains(uniqueId) == true {
                let downloader = self.downloaders[uniqueId]!.object
                return downloader
            } else {
                let downloader = EntrancePackageDownloader()
                self.downloaders.updateValue((type: type, object: downloader, state: DownloaderState.Initilize), forKey: uniqueId)
                return downloader
            }
        }
        
        return nil
    }

    internal func removeDownloader(uniqueId uniqueId: String) {
        if self.downloaders.keys.contains(uniqueId) {
            self.downloaders.removeValueForKey(uniqueId)
        }
    }
    
    internal func setDownloaderStarted(uniqueId uniqueId: String) {
        if self.downloaders.keys.contains(uniqueId) {
            self.downloaders[uniqueId]!.state = .Started
        }
    }

    internal func setDownloaderFinished(uniqueId uniqueId: String) {
        if self.downloaders.keys.contains(uniqueId) {
            self.downloaders[uniqueId]!.state = .Finished
        }
    }
    
    internal func getDownloaderState(uniqueId uniqueId: String) -> DownloaderState? {
        if self.downloaders.keys.contains(uniqueId) {
            return self.downloaders[uniqueId]!.state
        }
        return nil
    }
    
}
