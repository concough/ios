//
//  EntranceCommentType.swift
//  Concough
//
//  Created by Owner on 2018-03-31.
//  Copyright © 2018 Famba. All rights reserved.
//

import Foundation

enum EntranceCommentType: String {
    case TEXT = "TEXT"
    
    static func toType(item: String) -> EntranceCommentType {
        switch item {
        case "TEXT":
            return .TEXT
        default:
            return .TEXT
        }
    }
}
