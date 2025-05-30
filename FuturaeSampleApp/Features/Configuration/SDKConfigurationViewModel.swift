//
//  SDKConfigurationViewModel.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 28.2.25.
//


import Foundation
import FuturaeKit

final class SDKConfigurationViewModel: ObservableObject {
    let prefs: GlobalPreferences
    let mode: SDKConfigMode
    
    @Published var sdkConfigData: SDKConfigurationData = .default
    @Published var isLoading = false
    @Published var alertMessage: (title: String, message: String)? = nil
    
    @Published var pin: String? = nil
    
    init(prefs: GlobalPreferences, mode: SDKConfigMode) {
        self.prefs = prefs
        self.mode = mode
        self.sdkConfigData = prefs.sdkConfigData
    }
    
    func launchSDK() {
        let config = sdkConfigData.ftrConfig
        do {
            FuturaeService.client.enableLogging()
            try FuturaeService.client.launch(config: config)
            prefs.save(sdkConfigData: sdkConfigData)
            prefs.saveBool(.launchSDK, value: true)
        } catch {
            alertMessage = (title: String.error, message: error.localizedDescription)
        }
    }
    
    func updateConfiguration() {
        let config = sdkConfigData.ftrConfig
        
        Task {
            do {
                try await FuturaeService.client.updateSDKConfig(appGroup: config.appGroup, keychainConfig: config.keychain).execute()
                
                await MainActor.run {
                    prefs.save(sdkConfigData: sdkConfigData)
                    self.alertMessage = (title: String.success, message: "Configuration updated")
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = (title: String.error, message: error.localizedDescription)
                }
            }
        }
    }
    
    func switchLockConfiguration() {
        let config = sdkConfigData.ftrConfig
        
        if config.lockConfiguration.type == .sdkPinWithBiometricsOptional {
            guard let pin = pin, !pin.isEmpty else {
                alertMessage = (String.error, "PIN cannot be empty")
                return
            }
            
            isLoading = true
        }
        
        Task {
            do {
                let parameters: SwitchLockParameters
                
                switch config.lockConfiguration.type {
                case .none:
                    parameters = .with(newLockConfiguration: config.lockConfiguration)
                case .biometricsOnly:
                    parameters = .with(biometricsPrompt: "Unlock with biometrics", newLockConfiguration: config.lockConfiguration)
                case .biometricsOrPasscode:
                    parameters = .with(biometricsOrPasscodePrompt: "Unlock with biometrics or passcode", newLockConfiguration: config.lockConfiguration)
                case .sdkPinWithBiometricsOptional:
                    parameters = .with(sdkPin: pin!, newLockConfiguration: config.lockConfiguration)
                }
                
                try await FuturaeService.client.switchToLockConfiguration(parameters).execute()
                
                await MainActor.run {
                    prefs.save(sdkConfigData: sdkConfigData)
                    self.isLoading = false
                    self.alertMessage = (title: String.success, message: "Lock configuration updated")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.alertMessage = (title: String.error, message: error.localizedDescription)
                }
            }
        }
    }
    
    func checkDataExists() {
        let config = sdkConfigData.ftrConfig
        
        let exists = FuturaeService.client.checkDataExists(forAppGroup: config.appGroup,
                                               keychainConfig: config.keychain,
                                               lockConfiguration: config.lockConfiguration)
        
        self.alertMessage = (title: "SDK data exists", message: "\(exists)")
    }
}
