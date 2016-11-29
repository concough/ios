//
//  LoginViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-28.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    private var activeTextField: UITextField?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // customize uibutton
        self.loginButton.layer.cornerRadius = 5
        
        // make text fields properties
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        //self.emailTextField.becomeFirstResponder()
        
        // Set Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
        // GestureRecognizer functions
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTapped(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.enabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        self.scrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    // MARK: - Actions
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        if let email = emailTextField.text where email != "", let pass = passwordTextField.text where pass != "" {
            
            // email and password entered correctly
            OAuthHandlerSingleton.sharedInstance.setUsernameAndPassword(username: email, password: pass)
            
            OAuthHandlerSingleton.sharedInstance.assureAuthorized(completion: { authenticated, error in
                if authenticated {
                    if let err = error {
                        switch err {
                            case .UnAuthorized:
                                self.showAlert("UnAuthorized")
                            case .ForbidenAccess:
                                self.showAlert("ForbiddenAccess")
                            case .NotFound:
                                fallthrough
                            case .UnKnown:
                                break
                            default:
                                break
                        }
                        
                    } else {
                        // login passed successfully
                        if OAuthHandlerSingleton.sharedInstance.isAuthorized() {
                            // ok --> now perform segue
                            KeyChainAccessProxy.setValue(USERNAME_KEY, value: email)
                            KeyChainAccessProxy.setValue(PASSWORD_KEY, value: pass)
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.performSegueWithIdentifier("HomeVCSegue", sender: self)
                            })
                        }
                    }
                }
            })
        } else {
            // Show alert
            self.showAlert("EmptyField")
        }
    }
    
    func showAlert(type: String) {
        var title: String?
        var message: String?
        var showMsg: Bool = false
        
        switch type {
        case "EmptyField":
            showMsg = true
            title = "خطا"
            message = "لطفا هر دو فیلد را پر نمایید"
        
        case "UnAuthorized":
            showMsg = true
            title = "خطا"
            message = "اطلاعات وارد شده صحیح نمی باشد."

        case "ForbiddenAccess":
            showMsg = true
            title = "خطا"
            message = "این دسترسی برای شما تعریف نشده است."

        default:
            break
        }
        
        if showMsg {
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                let alertController = UIAlertController(title: title!, message: message!, preferredStyle: .Alert)
                let action = UIAlertAction(title: "متوجه شدم", style: .Default, handler: nil)
                alertController.addAction(action)
                self.showViewController(alertController, sender: self)                
            })
        }
    }
    
    // MARK: - TextField Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    // MARK: - Notifications Implementations
    func keyboardWillShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardSize: CGSize = (userInfo["UIKeyboardFrameBeginUserInfoKey"]?.CGRectValue().size)!
            
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            // if active text field is hidden by keyboard, scroll it so it's visible
            var aRect: CGRect = self.view.frame
            aRect.size.height -= keyboardSize.height
            
            if self.activeTextField != nil {
                if !CGRectContainsPoint(aRect, (self.activeTextField?.frame.origin)!) {
                    self.scrollView.scrollRectToVisible((self.activeTextField?.frame)!, animated: true)
                }
            }
            
        }
    }
    func keyboardWillHideNotification(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // Gusture Recognizer implementations
    func singleTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
