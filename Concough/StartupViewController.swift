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
    }
    
    private var returnFormVC: returnFormSegueType = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // load data from keyChain --> get token if exist else show login viewController
        OAuthHandlerSingleton.sharedInstance.assureAuthorized(true) { (authenticated, error) in
            if authenticated {
                print("StartupViewController: Authenticated")
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                }
            } else {
                print("StartupViewController: Not Authenticated")
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("LoginVCSegue", sender: self)
                }
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
            case .None:
                break
        }
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
}
