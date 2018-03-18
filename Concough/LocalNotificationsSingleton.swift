//
//  LocalNotificationsSingleton.swift
//  Concough
//
//  Created by Owner on 2017-02-07.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation
import UIKit

class LocalNotificationsSingleton {
    static let sharedInstance = LocalNotificationsSingleton()
    
    private var settings: UIUserNotificationSettings!
    private var _allowNotification: Bool = false
    
    private init() {
        self._allowNotification = false
        self.settings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    internal func changeAllowNotification(allow allow: Bool) {
        self._allowNotification = allow
    }
    
    internal func touch() {
        
    }
    
    internal func createNotification(alertTitle alertTitle: String, alertBody: String, fireDate: NSDate) {
        if self._allowNotification {
            let notification = UILocalNotification()
            notification.fireDate = fireDate
            notification.timeZone = NSTimeZone(name: "Asia/tehran")
            notification.alertBody = alertBody
            notification.alertTitle = alertTitle
            notification.alertLaunchImage = "logo_white_transparent_notification"
            notification.hasAction = false
            
            UIApplication.sharedApplication().applicationIconBadgeNumber += 1
            
            UIApplication.sharedApplication().scheduleLocalNotification(notification)            
        }
    }
}
