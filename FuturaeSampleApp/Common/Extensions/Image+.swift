//
//  Image+.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 12.3.25.
//

import SwiftUI

extension Image {
    init(_ asset: ImageAsset) {
        self.init(asset.rawValue)
    }
}

enum ImageAsset: String {
    case futurae = "Futurae"
    case account = "Account"
    case more = "More"
    case qrScanner = "QRScanner"
    case manualEntry = "ManualEntry"
    case accounts = "Accounts"
    case restore = "Restore"
    case close = "Close"
    case closeLarge = "CloseLarge"
    case success = "Success"
    case error = "Error"
    case successLarge = "SuccessLarge"
    case errorLarge = "ErrorLarge"
    case noActivity = "NoActivity"
    case arrow = "Arrow"
    case back = "Back"
    case alert = "Alert"
    case qr = "QR"
    case manualEntryImage = "ManualEntryImage"
    case selectAccount = "SelectAccount"
    case approve = "Approve"
    case decline = "Decline"
    case restoreAccounts = "RestoreAccounts"
    case poweredBy = "PoweredBy"
    case link = "Link"
}
