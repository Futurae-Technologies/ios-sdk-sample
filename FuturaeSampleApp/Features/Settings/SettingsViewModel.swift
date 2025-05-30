//
//  SettingsViewModel.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 28.2.25.
//

import Foundation
import FuturaeKit

final class SettingsViewModel: ObservableObject {
    @Published var biometricsInvalidated = false
    @Published var showPinChangeView: Bool = false
    @Published var isLoading = false
    @Published var alertMessage: (title: String, message: String)? = nil
    
    func activateBiometrics() {
        do {
            try FuturaeService.client.activateBiometrics()
            alertMessage = (title: String.success, message: String.biometricsActivated)
        } catch {
            alertMessage = (title: String.error, message: "\(String.errorBiometricsActivation)\n\(error.localizedDescription)")
        }
    }
    
    func deactivateBiometrics() {
        do {
            try FuturaeService.client.deactivateBiometrics()
            alertMessage = (title: String.success, message: String.biometricsDeactivated)
        } catch {
            alertMessage = (title: String.error, message: "\(String.errorBiometricsDeactivation)\n\(error.localizedDescription)")
        }
    }
    
    func changeSDKPin(pin: String?){
        guard let pin = pin else {
            self.alertMessage = (title: String.error, message: String.enterPinPlease)
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await FuturaeService.client.changeSDKPin(newSDKPin: pin).execute()
                
                await MainActor.run {
                    self.isLoading = false
                    self.alertMessage = (title: String.success, message: String.pinChanged)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.alertMessage = (title: String.error, message: error.localizedDescription)
                }
            }
        }
    }
}
