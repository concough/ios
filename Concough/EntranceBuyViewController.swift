//
//  EntranceBuyViewController.swift
//  Concough
//
//  Created by Owner on 2018-05-21.
//  Copyright © 2018 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ProductBuyDelegate {
    func ProductBuyedResult(data data: JSON, productId: String, productType: String)
}

class EntranceBuyViewController: UIViewController {

    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var costBonLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var notBalanceLabel: UILabel!
    
    internal var balance: Int!
    internal var cost: Int!
    internal var canBuy: Bool!
    internal var productType: String!
    internal var uniqueId: String!
    internal var productBuyDelegate: ProductBuyDelegate!
    
    private var retryCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.cancelButton.layer.borderColor = self.cancelButton.titleColorForState(.Normal)?.CGColor
        self.cancelButton.layer.borderWidth = 1.0
        self.cancelButton.layer.masksToBounds = true
        self.cancelButton.layer.cornerRadius = 5.0
        
        self.buyButton.layer.cornerRadius = 5.0
        
        self.configureController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    internal func configureController() {
        if self.productType == "EntranceMulti" {
            self.headerLabel.text = "خرید بسته آزمون"
        } else {
            self.headerLabel.text = "خرید آزمون"
        }
        
        self.balanceLabel.text = "\(FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.balance)!)"
        if self.cost == 0 {
            self.costBonLabel.text = "رایگان"
            self.costBonLabel.textColor = UIColor(netHex: RED_COLOR_HEX, alpha: 1.0)
        } else {
            self.costBonLabel.text = FormatterSingleton.sharedInstance.NumberFormatter.stringFromNumber(self.cost)! + " بنکوق"
        }
        
        self.setupButtons(canBuy: self.canBuy)
    }
    
    private func setupButtons(canBuy canBuy: Bool) {
        self.buyButton.enabled = true
        self.cancelButton.hidden = false
        
        if canBuy {
            self.notBalanceLabel.hidden = true
            self.buyButton.backgroundColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        } else {
            self.notBalanceLabel.hidden = false
            self.buyButton.setTitle("خرید بنکوق", forState: .Normal)
            self.buyButton.backgroundColor = UIColor(netHex: GREEN_COLOR_HEX, alpha: 1.0)
        }
    }
    
    private func disableButtons() {
        self.cancelButton.hidden = true
        self.buyButton.enabled = false
        
        self.buyButton.backgroundColor = UIColor.darkGrayColor()
        self.buyButton.setTitle("●●●", forState: .Normal)
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func buyButtonPressed(sender: UIButton) {
        if self.canBuy == true {
            self.addToLibrary()
        } else {
            AlertClass.showAlertMessage(viewController: self, messageType: "ErrorResult", messageSubType: "UnsupportedVersion", type: "error", completion: {
            })
        }
    }
    
    private func addToLibrary() {
        ProductRestAPIClass.addToLibrary(productId: self.uniqueId, productType: self.productType, completion: { (data, error) in
            
            if error != HTTPErrorType.Success {
                if error == HTTPErrorType.Refresh {
                    self.addToLibrary()
                } else {
                    if self.retryCounter < CONNECTION_MAX_RETRY {
                        self.retryCounter += 1
                        self.addToLibrary()
                    } else {
                        self.retryCounter = 0
                        
                        AlertClass.showTopMessage(viewController: self, messageType: "HTTPError", messageSubType: (error?.toString())!, type: "error", completion: nil)
                        
                    }
                }
            } else {
                self.retryCounter = 0
                
                if let localData = data {
                    if let status = localData["status"].string {
                        switch status {
                        case "OK":
                            self.productBuyDelegate.ProductBuyedResult(data: localData, productId: self.uniqueId, productType: self.productType)
                            self.dismissViewControllerAnimated(true, completion: nil)
                            
                        case "Error":
                            if let errorType = localData["error_type"].string {
                                switch errorType {
                                case "DuplicateSale":
                                    AlertClass.showAlertMessage(viewController: self, messageType: "BasketResult", messageSubType: errorType, type: "error", completion: {
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    })
                                case "UnsupportedVersion":
                                    AlertClass.showAlertMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, type: "error", completion: {
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    })
                                case "ProductNotExist":
                                    AlertClass.showAlertMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, type: "", completion: {
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    })
                                    
                                case "WalletNotEnoughCash":
                                    AlertClass.showAlertMessage(viewController: self, messageType: "WalletResult", messageSubType: errorType, type: "error", completion: {
                                        self.canBuy = false
                                        self.setupButtons(canBuy: self.canBuy)
                                    })
                                default:
                                    AlertClass.showTopMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, type: "", completion: nil)
                                    //                                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "ErrorResult", messageSubType: errorType, completion: nil)
                                }
                            }
                            
                        default:
                            break
                        }
                    }
                }
            }
            
        }) { (error) in
            
            if self.retryCounter < CONNECTION_MAX_RETRY {
                self.retryCounter += 1
                self.addToLibrary()
            } else {
                self.retryCounter = 0
                
                if let err = error {
                    switch err {
                    case .HostUnreachable:
                        fallthrough
                    case .NoInternetAccess:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "error", completion: nil)
                        })
                        
                        //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: {
                        //                        let operation = NSBlockOperation(block: {
                        //                            self.downloadUserPurchaseData()
                        //                        })
                        //                        self.queue.addOperation(operation)
                    //                    })
                    default:
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            AlertClass.showTopMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, type: "", completion: nil)
                        })
                        
                        //                    AlertClass.showSimpleErrorMessage(viewController: self, messageType: "NetworkError", messageSubType: err.rawValue, completion: nil)
                    }
                }
            }
        }
        
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
