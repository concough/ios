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

extension UIGestureRecognizer {
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


extension UIColor {
    convenience init(netHex: Int, alpha: CGFloat) {
        self.init(red: CGFloat((netHex >> 16) & 0xff) / 255.0, green: CGFloat((netHex >> 8) & 0xff) / 255.0, blue:  CGFloat((netHex >> 0) & 0xff) / 255.0, alpha:  alpha)
    }
}

extension UIImageView {
    func tintImageColor(color: UIColor) {
        self.image = self.image!.imageWithRenderingMode(.AlwaysTemplate)
        self.tintColor = color
    }
}
