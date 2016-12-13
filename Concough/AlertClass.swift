//
//  AlertClass.swift
//  Concough
//
//  Created by Owner on 2016-12-12.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import UIKit

class AlertClass {
    class func showSimpleErrorMessage(viewController viewController: UIViewController, messageType: String, messageSubType: String, completion: (() -> ())?) {
        
        var showMessage: Bool = true
        var title: String?
        var message: String?
        
        switch messageType {
        case "Form":
            switch messageSubType {
            case "EmptyFields":
                title = "خطا"
                message = "لطفا همه فیلدها را پر نمایید"
            case "NotSameFields":
                title = "خطا"
                message = "مقادیر وارد شده باید یکسان باشند"
            default:
                showMessage = false
            }
        case "ActionResult":
            switch messageSubType {
            case "ResendCodeSuccess":
                title = "پیغام"
                message = "کد فعالسازی مجددا ارسال شد"
                
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
                message = "حساب کاربری شما صحیح نمی باشد"
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
            default:
                showMessage = false
            }
        case "HTTPError":
            switch messageSubType {
            case "UnAuthorized":
                title = "خطای دسترسی"
                message = "اطلاعات وارد شده صحیح نمی باشد."
            case "ForbiddenAccess":
                title = "خطای دسترسی"
                message = "این دسترسی برای شما تعریف نشده است."
            case "Unknown":
                fallthrough
            case "NetworkError":
                title = "خطای دسترسی"
                message = "برقراری ارتباط با سرور مقدور نیست." + "\n" + "مجددا سعی نمایید"
            default:
                showMessage = false
            }
        default:
            showMessage = false
        }
        
        if showMessage {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                let alertController = UIAlertController(title: title!, message: message!, preferredStyle: .Alert)
                let action = UIAlertAction(title: "متوجه شدم", style: .Default, handler: nil)
                alertController.addAction(action)
                viewController.presentViewController(alertController, animated: true) {
                    if let completeHandler = completion {
                        completeHandler()
                    }
                }
            })
        }
    }
}