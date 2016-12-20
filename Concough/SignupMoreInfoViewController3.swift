//
//  SignupMoreInfoViewController3.swift
//  Concough
//
//  Created by Owner on 2016-12-11.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class SignupMoreInfoViewController3: UIViewController, UINavigationControllerDelegate {

    internal var infoStruct: SignupMoreInfoStruct!
    private var selectedGrade: GradeTypeEnum!
    
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
            self.selectedGrade = GradeTypeEnum(rawValue: grade)
        } else {
            self.selectedGrade = GradeTypeEnum.BE
        }
        
        self.gradeButton.setTitle( self.selectedGrade.toString(), forState: .Normal) 
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
    
    // MARK: - Actions
    @IBAction func gradeButtonPressed(sender: UIButton) {
        let actionSheet = UIAlertController(title: "متقاضی کنکور", message: "لطفا یکی از گزینه های زیر را انتخاب نمایید", preferredStyle: .ActionSheet)
        
        for value in GradeTypeEnum.allValues {
            let action = UIAlertAction(title: value.toString(), style: .Default) {
                action in
                
                
                let index = actionSheet.actions.indexOf(action)
                print(index)
                self.selectedGrade = GradeTypeEnum.allValues[index!]
                
//                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.gradeButton.setTitle(value.toString(), forState: .Normal)
//                })
            }
            
            actionSheet.addAction(action)
        }
        
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        // main action here
        self.postProfile()
    }
    
    // MARK: - Functions
    private func postProfile() {
        self.infoStruct.grade = self.selectedGrade.rawValue

        ProfileRestAPIClass.postProfileData(info: self.infoStruct, completion: { (data, error) in
            if error != HTTPErrorType.Success {
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            var modified = NSDate()
                            if let m = localData["modified"].string {
                                modified = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(m)!
                            }
                            
                            UserDefaultsSingleton.sharedInstance.createProfile(firstname: self.infoStruct.firstname!, lastname: self.infoStruct.lastname!, grade: self.infoStruct.grade!, gender: self.infoStruct.gender!, birthday: self.infoStruct.birthday!, modified: modified)
                            
                            if UserDefaultsSingleton.sharedInstance.hasProfile() {
                                print("Profile Created")
                            }
                            
                            // perform segue navigation to home controller
                            let vc : UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NHomeTableViewController") as! UINavigationController;
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.presentViewController(vc, animated: true, completion: nil)
                                //self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                            })
                            
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "UserNotExist":
                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "AuthProfile", messageSubType: errorType, completion: nil)
                                case "MultiRecord":
                                    fallthrough
                                case "BadData":
                                    fallthrough
                                case "RemoteDBError":
                                    fallthrough
                                default:
                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                    
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
            if let err = error {
                switch err {
                case .NoInternetAccess:
                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: { 
                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
                            self.postProfile()
                        })
                    })
                default:
                    break
                }
            }
        })
    }

    // MARK: - Navigations
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HomeVCSegue" {
            
        }
    }
}
