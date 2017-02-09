//
//  UrlMakerSingleton.swift
//  Concough
//
//  Created by Owner on 2016-11-24.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation

class UrlMakerSingleton {
    private var _base_url: String!
    private var _api_version: String!
    private var _jwt_prefix: String!
    
    private var _media_class_name: String!
    private var _activity_class_name: String!
    private var _oauth_class_name: String!
    private var _jauth_class_name: String!
    private var _auth_class_name: String!
    private var _profile_class_name: String!
    private var _archive_class_name: String!
    private var _entrance_class_name: String!
    private var _purchased_class_name: String!
    private var _product_class_name: String!
    private var _basket_class_name: String!
    
    static let sharedInstance = UrlMakerSingleton()
    
    private init() {
        // in future must be read from user defaults
        self._base_url = BASE_URL
        self._api_version = API_VERSION
        self._jwt_prefix = JWT_URL_PREFIX
        self._media_class_name = MEDIA_CLASS_NAME
        self._activity_class_name = ACTIVITY_CLASS_NAME
        self._oauth_class_name = OAUTH_CLASS_NAME
        self._jauth_class_name = JAUTH_CLASS_NAME
        self._auth_class_name = AUTH_CLASS_NAME
        self._profile_class_name = PROFILE_CLASS_NAME
        self._archive_class_name = ARCHIVE_CLASS_NAME
        self._entrance_class_name = ENTRANCE_CLASS_NAME
        self._purchased_class_name = PURCHASED_CLASS_NAME
        self._product_class_name = PRODUCT_CLASS_NAME
        self._basket_class_name = BASKET_CLASS_NAME
    }
    
    internal func getAboutUrl() -> String? {
        var fullPath:String?
        
        fullPath = "\(self._base_url)" + "about/"
        return fullPath
    }

    internal func getHelpUrl() -> String? {
        var fullPath:String?
        
        fullPath = "\(self._base_url)" + "help/"
        return fullPath
    }

