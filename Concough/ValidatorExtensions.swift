//
//  ValidatorExtensions.swift
//  Concough
//
//  Created by Owner on 2016-12-04.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", EMAIL_VALIDATOR_REGEX)
        let result = emailTest.evaluateWithObject(self)
        return result
    }
    
//    var isValidUsername: Bool {
//        let usernameTest = NSPredicate(format: "SELF MATCHES %@", USERNAME_VALIDATOR_REGEX)
//        let result = usernameTest.evaluateWithObject(self)
//        return result
//    }
    
    var isValidPhoneNumber: Bool {
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", PHONE_NUMBER_VALIDATOR_REGEX)
        let result = usernameTest.evaluateWithObject(self)
        return result
    
    }
}
