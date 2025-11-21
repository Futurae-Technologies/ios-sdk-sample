//
//  AppRoute.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 27.2.25.
//

import SwiftUI
import FuturaeKit

enum AppRoute {
    case auth(type: AuthApprovalType)
    case enroll(type: EnrollType)
    case migration
    case unlock(callback: (() -> Void)?)
    case pinInput(title: String, callback: ((String?) -> Void)?)
    case usernamelessSelector(sessionToken: String, redirect: String?)
    
    func sameTypeAs(_ route: AppRoute) -> Bool {
        switch (self, route) {
        case (.auth, .auth),
             (.enroll, .enroll),
             (.migration, .migration),
             (.unlock, .unlock),
             (.pinInput, .pinInput),
             (.usernamelessSelector, .usernamelessSelector):
            return true
        default:
            return false
        }
    }
    
    var requiresUnlock: Bool {
        switch self {
        case .auth:
            return true
        default:
            return false
        }
    }

}

enum AuthApprovalType {
    case onlineQR(qrCode: String)
    case offlineQR(parameters: OfflineQRCodeParameters)
    case usernameless(qrCode: String, userId: String)
    case usernamelessUrl(sessionToken: String, userId: String, redirect: String?)
    case pushAuth(sessionId: String, userId: String, multiNumberedChallenge: [Int]?)
    case url(sessionToken: String, userId: String, redirect: String?)
}

enum EnrollType {
    case shortCode(code: String)
    case activationCode(code: String)
}

