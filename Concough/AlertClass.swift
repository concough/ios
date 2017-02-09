//
//  AlertClass.swift
//  Concough
//
//  Created by Owner on 2016-12-12.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages
import MBProgressHUD
import FCAlertView

class AlertClass {
    class func convertMessage(messageType messageType: String, messageSubType: String) -> (title: String, message: String, showMsg: Bool) {
        
        var showMessage: Bool = true
        var title: String = ""
        var message: String = ""
        
        switch messageType {
        case "Contacts":
            switch messageSubType {
            case "Denied":
                title = "خطا"
                message = "لطفا اجازه دسترسی به لیست مخاطبین را از طریق تنظیمات گوشی صادر نمایید"
            case "FetchError":
                title = "خطا"
                message = "خطا در بارگذاری مخاطبین"
            default:
                showMessage = false
            }
        case "Form":
            switch messageSubType {
            case "EmptyFields":
                title = "خطا"
                message = "لطفا همه فیلدها را پر نمایید"
            case "NotSameFields":
                title = "خطا"
                message = "مقادیر وارد شده باید یکسان باشند"
            case "OldPasswordNotCorrect":
                title = "خطا"
                message = "گذرواژه فعلی نادرست است"
            case "CodeWrong":
                title = "خطا"
                message = "کد وارد شده صحیح نمی باشد"
            default:
                showMessage = false
            }
        case "ActionResult":
            switch messageSubType {
            case "ResendCodeSuccess":
                title = "پیغام"
                message = "کد فعالسازی مجددا ارسال شد"
            case "PurchasedSuccess":
                title = "پیغام"
                message = "خرید با موفقیت انجام گردید"
            case "DownloadSuccess":
                title = "پیغام"
                message = "دانلود با موفقیت انجام گردید"
            case "BasketDeleteSuccess":
                title = "پیغام"
                message = "از سبد کالا با موفقیت حذف شد"
            case "BugReportedSuccess":
                title = "پیغام"
                message = "خطای گزارش شده با موفقیت ثبت گردید"
            case "DownloadStarted":
                title = "پیغام"
                message = "دانلود شروع شده است"
            case "QuestionStarred":
                title = "پیغام"
                message = "✮" + " اضافه شد"
            case "QuestionUnStarred":
                title = "پیغام"
                message = "✩" + " حذف شد"
            case "InviteSuccess":
                title = "پیغام"
                message = "دعوتنامه ها با موفقیت ارسال گردید"
            case "ChangePasswordSuccess":
                title = "پیغام"
                message = "گذرواژه شما با موفقیت تغییر یافت"
            case "FreeMemorySuccess":
                title = "پیغام"
                message = "داده هاس شما با موفقیت پاک گردید"
            default:
                showMessage = false
            }
        case "ErrorResult":
            switch messageSubType {
            case "RemoteDBError":
                title = "خطا"
                message = "دسترسی به پایگاه داده مقدور نیست"
            case "BadData":
                title = "خطا"
                message = "لطفا دوباره سعی نمایید"
            case "ExpiredCode":
                title = "خطا"
                message = "کد ارسالی نامعتبر است. لطفا درخواست کد مجدد نمایید"
            case "MultiRecord":
                title = "خطا"
                message = "اطلاعات نامشخص است"
            case "EmptyArray":
                title = "خطا"
                message = "اطلاعات برای نمایش ناموجود"                
            default:
                showMessage = false
            }
        case "EntranceResult":
            switch messageSubType {
            case "EntranceNotExist":
                title = "خطا"
                message = "کنکور درخواستی موجود نمی باشد"
            default:
                showMessage = false
            }
        case "BasketResult":
            switch messageSubType {
            case "SaleNotExist":
                title = "خطا"
                message = "چنین خریدی موجود نیست"
            case "DuplicateSale":
                title = "خطا"
                message = "این خرید قبلا ثبت شده است"
            case "EmptyBasket":
                title = "خطا"
                message = "سبد خرید شما خالی است"
            default:
                showMessage = false
            }
        case "AuthProfile":
            switch messageSubType {
            case "ExistUsername":
                title = "خطا"
                message = "این نام کاربری قبلا انتخاب شده است"
            case "UserNotExist":
                title = "خطا"
                message = "لطفا ابتدا ثبت نام کنید"
            case "PreAuthNotExist":
                title = "خطا"
                message = "لطفا مجددا تقاضای کد نمایید"
            case "MismatchPassword":
                title = "خطا"
                message = "هر دو فیلد گذرواژه باید یکی باشند"
            case "PassCannotChange":
                title = "خطا"
                message = "امکان تغییر گذرواژه وجود ندارد"
            default:
                showMessage = false
            }
        case "HTTPError":
            switch messageSubType {
            case "BadRequest":
                fallthrough
            case "UnAuthorized":
                title = "خطای دسترسی"
                message = "اطلاعات وارد شده صحیح نمی باشد."
            case "ForbiddenAccess":
                title = "خطای دسترسی"
                message = "دسترسی غیر مجاز"
            case "Unknown":
                fallthrough
            case "NetworkError":
                title = "خطای دسترسی"
                message = "برقراری ارتباط با سرور مقدور نیست"
            case "NotFound":
                title = "خطای دسترسی"
                message = "آدرس نامعتبر است"
            default:
                showMessage = false
            }
        case "NetworkError":
            switch messageSubType {
            case "NoInternetAccess":
                title = "خطای اینترنت"
                message = "لطفا اینترنت خود را فعال نمایید"
            case "HostUnreachable":
                title = "خطای اینترنت"
                message = "در حال حاضر کنکوق پاسخگو نمی باشد"
            case "UnKnown":
                title = "خطای اینترنت"
                message = "اشکال در شبکه"
            default:
                showMessage = false
            }
        default:
            showMessage = false
        }
     