    internal func getReportBugUrl() -> String? {
        var fullPath:String?
        let functionName = "report_bug"
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(functionName)/"
        }
        return fullPath
    }
    
    internal func getInviteFriendsUrl() -> String? {
        var fullPath:String?
        let functionName = "invite"
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(functionName)/"
        }
        return fullPath
        
    }
    
    internal func mediaUrlFor(type: String, mediaId: AnyObject) -> String? {
        var fullPath:String?
        let functionName = "\(type)/\(mediaId)"
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._media_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._media_class_name)/\(functionName)/"
        }
        return fullPath
    }

    internal func mediaUrlForQuestion(uniqueId uniqueId: String, mediaId: AnyObject) -> String? {
        var fullPath:String?
        let functionName = "entrance/\(uniqueId)/q/\(mediaId)"
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._media_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._media_class_name)/\(functionName)/"
        }
        return fullPath
    }

    internal func activityUrl() -> String? {
        var fullPath:String?
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._activity_class_name)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._activity_class_name)/"
        }
        return fullPath
    }
    
    internal func activityUrlWithNext(next: String) -> String? {
        if var path = UrlMakerSingleton.sharedInstance.activityUrl() {
            path += "next/\(next)/"
            return path
        }
        return nil
    }
    
    internal func tokenUrl() -> String? {
        let functionName = "token"
        let fullPath = "\(self._base_url)\(self._oauth_class_name)/\(functionName)/"
        return fullPath
    }
    
    internal func jwtTokenUrl() -> String? {
        let functionName = "token"
        let fullPath = "\(self._base_url)\(self._api_version)/\(self._jauth_class_name)/\(functionName)/"
        return fullPath
    }

    internal func jwtRefreshTokenUrl() -> String? {
        let functionName = "refresh_token"
        let fullPath = "\(self._base_url)\(self._api_version)/\(self._jauth_class_name)/\(functionName)/"
        return fullPath
    }

    internal func jwtVerifyTokenUrl() -> String? {
        let functionName = "verify"
        let fullPath = "\(self._base_url)\(self._api_version)/\(self._jauth_class_name)/\(functionName)/"
        return fullPath
    }
    
    internal func preSignupUrl() -> String? {
        var fullPath:String?
        let functionName = "pre_signup"

        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._auth_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._auth_class_name)/\(functionName)/"
        }

        return fullPath
    }

    internal func checkUsername() -> String? {
        var fullPath:String?
        let functionName = "check_username"

        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._auth_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._auth_class_name)/\(functionName)/"
        }
        
        return fullPath
    }
    
    internal func signupUrl() -> String? {
        var fullPath:String?
        let functionName = "signup"

        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._auth_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._auth_class_name)/\(functionName)/"
        }
        return fullPath
    }
    
    internal func forgotPassword() -> String? {
        var fullPath:String?
        let functionName = "forgot_password"
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._auth_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._auth_class_name)/\(functionName)/"
        }
        return fullPath
    }

    internal func resetPassword() -> String? {
        var fullPath:String?
        let functionName = "reset_password"

        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._auth_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._auth_class_name)/\(functionName)/"
        }
        return fullPath
    }

    internal func changePassword() -> String? {
        var fullPath:String?
        let functionName = "change_password"
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._auth_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._auth_class_name)/\(functionName)/"
        }
        return fullPath
    }
    
    internal func profileUrl() -> String? {
        var fullPath:String?
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._profile_class_name)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._profile_class_name)/"
        }
        return fullPath
    }

    internal func editGradeProfileUrl() -> String? {
        var fullPath:String?
        let functionName = "edit/grade"
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._profile_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._profile_class_name)/\(functionName)"
        }
        return fullPath
    }
 
    internal func archiveEntranceTypesUrl() -> String? {
        var fullPath: String?
        let functionName = "entrance/types"
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._archive_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._archive_class_name)/\(functionName)/"
        }
        return fullPath
    }

    internal func archiveEntranceGroupsUrl(etypeId etypeId: Int) -> String? {
        var fullPath: String?
        let functionName = "entrance/groups/\(etypeId)"
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._archive_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._archive_class_name)/\(functionName)/"
        }
        return fullPath
    }
    
    internal func archiveEntranceSetsUrl(egroupId egroupId: Int) -> String? {
        var fullPath: String?
        let functionName = "entrance/sets/\(egroupId)"
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._archive_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._archive_class_name)/\(functionName)/"
        }
        return fullPath
    }

    internal func archiveEntrancesUrl(esetId esetId: Int) -> String? {
        var fullPath: String?
        let functionName = "entrance/\(esetId)"
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._archive_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._archive_class_name)/\(functionName)/"
        }
        return fullPath
    }
    
    internal func getEnranceUrl(uniqueId uniqueId: String) -> String? {
        var fullPath: String?
        let functionName = "\(uniqueId)"
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._entrance_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._entrance_class_name)/\(functionName)/"
        }
        return fullPath        
    }
    
    internal func getEntrancePackageDataInitUrl(uniqueId uniqueId: String) -> String? {
        var fullPath: String?
        let functionName = "\(uniqueId)/data/init"
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._entrance_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._entrance_class_name)/\(functionName)/"
        }
        return fullPath
    }

    internal func getEntrancePackageImageUrl(uniqueId uniqueId: String, packageId: String) -> String? {
        var fullPath: String?
        let functionName = "\(uniqueId)/package/\(packageId)"
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._entrance_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._entrance_class_name)/\(functionName)/"
        }
        return fullPath
    }
    
    private func getPurchasedUrl(functionName functionName: String) -> String? {
        var fullPath: String?
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._purchased_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._purchased_class_name)/\(functionName)/"
        }
        return fullPath
    }
    
    internal func getPurchasedListUrl() -> String? {
        let functionName = "list"
        return self.getPurchasedUrl(functionName: functionName)
    }
    
    internal func getPurchasedForEntranceUrl(uniqueId uniqueId: String) -> String? {
        let functionName = "entrance/\(uniqueId)"
        return self.getPurchasedUrl(functionName: functionName)
    }

    internal func getPurchasedUpdateDownloadTimesUrl(uniqueId uniqueId: String) -> String? {
        let functionName = "entrance/\(uniqueId)/update"
        return self.getPurchasedUrl(functionName: functionName)
    }
    
    private func getProductUrl(functionName functionName: String) -> String? {
        var fullPath: String?
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._product_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._product_class_name)/\(functionName)/"
        }
        return fullPath        
    }
    
    internal func getProductDataForEntranceUrl(uniqueId uniqueId: String) -> String? {
        let functionName = "entrance/\(uniqueId)/sale"
        return self.getProductUrl(functionName: functionName)
    }

    internal func getProductStatForEntranceUrl(uniqueId uniqueId: String) -> String? {
        let functionName = "entrance/\(uniqueId)/stat"
        return self.getProductUrl(functionName: functionName)
    }
    
    private func getBasketUrl(functionName functionName: String) -> String? {
        var fullPath: String?
        
        if OAUTH_METHOD == "jwt" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._jwt_prefix)/\(self._basket_class_name)/\(functionName)/"
        } else if OAUTH_METHOD == "oauth" {
            fullPath = "\(self._base_url)\(self._api_version)/\(self._basket_class_name)/\(functionName)/"
        }
        return fullPath
    }
    
    internal func getCreateBasketUrl() -> String? {
        let functionName = "create"
        return self.getBasketUrl(functionName: functionName)
    }
    
    internal func getAddEntranceToBasketUrl(basketId basketId: String) -> String? {
        let functionName = "\(basketId)/add"
        return self.getBasketUrl(functionName: functionName)
    }
    
    internal func getRemoveSaleFormBasketUrl(basketId basketId: String, saleId: Int) -> String? {
        let functionName = "\(basketId)/sale/\(saleId)"
        return self.getBasketUrl(functionName: functionName)
    }

    internal func getLoadBasketItemsUrl() -> String? {
        let functionName = "list"
        return self.getBasketUrl(functionName: functionName)
    }
    
    internal func getCheckoutBasketUrl(basketId basketId: String) -> String? {
        let functionName = "\(basketId)/checkout"
        return self.getBasketUrl(functionName: functionName)
    }
}
