//
//  MediaRequestRepositorySingleton.swift
//  Concough
//
//  Created by Owner on 2016-12-03.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

class MediaRequestRepositorySingleton: RequestRepositoryClass {
    static let sharedInstance = MediaRequestRepositorySingleton()
    
    private override init() {
        super.init()
    }    
}
