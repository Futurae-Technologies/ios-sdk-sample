//
//  SDKUnlockViewModel.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 4.3.25.
//

import SwiftUI
import FuturaeKit

final class SDKUnlockViewModel: ObservableObject {
    let maxPinLength = 4
    
    var onUnlocked: (() -> Void)?
    var callback: (() -> Void)?
    
    @Published var pin: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    init(onUnlocked: (() -> Void)? = nil, callback: (() -> Void)? = nil) {
        self.onUnlocked = onUnlocked
        self.callback = callback
    }
    
    var canUsePin: Bool { FuturaeService.client.activeUnlockMethods.contains(.sdkPin) }
    var canUseBiometrics: Bool {
        let methods = FuturaeService.client.activeUnlockMethods
        return methods.contains(.biometrics) || methods.contains(.biometricsOrPasscode)
    }
        
    func unlockWithPin() {
        guard !pin.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                try await FuturaeService.client.unlock(.with(sdkPin: pin)).execute()
                await MainActor.run {
                    self.isLoading = false
                    self.onUnlocked?()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.pin = ""
                }
            }
        }
    }
    
    func unlockWithBiometrics() {
        isLoading = true
        
        Task {
            do {
                try await FuturaeService.client.unlock(.with(biometricsPrompt: "Unlock with Face ID / Touch ID")).execute()
                await MainActor.run {
                    self.isLoading = false
                    self.onUnlocked?()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
