//
//  AppDelegate.swift
//  Concough
//
//  Created by Owner on 2016-11-06.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //UINavigationBar.appearance().barTintColor = UIColor(netHex: 0xFFFFFF, alpha: 0.5)
        //UINavigationBar.appearance().backgroundColor = UIColor(netHex: 0xFFFFFF, alpha: 0.5)
        //UINavigationBar.appearance().barTintColor =
        
        let attributes = NSDictionary(object: UIFont(name: "IRANYekanMobile-Bold", size: 14)! , forKey: NSFontAttributeName) as! [String: AnyObject]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, forState: .Normal)

        let attributes2 = NSDictionary(object: UIFont(name: "IRANYekanMobile-Bold", size: 10)! , forKey: NSFontAttributeName) as! [String: AnyObject]
        UITabBarItem.appearance().setTitleTextAttributes(attributes2, forState: .Normal)
        
        // TSMessage appearance
        //TSMessageView.appearance().setValue(13, forKey: "titleFontSize")
        
        if let options = launchOptions {
            let value = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification
            if let notification = value {
                self.window?.rootViewController?.tabBarController?.selectedIndex = 2
            } else {
                LocalNotificationsSingleton.sharedInstance.touch()
            }
        }
        
        return true
    }

    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        let bundles = identifier.componentsSeparatedByString(":")
        if bundles[0] == "Entrance" {
            if let downloader = DownloaderSingleton.sharedInstance.getMeDownloader(type: bundles[0], uniqueId: bundles[1]) as? EntrancePackageDownloader {
                downloader.backgroundCompletionHandler = completionHandler
            }
        }
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types == .None {
            return
        }
        
        LocalNotificationsSingleton.sharedInstance.changeAllowNotification(allow: true)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