        return (title, message, showMessage)
    }
    
    class func showSimpleErrorMessage(viewController viewController: UIViewController, messageType: String, messageSubType: String, completion: (() -> ())?) {
        
        var showMessage: Bool = true
        var title: String = ""
        var message: String = ""
        
        (title, message, showMessage) = AlertClass.convertMessage(messageType: messageType, messageSubType: messageSubType)
        
        if showMessage {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                let titleFont = [NSFontAttributeName: UIFont(name: "IRANYekanMobile-Bold", size: 16.0)!]
                let messageFont = [NSFontAttributeName: UIFont(name: "IRANYekanMobile-Light", size: 12.0)!]
                
                let titleAttrString = NSMutableAttributedString(string: title, attributes: titleFont as [String: AnyObject])
                let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont as [String: AnyObject])
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alertController.setValue(titleAttrString, forKey: "attributedTitle")
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                
                let action = UIAlertAction(title: "متوجه شدم", style: .Default, handler: { (action) in
                    if let completeHandler = completion {
                        completeHandler()
                    }
                })
                
                let actionFont = [NSFontAttributeName: UIFont(name: "IRANYekanMobile-Bold", size: 12.0)!]
                let actionAttrString = NSMutableAttributedString(string: "متوجه شدم", attributes: actionFont as [String: AnyObject])
                
                let a = action.valueForKey("__representer")
                print("--> \(a)")
                if let label = action.valueForKey("__representer")?.valueForKey("label") as? UILabel {
                    label.attributedText = actionAttrString
                }
                
