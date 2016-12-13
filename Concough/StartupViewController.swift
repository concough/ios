//
//  StartupViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-28.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class StartupViewController: UIViewController {
    
    enum returnFormSegueType {
        case None
        case ForgotPasswordVC
        case SignupVC
        case LogIn
    }
    
    var returnFormVC: returnFormSegueType = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // load data from keyChain --> get token if exist else show login viewController
        if OAuthHandlerSingleton.sharedInstance.isAuthorized() {            
            if UserDefaultsSingleton.sharedInstance.hasProfile() {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                }
            } else {
                // get profile
                self.getProfile()
            }
        } else if OAuthHandlerSingleton.sharedInstance.isAuthenticated() {
            OAuthHandlerSingleton.sharedInstance.assureAuthorized(true) { (authenticated, error) in
                if authenticated {
                    print("StartupViewController: Authenticated")
                    if UserDefaultsSingleton.sharedInstance.hasProfile() {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                        }
                    } else {
                        // get profile
                        self.getProfile()
                    }
                } else {
                    print("StartupViewController: Not Authenticated")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                    }
                }
            }
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("LogInVCSegue", sender: self)
            }            
        }
    }

    override func viewDidAppear(animated: Bool) {
        switch returnFormVC {
            case .ForgotPasswordVC:
                returnFormVC = .None
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("ForgotPasswordVCSegue", sender: self)
                }
            
            case .SignupVC:
                returnFormVC = .None
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("SignUpVCSugue", sender: self)
                }
            case .LogIn:
                returnFormVC = .None
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                }
            case .None:
                break
        }
    }
    
    // MARK: - Functions
    private func getProfile() {
        ProfileRestAPIClass.getProfileData({ (data, error) in
            if error != HTTPErrorType.Success {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                })
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            // profile exist
                            let profile = localData["record"][0]
                            
                            // save profile
                            if let gender = profile["gender"].string, let grade = profile["grade"].string, let birthday = profile["birthday"].string, let modified = profile["modified"].string, let firstname = profile["user"]["first_name"].string, let lastname = profile["user"]["last_name"].string {
                                
                                let modifiedDate = FormatterSingleton.sharedInstance.UTCDateFormatter.dateFromString(modified)
                                let birthdayDate = FormatterSingleton.sharedInstance.UTCShortDateFormatter.dateFromString(birthday)
                                
                                UserDefaultsSingleton.sharedInstance.createProfile(firstname: firstname, lastname: lastname, grade: grade, gender: gender, birthday: birthdayDate!, modified: modifiedDate!)
                            }
                            
                            if UserDefaultsSingleton.sharedInstance.hasProfile() {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                                })
                            } else {
                                // profile not created --> try again
                            }
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "ProfileNotExist":
                                    // profile not exist --> perform navigation
                                    fallthrough
                                default:
                                    NSOperationQueue.mainQueue().addOperationWithBlock({
                                        self.performSegueWithIdentifier("LogInVCSegue", sender: self)
                                    })
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    // MARK: - Unwind Segue Operations
    
    @IBAction func unwindForgotPasswordPressed(segue: UIStoryboardSegue) {
        print("Unwind: Forgot Password Pressed")
        self.returnFormVC = .ForgotPasswordVC
    }

    @IBAction func unwindSignUpPressed(segue: UIStoryboardSegue) {
        print("Unwind: SignUp Pressed")
        self.returnFormVC = .SignupVC
    }
    
    @IBAction func unwindLogInPressed(segue: UIStoryboardSegue) {
        print("Unwnid: LogIn Pressed")
        self.returnFormVC = .LogIn
    }
}
