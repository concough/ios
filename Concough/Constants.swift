//
//  File.swift
//  Concough
//
//  Created by Owner on 2016-11-22.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import UIKit

// Application Version
let APP_VERSION = 1
let API_VERSION = "v1"
let PRE = "67mnnv^vs7&^v87YrV&hd8bw92bu9b%$$#b8728^%93y6==37yb&BBB6*njs*99__=="
let PRO = "ncdjncdujb"
let array = [7, 11, 13, 15, 17, 19, 23, 29, 31]
var SECRET_KEY: String {
    get {
        let str = array.reverse().map({(element: Int) -> String in
            return "\(element)"
        }).joinWithSeparator("")
        return "\(PRE)\(str)\(PRO)"
    }
}

// Host Urls
//let BASE_URL = "http://192.168.0.21:8000/api/"
let BASE_URL = "https://concough.zhycan.com/api/"
let ABOUT_URL = "https://zhycan.com/concough/fa/"
let HELP_URL = "https://zhycan.com/concough/fa/help/"
let MEDIA_CLASS_NAME = "media"
let ACTIVITY_CLASS_NAME = "activities"
let ARCHIVE_CLASS_NAME = "archive"
let OAUTH_CLASS_NAME = "oauth"
let JAUTH_CLASS_NAME = "jauth"
let AUTH_CLASS_NAME = "auth"
let PROFILE_CLASS_NAME = "profile"
let ENTRANCE_CLASS_NAME = "entrance"
let PURCHASED_CLASS_NAME = "purchased"
let PRODUCT_CLASS_NAME = "product"
let BASKET_CLASS_NAME = "basket"
let DEVICE_CLASS_NAME = "device"
let JWT_URL_PREFIX = "j"

// Cache Configurations
let MEDIA_CACHE_SIZE = 1024 * 1024 * 30
let MEDIA_CACHE_COUNT = 200

// OAuth Settings
let OAUTH_METHOD = "jwt"        // can be "jwt" or "oauth"
let CLIENT_ID = "vKREqBOlXXVZNqWdAGTYio8W6Rhe4SpTAtCZb6Ra"
let CLIENT_PASSWORD = "uAnxNKjqK1b5i0Y3SYpCWnyjORQR14JIpOHchse0alsYpqIVrpy2C9Fu095anIrM6v3yft0pDjO8eGu5G8q5UDs7WjMEqpHUVwg9x6QHrIlW6NR2DZiUJD0njCaqkBaL"

// KeyChain Keys
let OAUTH_TOKEN_KEY = "oauthToken"
let OAUTH_REFRESH_TOKEN_KEY = "oauthRefreshToken"
let OAUTH_TOKEN_TYPE_KEY = "oauthTokenType"
let OAUTH_LAST_ACCESS_KEY = "oauthLastAccess"
let OAUTH_EXPIRES_IN_KEY = "oauthExpiresIn"
let USERNAME_KEY = "authUsername"
let PASSWORD_KEY = "authPassword"
let IDENTIFIER_FOR_VENDOR_KEY = "identifierForVendor"


// Validator Regex
let EMAIL_VALIDATOR_REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
let USERNAME_VALIDATOR_REGEX = "^[A-Za-z0-9][A-Za-z0-9@+-@._]{9,29}$"
let PHONE_NUMBER_VALIDATOR_REGEX = "^(9|09)[0-9]{9}$"


// UI Constants
let BLUE_COLOR_HEX: Int = 0x1007AFF
let RED_COLOR_HEX:Int = 0x960000
let RED_COLOR_HEX_2:Int = 0xDD0000
let GREEN_COLOR_HEX:Int = 0x1008000
let GRAY_COLOR_HEX_1: Int = 0xB7B7B7

// Downloader Settings
let DOWNLOAD_IMAGE_COUNT = 15
let CONNECTION_MAX_RETRY = 3

