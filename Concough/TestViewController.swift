//
//  TestViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-26.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import Alamofire
import SwiftMessages

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationUserDidTakeScreenshotNotification, object: nil, queue: mainQueue) { (notification) in
            NSLog("Captured Screen")
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        
        NSLog("Touches cancelled")
        print("Touched Cancelled")
    }
    
    @IBAction func testOauthToken(sender: UIButton) {
        var headers: [String: String] = ["Content-Type": "application/x-www-form-urlencoded",
                                         "Accept": "application/json"]
        let parameters: [String: String] = ["grant_type": "password",
                                            "username": "abolfazlbeh",
                                            "password": "abolfazl#102938"]
        
        let clientId = "vKREqBOlXXVZNqWdAGTYio8W6Rhe4SpTAtCZb6Ra"
        let clientPassword = "uAnxNKjqK1b5i0Y3SYpCWnyjORQR14JIpOHchse0alsYpqIVrpy2C9Fu095anIrM6v3yft0pDjO8eGu5G8q5UDs7WjMEqpHUVwg9x6QHrIlW6NR2DZiUJD0njCaqkBaL"
        
        let clientData: NSData = "\(clientId):\(clientPassword)".dataUsingEncoding(NSUTF8StringEncoding)!
        let client64String = clientData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0))
        
        let login_url = "http://192.168.1.15:8000/api/o/token/"
        
        
        headers["Authorization"] = "Basic \(client64String)"
        Alamofire.request(.POST, login_url, parameters: parameters, encoding: .URL, headers: headers).responseData {
            response in
            
            debugPrint(response)
        }
    }
    
    @IBAction func clearKeyChainCache(sender: UIButton) {
//        if KeyChainAccessProxy.clearAllValue() {
//            print ("All KeyChain Value cleared")
//        }
//        if UserDefaultsSingleton.sharedInstance.clearAll() {
//            print ("All UserDefaults Value cleared")
//        }
    
    SnapshotCounterHandler.deleteAllValue()
    }
    
    @IBAction func showMessaeg(sender: UIButton) {
        let view = MessageView.viewFromNib(layout: .MessageViewIOS8)
        var config = SwiftMessages.Config()
        config.presentationStyle = .Top
        config.preferredStatusBarStyle = UIStatusBarStyle.Default
        //config.presentationContext = .Window(windowLevel: UIWindowLevel)
        config.duration = .Seconds(seconds: 3)
        config.interactiveHide = true
        
        view.configureTheme(.Info)
        view.configureDropShadow()
        view.configureContent(title: "تست", body: nil, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)

        view.titleLabel?.font = UIFont()
        SwiftMessages.show(config: config, view: view)
        
    }
    
}
