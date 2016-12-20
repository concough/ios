//
//  JwtHandler.swift
//  Concough
//
//  Created by Owner on 2016-12-20.
//  Copyright © 2016 Famba. All rights reserved.
//

import Foundation
import SwiftyJSON

class JwtHandler {
    class func getPayloadData(data: String) -> JSON? {
        let splittedData = data.componentsSeparatedByString(".")
        let jsonString: NSData = splittedData[1].base64Decoded()
        let json = JSON(data: jsonString)
        return json
    }
}
