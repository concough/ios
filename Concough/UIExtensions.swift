//
//  UIExtensions.swift
//  Concough
//
//  Created by Owner on 2016-12-03.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    private struct AssociatedKey {
        static var ViewExtension = "ViewExtension"
    }
    
    var assicatedObject: String {
        get {
            return getAssociatedObject(self, associatedKey: &AssociatedKey.ViewExtension)!
        }
        
        set {
                setAssociatedObject(self, value: newValue, associativeKey: &AssociatedKey.ViewExtension, policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
