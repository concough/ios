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
            case "PhoneVerifyWrong":
                title = "خطا"
                message = "فرمت شماره همراه اشتباه است"
                
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
                message = "خرید با موفقیت انجام گردید. جهت دانلود به بخش کتابخانه من مراجعه نمایید."
            case "DownloadSuccess":
                title = "پیغام"
                message = "دانلود با موفقیت انجام گردید"
            case "DownloadFailed":
                title = "پیغام"
                message = "دانلود با خطا مواجه گردید"
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
                message = "داده های شما با موفقیت پاک گردید"
            case "ScreenshotTaken":
                title = "پیغام"
                message = "خواهشمندیم به منظور حفظ حقوق نرم افزار از گرفتن هرگونه اسکرین شات خودداری بفرمایید"
            case "BlockedByScreenshot":
                title = "پیغام"
                message = "دسترسی به این آیتم محدود شد"
            case "BlockedByScreenshotTime":
                title = "پیغام"
                message = "دسترسی به این آیتم تا %%% به دلیل عدم رعایت قوانین مقدور نمی باشد"
            default:
                showMessage = false
            }
        case "DeviceInfoError":
            switch messageSubType {
            case "AnotherDevice":
                title = "خطا"
                message = "اکانت شما توسط دستگاه دیگری در حال استفاده می باشد، در صورتی که به دستگاه فعال دسترسی دارید گزینه 'قفل دستگاه' در تنظیمات کنکوق را فشار دهید و در غیر اینصورت از دکمه بازیایی گذرواژه همین دستگاه استفاده نمایید"
            case "DeviceNotRegistered":
                title = "خطا"
                message = "دستگاه شما با این اکانت ثبت نشده است"
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
                message = "اطلاعات برای نمایش ناموجود است"
            default:
                showMessage = false
            }
        case "EntranceResult":
            switch messageSubType {
            case "EntranceNotExist":
                title = "خطا"
                message = "آزمون درخواستی موجود نمی باشد"
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
            case "PaymentProviderError":
                title = "خطا"
                message = "خطا در اتصال به بانک"
            case "NotPaymnetRecord":
                title = "خطا"
                message = "پرداختی ثبت نشده است"
            case "CheckoutPending":
                title = "خطا"
                message = "وضعیت سبد خرید قبلی شما در حالت معلق است، آن را نهایی نمایید"
            case "CheckoutError":
                title = "خطا"
                message = "پرداخت نا موفق بود! در که صورتی که مبلغ از حساب شما کسر شده است حداکثر تا یک روز کاری به حسابتان باز خواهد گشت"
            case "MustCheckoutLast":
                title = "خطا"
                message = "ابتدا پرداخت قبلی خود را نهایی نمایید"
            default:
                showMessage = false
            }
        case "AuthProfile":
            switch messageSubType {
            case "ExistUsername":
                title = "خطا"
                message = "این شماره همراه قبلا انتخاب شده است"
            case "UserNotExist":
                title = "خطا"
                message = "لطفا ابتدا ثبت نام کنید"
            case "PreAuthNotExist":
                title = "خطا"
                message = "لطفا مجددا تقاضای کد نمایید"
            case "FieldTooSmall":
                title = "خطا"
                message = "طول فیلد وارد شده کوتاه است"
            case "MismatchPassword":
                title = "خطا"
                message = "هر دو فیلد گذرواژه باید یکی باشند"
            case "PassCannotChange":
                title = "خطا"
                message = "امکان تغییر گذرواژه وجود ندارد"
            case "SMSSendError":
                title = "خطا"
                message = "ارسال پیامک با خطا مواجه شد. مجددا سعی نمایید"
            case "CallSendError":
                title = "خطا"
                message = "تماس صوتی با خطا مواجه شد. مجددا سعی نمایید"
            case "ExceedToday":
                title = "خطا"
                message = "ظرقیت ارسال پیامک امروز شما به پایان رسید"
            case "ExceedCallToday":
                title = "خطا"
                message = "لطفا فردا سعی نمایید. ظرفیت امروز شما برای ارسال پیامک و یا تماس صوتی به پایان رسید."
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
        case "DeviceAction":
            switch messageSubType {
            case "UpdateApp":
                title = "نسخه جدید نرم افزار"
                message = "نسخه %s منتشر شده است"
            default:
                showMessage = false
            }
        default:
            showMessage = false
        }
     
        return (title, message, showMessage)
    }
        
    class func showTopMessage(viewController viewController: UIViewController, messageType: String, messageSubType: String, type: String, completion: (() -> ())?) {
        
        let (_, message, showMessage) = AlertClass.convertMessage(messageType: messageType, messageSubType: messageSubType)
        
        if showMessage == true {
            let view = MessageView.viewFromNib(layout: .MessageViewIOS8)
            view.configureDropShadow()
            view.titleLabel?.font = UIFont(name: "IRANSansMobile-Medium", size: 13)!
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
            hud.label.font = UIFont(name: "IRANSansMobile", size: 14)
            hud.dimBackground = true
            hud.bezelView.style = .Blur
            hud.bezelView.backgroundColor = UIColor.whiteColor()
//            hud.backgroundView.style = .SolidColor
//            hud.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
            return hud
    }

    class func showUpdatingMessage(viewController viewController: UIViewController) -> MBProgressHUD {
        let hud = MBProgressHUD.showHUDAddedTo(viewController.view, animated: true)
        hud.activityIndicatorColor = UIColor(netHex: BLUE_COLOR_HEX, alpha: 1.0)
        hud.animationType = .Fade
        hud.mode = .AnnularDeterminate
        hud.label.text = "به روز رسانی ..."
        hud.label.font = UIFont(name: "IRANSansMobile", size: 14)
        hud.dimBackground = true
        hud.bezelView.style = .Blur
        hud.bezelView.backgroundColor = UIColor.whiteColor()
//        hud.backgroundView.style = .SolidColor
//        hud.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        return hud
    }
    
    class func hideLoaingMessage(progressHUD progressHUD: MBProgressHUD?) {
        if progressHUD != nil {
            progressHUD!.hideAnimated(true)
        }
    }
    
    class func showAlertMessage(viewController viewController: UIViewController, messageType: String, messageSubType: String, type: String, completion: (() -> ())?) {
        return AlertClass.showAlertMessageWithParams(viewController: viewController, messageType: messageType, messageSubType: messageSubType, params: nil, type: type, completion: completion)
    }

    class func showAlertMessageWithParams(viewController viewController: UIViewController, messageType: String, messageSubType: String, params: [String]?, type: String, completion: (() -> ())?) {
        
        let (title, message, showMessage) = AlertClass.convertMessage(messageType: messageType, messageSubType: messageSubType)
        
        var msg = message
        if let parameters = params {
            let message_parts = message.componentsSeparatedByString("%%%")
            msg = ""
            for (index, item) in message_parts.enumerate() {
                if index < message_parts.count - 1 {
                    msg += item + parameters[index]
                } else {
                    msg += item
                }
            }
        }
        
        let u = UIImage(named: "logo_white_share")
        
        if showMessage == true {
            let alert = FCAlertView()
            alert.showAlertInView(viewController, withTitle: title, withSubtitle: msg, withCustomImage: u, withDoneButtonTitle: "متوجه شدم", andButtons: nil)
            alert.animateAlertInFromTop = true
            alert.animateAlertOutToBottom = true
            alert.doneButtonTitleColor = UIColor.whiteColor()
            alert.hideSeparatorLineView = true
            alert.bounceAnimations = true
            alert.dismissOnOutsideTouch = false
            
            alert.titleFont = UIFont(name: "IRANSansMobile-Medium", size: 16)!
            alert.subtitleFont = UIFont(name: "IRANSansMobile", size: 12)!
            alert.firstButtonCustomFont = UIFont(name: "IRANSansMobile-Medium", size: 14)!
            alert.secondButtonCustomFont = UIFont(name: "IRANSansMobile-Medium", size: 14)!
            alert.doneButtonCustomFont = UIFont(name: "IRANSansMobile-Medium", size: 14)!
            
            alert.customImageScale = 1.3
            alert.avoidCustomImageTint = true
            
            switch type {
            case "success":
                alert.colorScheme = alert.flatGreen
            case "error":
                alert.colorScheme = alert.flatRed
            case "warning":
                alert.colorScheme = alert.flatOrange
            default:
                alert.colorScheme = alert.flatBlue
            }
            
            if let compl = completion {
                alert.doneActionBlock({
                    compl()
                })
            }
            
        }
    }
    
    
    class func showAlertMessageCustom(viewController viewController: UIViewController, title: String, message: String, yesButtonTitle: String, noButtonTitle: String, completion: (() -> ())?, noCompletion: (() -> ())?) {
        
        let u = UIImage(named: "logo_white_share")
        
        let alert = FCAlertView()
        alert.showAlertInView(viewController, withTitle: title, withSubtitle: message, withCustomImage: u, withDoneButtonTitle: yesButtonTitle, andButtons: nil)
        alert.addButton(noButtonTitle, withActionBlock: noCompletion)
        alert.animateAlertInFromTop = true
        alert.animateAlertOutToBottom = true
        alert.doneButtonTitleColor = UIColor.whiteColor()
        alert.hideSeparatorLineView = true
        alert.dismissOnOutsideTouch = false
        alert.bounceAnimations = true
        
        alert.titleFont = UIFont(name: "IRANSansMobile-Medium", size: 16)!
        alert.subtitleFont = UIFont(name: "IRANSansMobile", size: 12)!
        alert.firstButtonCustomFont = UIFont(name: "IRANSansMobile-Medium", size: 14)!
        alert.secondButtonCustomFont = UIFont(name: "IRANSansMobile-Medium", size: 14)!
        alert.doneButtonCustomFont = UIFont(name: "IRANSansMobile-Medium", size: 14)!

        alert.colorScheme = alert.flatRed
        alert.customImageScale = 1.3
        alert.avoidCustomImageTint = true

        if let compl = completion {
            alert.doneActionBlock({
                compl()
            })
        }
    }
    class func showSuccessMessageCustom(viewController viewController: UIViewController, title: String, message: String, yesButtonTitle: String, noButtonTitle: String, completion: (() -> ())?, noCompletion: (() -> ())?) {

        let u = UIImage(named: "logo_white_share")
        
        let alert = FCAlertView()
        alert.showAlertInView(viewController, withTitle: title, withSubtitle: message, withCustomImage: u, withDoneButtonTitle: yesButtonTitle, andButtons: nil)
        alert.addButton(noButtonTitle, withActionBlock: noCompletion)
        alert.animateAlertInFromTop = true
        alert.animateAlertOutToBottom = true
        alert.doneButtonTitleColor = UIColor.whiteColor()
        alert.hideSeparatorLineView = true
        alert.bounceAnimations = true
        alert.dismissOnOutsideTouch = false
        
        alert.titleFont = UIFont(name: "IRANSansMobile-Medium", size: 16)!
        alert.subtitleFont = UIFont(name: "IRANSansMobile", size: 12)!
        alert.firstButtonCustomFont = UIFont(name: "IRANSansMobile-Medium", size: 14)!
        alert.secondButtonCustomFont = UIFont(name: "IRANSansMobile-Medium", size: 14)!
        alert.doneButtonCustomFont = UIFont(name: "IRANSansMobile-Medium", size: 14)!

        
        alert.colorScheme = alert.flatGreen
        alert.customImageScale = 1.3
        alert.avoidCustomImageTint = true
        
        if let compl = completion {
            alert.doneActionBlock({
                compl()
            })
        }
    }
}
