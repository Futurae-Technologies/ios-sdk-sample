//
//  AccountItem.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//

import SwiftUI
import FuturaeKit

struct AccountItem: Identifiable {
    let id: String
    let account: FTRAccount
    var serviceName: String
    var username: String
    var serviceLogo: String?
    
    var totp: String
    var remainingSecs: Int
}
