//
//  GlobalPreferences.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 28.2.25.
//


import SwiftUI

final class GlobalPreferences: ObservableObject {
    static let shared = GlobalPreferences()
    
    @Published var sdkConfigData: SDKConfigurationData = .default
    @Published var launchSDK: Bool = true
    @Published var flowBinding = false
    @Published var verificationCodeType = VerificationCodeType.default
    @Published var sdkPinBiometrics = false
    @Published var sessionInfoType = SessionInfoType.protected
    @Published var collections = false
    @Published var collectionsAuthentication = false
    @Published var collectionsMigration = false
    @Published var collectionsThreshold: Double = 10
    @Published var floatingButton = true
    @Published var unlockScreenWhenLocked = true
    @Published var unlockScreenBeforeLockedOperation = true
    
    private init() {
        load()
    }
    
    func load() {
        guard let data = UserDefaults.custom.data(forKey: UserDefaultsKey.sdkConfig.rawValue),
              let decoded = try? JSONDecoder().decode(SDKConfigurationData.self, from: data) else {
            return
        }
        self.sdkConfigData = decoded
        
        self.launchSDK = sdkConfigData.saveLaunch ? (loadBool(.launchSDK) ?? false) : false
        
        self.collections = loadBool(.collections) ?? false
        self.collectionsAuthentication = loadBool(.collectionsAuthentication) ?? false
        self.collectionsMigration = loadBool(.collectionsMigration) ?? false
        self.collectionsThreshold = loadDouble(.collectionsThreshold) ?? 10
        
        self.sdkPinBiometrics = loadBool(.sdkPinBiometrics) ?? false
        
        self.flowBinding = loadBool(.flowBinding) ?? false
        
        self.floatingButton = loadBool(.floatingButton) ?? true
        self.unlockScreenWhenLocked = loadBool(.unlockScreenWhenLocked) ?? true
        self.unlockScreenBeforeLockedOperation = loadBool(.unlockScreenBeforeLockedOperation) ?? true
        
        if let type = UserDefaults.custom.object(forKey: UserDefaultsKey.verificationCodeType.rawValue) as? Int, let verificationType = VerificationCodeType(rawValue: type) {
            self.verificationCodeType = verificationType
        }
        
        if let sessionType = UserDefaults.custom.object(forKey: UserDefaultsKey.sessionInfoType.rawValue) as? Int, let sessionInfoType = SessionInfoType(rawValue: sessionType) {
            self.sessionInfoType = sessionInfoType
        }
    }
    
    func save(sdkConfigData: SDKConfigurationData, userDefaults: Bool = true) {
        self.sdkConfigData = sdkConfigData
        
        if userDefaults {
            if let encoded = try? JSONEncoder().encode(sdkConfigData) {
                UserDefaults.custom.set(encoded, forKey: UserDefaultsKey.sdkConfig.rawValue)
            }
        }
    }
    
    func save(_ type: VerificationCodeType) {
        self.verificationCodeType = type
        UserDefaults.custom.set(type.rawValue, forKey: UserDefaultsKey.verificationCodeType.rawValue)
    }
    
    func save(sessionType: SessionInfoType) {
        self.sessionInfoType = sessionType
        UserDefaults.custom.set(sessionType.rawValue, forKey: UserDefaultsKey.sessionInfoType.rawValue)
    }
    
    func saveBool(_ key: UserDefaultsKey, value: Bool, userDefaults: Bool = true) {
        switch key {
        case .launchSDK:
            self.launchSDK = value
        case .collections:
            self.collections = value
        case .collectionsAuthentication:
            self.collectionsAuthentication = value
        case .collectionsMigration:
            self.collectionsMigration = value
        case .flowBinding:
            self.flowBinding = value
        case .sdkPinBiometrics:
            self.sdkPinBiometrics = value
        case .floatingButton:
            self.floatingButton = value
        case .unlockScreenWhenLocked:
            self.unlockScreenWhenLocked = value
        case .unlockScreenBeforeLockedOperation:
            self.unlockScreenBeforeLockedOperation = value
        default:
            break
        }
        
        if userDefaults {
            UserDefaults.custom.set(value, forKey: key.rawValue)
        }
    }
    
    func saveDouble(_ key: UserDefaultsKey, value: Double) {
        switch key {
            case .collectionsThreshold:
                self.collectionsThreshold = value
            default:
                break
       }
    }
    
    func loadBool(_ key: UserDefaultsKey) -> Bool? {
        UserDefaults.custom.object(forKey: key.rawValue) as? Bool
    }
    
    func loadDouble(_ key: UserDefaultsKey) -> Double? {
        UserDefaults.custom.object(forKey: key.rawValue) as? Double
    }
}

enum UserDefaultsKey: String {
    case sdkConfig
    case launchSDK
    
    case sessionInfoType
    case verificationCodeType
    case sdkPinBiometrics
    
    case flowBinding
    case collections
    case collectionsAuthentication
    case collectionsMigration
    case collectionsThreshold
    
    case floatingButton
    case unlockScreenWhenLocked
    case unlockScreenBeforeLockedOperation
}


extension UserDefaults {
    static var custom: UserDefaults {
        .init(suiteName: SDKConstants.appGroup)!
    }
}
