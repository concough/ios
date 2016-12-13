//
//  TypeExtensions.swift
//  Concough
//
//  Created by Owner on 2016-12-10.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String? {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}
