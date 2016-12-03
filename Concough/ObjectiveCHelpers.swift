//
//  ObjectiveCHelpers.swift
//  Concough
//
//  Created by Owner on 2016-12-03.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import ObjectiveC

final class Lifted<T> {
    let value: T
    init(_ x: T) {
        value = x
    }
}

private func lift<T>(x: T) -> Lifted<T> {
    return Lifted(x)
}

func setAssociatedObject<T>(object: AnyObject, value: T, associativeKey: UnsafePointer<Void>, policy: objc_AssociationPolicy) {
    if let v: AnyObject = value as? AnyObject {
        objc_setAssociatedObject(object, associativeKey, v, policy)
    } else {
        objc_setAssociatedObject(object, associativeKey, lift(value), policy)
    }
}

func getAssociatedObject<T>(object: AnyObject, associatedKey: UnsafePointer<Void>) -> T? {
    if let v = objc_getAssociatedObject(object, associatedKey) as? T {
        return v
    } else if let v = objc_getAssociatedObject(object, associatedKey) as? Lifted<T> {
        return v.value
    }
    
    return nil
}
