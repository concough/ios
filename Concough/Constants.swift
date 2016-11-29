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
let API_VERSION = "v1"

// Host Urls
let BASE_URL = "http://192.168.1.15:8000/api/"
let MEDIA_CLASS_NAME = "media"
let ACTIVITY_CLASS_NAME = "activities"
let OAUTH_CLASS_NAME = "oauth"


// Cache Configurations
let MEDIA_CACHE_SIZE = 1024 * 1024 * 30
let MEDIA_CACHE_COUNT = 200

// OAuth Settings
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