                alertController.addAction(action)
                viewController.presentViewController(alertController, animated: true) {
                }
            })
        }
    }
    
    class func showTopMessage(viewController viewController: UIViewController, messageType: String, messageSubType: String, type: String, completion: (() -> ())?) {
        
        let (_, message, showMessage) = AlertClass.convertMessage(messageType: messageType, messageSubType: messageSubType)
        
        if showMessage == true {
            let view = MessageView.viewFromNib(layout: .MessageViewIOS8)
            view.configureDropShadow()
            view.titleLabel?.font = UIFont(name: "IRANYekanMobile-Bold", size: 13)!
            view.titleLabel?.textAlignment =  .Center

            var config = SwiftMessages.Config()
            config.presentationStyle = .Top
            config.preferredStatusBarStyle = UIStatusBarStyle.Default
            config.duration = .Seconds(seconds: 5)
            config.interactiveHide = true

            switch type {
            case "warning":
                view.configureTheme(.Warning, iconStyle: .Subtle)
                view.configureContent(title: message, body: "")
            case "success":
                view.configureTheme(.Success, iconStyle: .Subtle)
                view.configureContent(title: message, body: "")
            case "error":
                view.configureTheme(.Error, iconStyle: .Subtle)
                view.configureContent(title: message, body: "")
            default:
                view.configureTheme(.Info)
                view.backgroundColor = UIColor(netHex: 0xEEEEEE, alpha: 1.0)
                //view.titleLabel?.textColor = UIColor.whiteColor()
                view.configureContent(title: message, body: nil, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
            }
            
            SwiftMessages.show(config: config, view: view)
        }
    }
    
    class func showLoadingMessage(viewController viewController: UIViewController) -> MBProgressHUD {
            let hud = MBProgressHUD.showHUDAddedTo(viewController.view, animated: true)
            hud.activityIndicatorColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
            hud.animationType = .Fade
            hud.mode = .Indeterminate
            hud.label.text = "حوصله نمایید ..."
            hud.label.font = UIFont(name: "IRANYekanMobile-Bold", size: 14)
            hud.dimBackground = true
            hud.bezelView.style = .Blur
            hud.bezelView.backgroundColor = UIColor.whiteColor()
            hud.backgroundView.style = .Blur
            return hud
    }

    class func showUpdatingMessage(viewController viewController: UIViewController) -> MBProgressHUD {
        let hud = MBProgressHUD.showHUDAddedTo(viewController.view, animated: true)
        hud.activityIndicatorColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        hud.animationType = .Fade
        hud.mode = .AnnularDeterminate
        hud.label.text = "به روز رسانی ..."
        hud.label.font = UIFont(name: "IRANYekanMobile-Bold", size: 14)
        hud.dimBackground = true
        hud.bezelView.style = .Blur
        hud.bezelView.backgroundColor = UIColor.whiteColor()
        hud.backgroundView.style = .Blur
        return hud
    }
    
    class func hideLoaingMessage(progressHUD progressHUD: MBProgressHUD?) {
        if progressHUD != nil {
            progressHUD!.hideAnimated(true)
        }
    }
    
    class func showAlertMessage(viewController viewController: UIViewController, messageType: String, messageSubType: String, type: String, completion: (() -> ())?) {
        
        let (title, message, showMessage) = AlertClass.convertMessage(messageType: messageType, messageSubType: messageSubType)
        
        if showMessage == true {
            let alert = FCAlertView()
            alert.showAlertInView(viewController, withTitle: title, withSubtitle: message, withCustomImage: nil, withDoneButtonTitle: "متوجه شدم", andButtons: nil)
            alert.animateAlertInFromTop = true
            alert.animateAlertOutToBottom = true
            alert.doneButtonTitleColor = UIColor.whiteColor()
            alert.hideSeparatorLineView = true
            alert.bounceAnimations = true

            if let compl = completion {
                alert.doneActionBlock({
                    compl()
                })
            }

            switch type {
            case "success":
                alert.makeAlertTypeSuccess()
            case "error":
                alert.makeAlertTypeWarning()
            default:
                alert.makeAlertTypeCaution()
            }
        }
    }

    class func showAlertMessageCustom(viewController viewController: UIViewController, title: String, message: String, yesButtonTitle: String, noButtonTitle: String, completion: (() -> ())?) {
        
        let alert = FCAlertView()
        alert.showAlertInView(viewController, withTitle: title, withSubtitle: message, withCustomImage: nil, withDoneButtonTitle: yesButtonTitle, andButtons: nil)
        alert.addButton(noButtonTitle, withActionBlock: nil)
        alert.animateAlertInFromTop = true
        alert.animateAlertOutToBottom = true
        alert.doneButtonTitleColor = UIColor.whiteColor()
        alert.hideSeparatorLineView = true
        alert.bounceAnimations = true
        
        alert.makeAlertTypeWarning()
        
        if let compl = completion {
            alert.doneActionBlock({
                compl()
            })
        }
    }
}
