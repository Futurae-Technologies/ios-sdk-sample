//
//  Notifications.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 27.2.25.
//

import SwiftUI

extension Notification.Name {
    static let appRouteChanged = Notification.Name("appRouteChanged")
    static let accountsChanged = Notification.Name("accountsChanged")
    static let authenticationProcessed = Notification.Name("authenticationProcessed")
    static let qrTabRequested = Notification.Name("qrTabRequested")
}
