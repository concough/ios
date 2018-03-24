//
//  SignupMoreInfoViewController3.swift
//  Concough
//
//  Created by Owner on 2016-12-11.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import MBProgressHUD
import SimpleAlert

class SignupMoreInfoViewController3: UIViewController, UINavigationControllerDelegate {

    internal var infoStruct: SignupMoreInfoStruct!
    private var selectedGrade: String!
    private var selectedGradeString: String!
    private var loading: MBProgressHUD?
    
    @IBOutlet weak var gradeButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Customize UI
        self.gradeButton.layer.cornerRadius = 5.0
        self.gradeButton.layer.borderWidth = 1.0
        self.gradeButton.layer.borderColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0).CGColor
        
        self.finishButton.layer.cornerRadius = 5.0
        
        if self.navigationController != nil {
            self.title = "کنکوق"
            //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "اتمام", style: .Plain, target: self, action: #selector(self.nextButtonPressed(_:)))
        }
    }

    override func viewWillAppear(animated: Bool) {
        if let grade = self.infoStruct.grade {
            self.selectedGrade = grade
            self.selectedGradeString = self.infoStruct.gradeString
            self.gradeButton.setTitle( self.infoStruct.gradeString, forState: .Normal)
        } else {
            self.selectedGrade = ""
            self.selectedGradeString = ""
            self.gradeButton.setTitle( "انتخاب کنید", forState: .Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Delegates
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? SignupMoreInfoViewController2 {
            controller.infoStruct = self.infoStruct
        }
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        // main action here
        self.postProfile()
    }
    
    @IBAction func gradeButtonPressed(sender: UIButton) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        ProfileRestAPIClass.getProfileGradeList({ (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.gradeButtonPressed(sender)
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                    })
                }
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            
                            if let records = localData["record"].array {
                                var localR:[String: String] = [:]
                                for record in records {
                                    if let title = record["title"].string, let code = record["code"].string {
                                        localR.updateValue(code, forKey: title)
                                    }
                                }
                                
                                self.showChooseGradeDialog(localR)
                            }
                            break
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "EmptyArray":
                                    // empty array received --> do nothing
                                    break
                                default:
                                    break
                                }
                            }
                            break
                        default:
                            break
                        }
                    }
                }
            }
        }) { (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    fallthrough
                case .HostUnreachable:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    })
                    //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                    //                        NSOperationQueue.mainQueue().addOperationWithBlock({
                    //                            self.postProfile()
                    //                        })
                //                    })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
                }
            }
        }
    }
    
    private func showChooseGradeDialog(values: [String:String]) {
        let alert = SimpleAlert.Controller(title: "متقاضی آزمون؟", message: "لطفا یکی از گزینه های زیر را انتخاب نمایید", style: .ActionSheet)
        alert.configContentView = { sview in
            if let v = sview as? SimpleAlert.ContentView {
                v.titleLabel.font = UIFont(name: "IRANSansMobile-Bold", size: 14)!
                v.messageLabel.font = UIFont(name: "IRANSansMobile", size: 12)!
                v.messageLabel.textColor = UIColor.darkGrayColor()
            }
        }
        
        alert.configContainerCornerRadius = {
            return 10.0
        }
        
        for val in values {
            let action = SimpleAlert.Action(title: val.0, style: .Default, handler: { (action) in
                
                let index = alert.actions.indexOf(action)
                self.selectedGrade = val.1
                self.selectedGradeString = val.0

                //                NSOperationQueue.mainQueue().addOperationWithBlock({
                self.gradeButton.setTitle(val.0, forState: .Normal)
                //                })
            })
            
            alert.addAction(action)
            action.button.setTitleColor(UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0), forState: .Normal)
            action.button.titleLabel?.font = UIFont(name: "IRANSansMobile-Bold", size: 14)!
        }
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    // MARK: - Functions
    private func postProfile() {
        if self.selectedGrade == "" || self.selectedGradeString == "" {
            AlertClass.showTopMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "error", completion: nil)
        } else {
        
        self.infoStruct.grade = self.selectedGrade
        self.infoStruct.gradeString = self.selectedGradeString

        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        ProfileRestAPIClass.postProfileData(info: self.infoStruct, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.postProfile()
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                    })
                }
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            var modified = NSDate()
                            if let m = localData["modified"].string {
                                modified = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(m)!
                            }
                            
                            UserDefaultsSingleton.sharedInstance.createProfile(firstname: self.infoStruct.firstname!, lastname: self.infoStruct.lastname!, grade: self.infoStruct.grade!, gradeString: self.infoStruct.gradeString!, gender: self.infoStruct.gender!, birthday: self.infoStruct.birthday!, modified: modified)
                            
                            // perform segue navigation to home controller
                            let vc : UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TabHomeTableViewController") as! UITabBarController;
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.presentViewController(vc, animated: true, completion: nil)
                                //self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                            })
                            
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "UserNotExist":
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                        AlertClass.showTopMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, type: "error", completion: nil)
                                    })
                                case "MultiRecord":
                                    fallthrough
                                case "BadData":
                                    fallthrough
                                case "RemoteDBError":
                                    fallthrough
                                default:
                                    break
//                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                    
                                }
                            }
                            break
                        default:
                            break
                        }
                    }
                }
            }
        }, failure: { (error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    fallthrough
                case .HostUnreachable:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                    })
//                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
//                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
//                            self.postProfile()
//                        })
//                    })
                default:
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                    })
                }
            }
        })
        }
    }

    // MARK: - Navigations
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HomeVCSegue" {
            
        }
    }
}
