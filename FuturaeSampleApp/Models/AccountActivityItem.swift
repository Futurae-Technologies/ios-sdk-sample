//
//  AccountActivityItem.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 27.2.25.
//

import SwiftUI
import FuturaeKit

struct AccountActivityItem: Identifiable {
    let id: String
    let activity: FTRAccountActivity
    
    var title: String {
        "\(activity.details.type ?? "Unknown") (\(activity.details.factor) - \(activity.details.result ?? ""))"
    }
    
    var image: ImageAsset {
        activity.details.result == "allow" ? ImageAsset.success : ImageAsset.error
    }
    
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(activity.timestamp))
    }
}
