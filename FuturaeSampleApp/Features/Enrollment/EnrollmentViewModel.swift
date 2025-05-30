//
//  EnrollmentViewModel.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 27.2.25.
//

import SwiftUI
import FuturaeKit


final class EnrollmentViewModel: ObservableObject {
    @Published var newAccount: FTRAccount? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    @Published var showPinEntryView: Bool = false
    @Published var pin: String? = nil
    
    @Published var showBindingTokenView: Bool = false
    @Published var bindingToken: String? = nil
    
    var prefs = GlobalPreferences.shared
    
    var isSDKPinSet: Bool { FuturaeService.client.activeUnlockMethods.contains(.sdkPin) }
    
    let onDismiss: () -> Void
    let enrollType: EnrollType
        
    init(enrollType: EnrollType, onDismiss: @escaping () -> Void) {
        self.enrollType = enrollType
        self.onDismiss = onDismiss
    }
    
    func processEnrollment() {
        isLoading = true
        
        Task {
            do {
                let parameters = try enrollParameters()
                try await FuturaeService.client.enroll(parameters: parameters).execute()
                
                await MainActor.run {
                    NotificationCenter.default.post(name: .accountsChanged, object: nil)
                }
                
                let accounts = try FuturaeService.client.getAccounts()
                if let lastAccount = accounts.last {
                    await MainActor.run {
                        self.newAccount = lastAccount
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "Unable to retrieve the new account."
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func enrollParameters() throws -> EnrollParameters {
        if prefs.sdkConfigData.lockType == .sdkPinWithBiometricsOptional && !isSDKPinSet {
            return try prefs.flowBinding ? parametersWithSDKPINWithBinding() : parametersWithSDKPIN()
        }
        
        return prefs.flowBinding ? try parametersDefaultWithBinding() : parametersDefault()
    }
    
    func parametersWithSDKPIN() throws -> EnrollParameters {
        guard let pin = pin else {
            throw SampleAppError.noSDKPIN
        }
        
        switch enrollType {
        case .shortCode(let code):
            return .with(shortCode: code, sdkPin: pin)
        case .activationCode(let code):
            return .with(activationCode: code, sdkPin: pin)
        }
    }
    
    func parametersDefault() -> EnrollParameters {
        switch enrollType {
        case .shortCode(let code):
            return .with(shortCode: code, bindingToken: bindingToken ?? "")
        case .activationCode(let code):
            return .with(activationCode: code, bindingToken: bindingToken ?? "")
        }
    }
    
    func parametersWithSDKPINWithBinding() throws -> EnrollParameters {
        guard let pin = pin else {
            throw SampleAppError.noSDKPIN
        }
        
        guard let bindingToken = bindingToken else {
            throw SampleAppError.noBindingToken
        }
        
        switch enrollType {
        case .shortCode(let code):
            return .with(shortCode: code, sdkPin: pin, bindingToken: bindingToken)
        case .activationCode(let code):
            return .with(activationCode: code, sdkPin: pin, bindingToken: bindingToken)
        }
    }
    
    func parametersDefaultWithBinding() throws -> EnrollParameters {
        guard let bindingToken = bindingToken else {
            throw SampleAppError.noBindingToken
        }
        
        switch enrollType {
        case .shortCode(let code):
            return .with(shortCode: code, bindingToken: bindingToken)
        case .activationCode(let code):
            return .with(activationCode: code, bindingToken: bindingToken)
        }
    }
}


