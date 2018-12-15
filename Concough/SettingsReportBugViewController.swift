//
//  SettingsReportBugViewController.swift
//  Concough
//
//  Created by Owner on 2017-02-03.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit
import MBProgressHUD

class SettingsReportBugViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var reportButton: UIButton!
    
    private var loading: MBProgressHUD?
    private var isFirstTime: Bool = true
    private var retryCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "کنکوق"
        
        self.reportButton.layer.cornerRadius = 5.0
        self.reportButton.layer.masksToBounds = true
        
        self.reportTextView.layer.cornerRadius = 5.0
        self.reportTextView.layer.masksToBounds = true
        self.reportTextView.layer.borderColor = UIColor(netHex: 0xDDDDDD, alpha: 1.0).CGColor
        self.reportTextView.layer.borderWidth = 1.0
        
        self.reportTextView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if self.isFirstTime {
            textView.text = ""
            self.isFirstTime = false
        }
    }
    
    // MARK: - Actions
    @IBAction func reportButtonPressed(sender: UIButton) {
        if self.reportTextView.text.characters.count > 0 {
            self.reportTextView.resignFirstResponder()
            self.reportBug(text: self.reportTextView.text)
        } else {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.showAlertMessage(viewController: self, messageType: "Form", messageSubType: "EmptyFields", type: "warning", completion: nil)
            })
        }
    }
    
    // MARK: - Functions
    private func reportBug(text text: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock { 
            self.loading = AlertClass.showLoadingMessage(viewController: self)
        }
        
        SettingsRestAPIClass.postBug(description: text, completion: { (data, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                AlertClass.hideLoaingMessage(progressHUD: self.loading)
            })
            
            if error != HTTPErrorType.Success {
                // sometimes happened
                if error == HTTPErrorType.Refresh {
                    self.reportBug(text: text)
                } else {
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        self.reportBug(text: text)
                    } else {
                        self.retryCounter = 0
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                        })
                    }
                }
            } else {
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                                AlertClass.showAlertMessage(viewController: self, messageType: "ActionResult", messageSubType: "BugReportedSuccess", type: "success", completion: {
                                
                                    if self.navigationController != nil {
                                        self.navigationController?.popViewControllerAnimated(true)
                                    }
                                })
                            })
                            
                            break
                        case "Error":
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

            if self.retryCounter < CONNECTION_MAX_RETRY {
                self.retryCounter += 1
                self.reportBug(text: text)
            } else {
                self.retryCounter = 0
                
                if let err = error {
                    switch err {
                    case .NoInternetAccess:
                        fallthrough
                    case .HostUnreachable:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                        })
                        //                            AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        //                                NSOperationQueue.mainQueue().addOperationWithBlock({
                        //                                    self.login()
                        //                                })
                    //                            })
                    default:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                        })
                    }
                }
            }
        }
    }
}
