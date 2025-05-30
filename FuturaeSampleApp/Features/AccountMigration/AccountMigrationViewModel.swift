//
//  AccountMigrationswift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 28.2.25.
//


import SwiftUI
import FuturaeKit

final class AccountMigrationViewModel: ObservableObject {
    enum MigrationState {
        case idle
        case loading
        case success
        case failure(String)
        case noAccountsToMigrate
    }
    
    @Published var state: MigrationState = .idle
    @Published var showPinEntryView: Bool = false
    @Published var pin: String? = nil
    @Published var showBindingTokenView: Bool = false
    @Published var bindingToken: String? = nil
    
    var checkPerformed = false
    var isSDKPinRequired: Bool = false
    var prefs = GlobalPreferences.shared
    
    
    func proceedWithMigration(forceCheck: Bool = false){
        if forceCheck {
            checkPerformed = false
            pin = nil
            bindingToken = nil
        }
        
        if !checkPerformed {
            checkForMigratableAccounts()
            return
        }
        
        let isSDKPinRequired = isSDKPinRequired
        let isPinCodeEmpty = pin?.isEmpty ?? true
        let showPinEntry = isSDKPinRequired && isPinCodeEmpty
        
        let isBindingEnabled = prefs.flowBinding
        let isBindingTokenEmpty = bindingToken?.isEmpty ?? true
        let showBindingToken = isBindingEnabled && isBindingTokenEmpty
        
        if showPinEntry {
            showPinEntryView = true
        } else if showBindingToken {
            showBindingTokenView = true
        } else {
            startMigration()
        }
    }
    
    func startMigration() {
        state = .loading
        Task {
            do {
                let parameters = try migrationParameters()
                let _ = try await FuturaeService.client
                    .migrateAccounts(parameters)
                    .execute()
                
                await MainActor.run {
                    NotificationCenter.default.post(name: .accountsChanged, object: nil)
                    self.state = .success
                }
            } catch {
                await MainActor.run {
                    self.state = .failure(error.localizedDescription)
                }
            }
        }
    }
    
    func checkForMigratableAccounts() {
        state = .loading
        
        Task {
            do {
                let migrationData = try await FuturaeService.client
                    .getMigratableAccounts()
                    .execute()
                let num = migrationData.numberOfAccountsToMigrate
                await MainActor.run {
                    self.checkPerformed = true
                    if num > 0 {
                        self.isSDKPinRequired = migrationData.pinProtected || prefs.sdkConfigData.lockType == .sdkPinWithBiometricsOptional
                        self.state = .idle
                        self.proceedWithMigration()
                    } else {
                        self.state = .noAccountsToMigrate
                    }
                }
            } catch {
                await MainActor.run {
                    self.state = .failure(error.localizedDescription)
                }
            }
        }
    }
    
    func migrationParameters() throws -> MigrationParameters {
        if isSDKPinRequired {
            return try prefs.flowBinding ? parametersWithSDKPINWithBinding() : parametersWithSDKPIN()
        }
        
        return prefs.flowBinding ? try parametersDefaultWithBinding() : parametersDefault()
    }
    
    func parametersWithSDKPIN() throws -> MigrationParameters {
        guard let pin = pin else {
            throw SampleAppError.noSDKPIN
        }
        
        return .with(sdkPin: pin)
    }
    
    func parametersDefault() -> MigrationParameters {
        .default()
    }
    
    func parametersWithSDKPINWithBinding() throws -> MigrationParameters {
        guard let pin = pin else {
            throw SampleAppError.noSDKPIN
        }
        
        guard let bindingToken = bindingToken else {
            throw SampleAppError.noBindingToken
        }
        
        return .with(sdkPin: pin, bindingToken: bindingToken)
    }
    
    func parametersDefaultWithBinding() throws -> MigrationParameters {
        guard let bindingToken = bindingToken else {
            throw SampleAppError.noBindingToken
        }
        
        return .default(bindingToken: bindingToken)
    }
}
