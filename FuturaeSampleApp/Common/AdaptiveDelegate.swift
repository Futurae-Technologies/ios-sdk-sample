//
//  AdaptiveDelegate.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 7.3.25.
//

import SwiftUI
import FuturaeKit
import AdaptiveKit

class AdaptiveDelegate: NSObject, FTRAdaptiveSDKDelegate {
    func bluetoothSettingStatus() -> FTRAdaptivePermissionStatus {
        .on
    }
    
    func bluetoothPermissionStatus() -> FTRAdaptivePermissionStatus {
        .on
    }
    
    func locationSettingStatus() -> FTRAdaptivePermissionStatus {
        .on
    }
    
    func locationPermissionStatus() -> FTRAdaptivePermissionStatus {
        .on
    }
    
    func locationPrecisePermissionStatus() -> FTRAdaptivePermissionStatus {
        .on
    }
    
    func networkSettingStatus() -> FTRAdaptivePermissionStatus {
        .on
    }
    
    func networkPermissionStatus() -> FTRAdaptivePermissionStatus {
        .on
    }
    
    func didReceiveUpdate(withCollectedData collectedData: [String : Any]!) {
        AdaptiveDebugStorage.shared().save(collectedData)
    }
}
