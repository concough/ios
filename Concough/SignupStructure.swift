//
//  SignupStructure.swift
//  Concough
//
//  Created by Owner on 2016-12-06.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

struct SignupStructure {
    var username: String?
    var password: String?
//    var email: String?
    var preSignupId: Int?
}

struct SignupMoreInfoStruct {
    var firstname: String?
    var lastname: String?
    var grade: String?
    var gradeString: String?
    var gender: String?
    var birthday: NSDate?
}

enum GenderEnum: String {
    case Male = "M"
    case Female = "F"
    case Other = "O"
}

enum GradeTypeEnum: String {
    case BE = "BE"
    case ME = "ME"
    
    static let allValues = [BE, ME]
    
    func toString() -> String {
        switch self {
        case .BE:
            return "سراسری"
        case .ME:
            return "کارشناسی ارشد"
        }
    }
    
    static func selectWithString(value: String) -> GradeTypeEnum {
        switch value {
        case "ME":
            return .ME
        default:
            return .BE
        }
    }
}

