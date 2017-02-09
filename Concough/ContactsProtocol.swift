//
//  ContactsProtocol.swift
//  Concough
//
//  Created by Owner on 2017-02-06.
//  Copyright © 2017 Famba. All rights reserved.
//

import Foundation

protocol ContactsProtocol {
    func contactsSelected(list list: [(fullname: String, email: String)])
}
