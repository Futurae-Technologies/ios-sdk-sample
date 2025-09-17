//
//  SDKConfiguration.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 28.2.25.
//


import Foundation
import FuturaeKit

struct SDKConstants {

    static let appGroup = "group.futuraesample"
    static let keychainAccessGroup = "group.futuraesample"
    static let appId = "{TEAMID}.com.futurae.FuturaeSample"
    
    static let sdkId = Bundle.main.infoDictionary?["SDK_ID"] as? String ?? ""
    static let sdkKey = Bundle.main.infoDictionary?["SDK_KEY"] as? String ?? ""
    static let sdkURL = "https://" + (Bundle.main.infoDictionary?["SDK_URL"] as? String  ?? "")
    
    static let ivTeamId = (Bundle.main.infoDictionary?["IV_TEAM_ID"] as? String  ?? "")
    static let ivProduction = (Bundle.main.infoDictionary?["IV_PRODUCTION"] as? String  ?? "") == "production"
}

enum SDKConfigMode {
    case setup
    case switchLock
    case updateConfig
    case checkDataExists
    case view
}

struct SDKConfigurationData: Codable {
    var sdkId: String
    var sdkKey: String
    var baseUrl: String
    var sslPinning: Bool
    
    var useAppGroup: Bool
    var useKeychainAccessGroup: Bool
    
    var lockType: LockType
    var unlockDuration: Double
    var invalidatedByBiometricsChange: Bool
    
    var allowPinChangeWithBiometricUnlock: Bool
    var deactivateBiometricsAfterPinChange: Bool
    
    var keychainAccessibility: KeychainAccessibilityType
    
    var ivEnabled: Bool
    var ivTeamId: String
    var ivProduction: Bool
    var ivBlockingTimeout: Int
    
    static var `default` = SDKConfigurationData(
        sdkId: SDKConstants.sdkId,
        sdkKey: SDKConstants.sdkKey,
        baseUrl: SDKConstants.sdkURL,
        sslPinning: true,
        useAppGroup: true,
        useKeychainAccessGroup: true,
        lockType: .none,
        unlockDuration: 60,
        invalidatedByBiometricsChange: true,
        allowPinChangeWithBiometricUnlock: true,
        deactivateBiometricsAfterPinChange: true,
        keychainAccessibility: .afterFirstUnlockThisDeviceOnly,
        ivEnabled: !SDKConstants.ivTeamId.isEmpty,
        ivTeamId: SDKConstants.ivTeamId,
        ivProduction: SDKConstants.ivProduction,
        ivBlockingTimeout: 5000
    )
    
    var ftrConfig: FTRConfig {
        let data = self
        
        let lockConfiguration = LockConfiguration(
            type: data.lockType.toFTRType,
            unlockDuration: data.unlockDuration,
            invalidatedByBiometricsChange: data.invalidatedByBiometricsChange,
            pinConfiguration: SDKPinConfiguration(
                allowPinChangeWithBiometricUnlock: data.allowPinChangeWithBiometricUnlock,
                deactivateBiometricsAfterPinChange: data.deactivateBiometricsAfterPinChange
            )
        )
        
        let keychainConfig = FTRKeychainConfig(
            accessGroup: data.useKeychainAccessGroup ? SDKConstants.keychainAccessGroup : nil,
            itemsAccessibility: data.keychainAccessibility.toFTRType
        )
        
        
        return FTRConfig(
            sdkId: data.sdkId,
            sdkKey: data.sdkKey,
            baseUrl: data.baseUrl,
            keychain: keychainConfig,
            lockConfiguration: lockConfiguration,
            appGroup: data.useAppGroup ? SDKConstants.appGroup : nil,
            sslPinning: data.sslPinning,
            integrityVerdictConfiguration: data.ivEnabled ? .init(teamID: data.ivTeamId, production: data.ivProduction, blockingIVCollectionTimeoutOnAuthMillis: .init(integerLiteral: ivBlockingTimeout)) : nil
        )
    }
}

enum LockType: Int, CaseIterable, Codable, CustomStringConvertible {
    case none = 1
    case biometricsOnly = 2
    case biometricsOrPasscode = 3
    case sdkPinWithBiometricsOptional = 4
    
    var toFTRType: LockConfigurationType {
        .init(rawValue: rawValue)!
    }
    
    var description: String {
        switch self {
        case .none: return "None"
        case .biometricsOnly: return "Biometrics Only"
        case .biometricsOrPasscode: return "Biometrics or Passcode"
        case .sdkPinWithBiometricsOptional: return "SDK PIN (Biometrics Optional)"
        }
    }
}

enum KeychainAccessibilityType: Int, CaseIterable, Codable, CustomStringConvertible {
    case whenPasscodeSetThisDeviceOnly
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
    
    var toFTRType: FTRKeychainItemAccessibility {
        .init(rawValue: rawValue)!
    }
    
    var description: String {
        switch self {
        case .afterFirstUnlockThisDeviceOnly: return "AfterFirstUnlockThisDeviceOnly"
        case .whenPasscodeSetThisDeviceOnly: return "WhenPasscodeSetThisDeviceOnly"
        case .whenUnlockedThisDeviceOnly: return "WhenUnlockedThisDeviceOnly"
        }
    }
}

enum VerificationCodeType: Int, CaseIterable, Codable, CustomStringConvertible {
    case `default` = 1
    case sdkPin = 2
    case biometrics = 3
    
    var description: String {
        switch self {
            case .default: return "Default"
            case .sdkPin: return "SDK Pin"
            case .biometrics: return "Biometrics"
        }
    }
}

enum SessionInfoType: Int, CaseIterable, Codable, CustomStringConvertible {
    case protected = 1
    case unprotected = 2
    
    var description: String {
        switch self {
            case .protected:
                return "Protected"
            case .unprotected:
                return "Unprotected"
        }
    }
}
