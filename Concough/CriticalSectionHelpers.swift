//
//  CriticalSectionHelpers.swift
//  Concough
//
//  Created by Owner on 2016-12-03.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

// Protocols for NSLocking objects that also provide tryLock()
public protocol TryLockable: NSLocking {
    func tryLock() -> Bool
}

// These Cocoa classes have tryLock()
extension NSLock: TryLockable {}
extension NSRecursiveLock: TryLockable {}
extension NSConditionLock: TryLockable {}

/// Protocols for NSLocking objects that also provide lockBeforeDate()
public protocol BeforeDateLockable: NSLocking {
    func lockBeforeDate(limit: NSDate) -> Bool
}

// These Cocoa classes have lockBeforeDate()
extension NSLock: BeforeDateLockable {}
extension NSRecursiveLock: BeforeDateLockable {}
extension NSConditionLock: BeforeDateLockable {}


/// Use an NSLocking object as a mutex for a critical section of code
public func synchronized<L: NSLocking> (lockable: L, criticalSection: () -> ()) {
    lockable.lock()
    criticalSection()
    lockable.unlock()
}

/// Use an NSLocking object as a mutex for a critical section of code that returns a result
public func synchronizedResult<L: NSLocking, T>(lockable: L, criticalSection: () -> T) -> T {
    lockable.lock()
    let result = criticalSection()
    lockable.unlock()
    return result
}

/// Use an TryLockable object as a mutex for a critical section of code
///
/// Return true if the critical section was executed, or false if tryLock() failed
public func trySynchronized<L: TryLockable>(lockable: L, criticalSection: () -> ()) -> Bool {
    if !lockable.tryLock() {
        return false
    }
    criticalSection()
    lockable.unlock()
    return true
}

/// Use an BeforeDateLockable object as a mutex for a critical section of code
///
/// Return true if the critical section was executed, or false if lockBeforeDate failed
public func synchronizedBeforeDate<L: BeforeDateLockable>(limit: NSDate, lockable: L, criticalSection: () -> ()) -> Bool {
    
    if !lockable.lockBeforeDate(limit) {
        return false
    }
    criticalSection()
    lockable.unlock()
    return true
}


