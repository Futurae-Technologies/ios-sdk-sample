//
//  AccountsViewModel.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//

import SwiftUI
import Combine
import FuturaeKit

enum MigrationBanner {
    case success(message: String)
    case failure(message: String)
    
    var message: String {
        switch self {
        case .success(let msg), .failure(let msg):
            return msg
        }
    }
}


final class AccountsViewModel: ObservableObject {
    @Published var accountItems: [AccountItem] = []
    @Published var isLoading: Bool = false
    @Published var alertMessage: (title: String, message: String)? = nil
    @Published var migrationBanner: MigrationBanner? = nil
    
    private var timerCancellable: AnyCancellable?
    private var didCheckMigration = false
    var minRemaining: Int? {
        accountItems.map { $0.remainingSecs }.min()
    }
    
    let totalDuration: Double = 30.0
    
    func onGenerateHOTP(_ account: FTRAccount){
        do {
            let token = try FuturaeService.client.getSynchronousAuthToken(userId: account.userId)
            UIPasteboard.general.string = token
            DispatchQueue.main.async {
                self.alertMessage = ("HOTP token copied to clipboard!", token)
            }
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = (String.error, error.localizedDescription)
            }
        }
        
    }
    
    func onGenerateTOTP(_ account: FTRAccount, _ parameters: TOTPParameters) -> Void {
        Task {
            do {
                let totp = try await FuturaeService.client.getTOTP(parameters).execute()
                
                await MainActor.run {
                    self.alertMessage = ("TOTP", "\(totp.totp)\n\nRemaining seconds:\(totp.remainingSecs)")
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = (String.error, error.localizedDescription)
                }
            }
        }
    }
    
    func onDelete(_ account: FTRAccount) -> Void {
        do {
            try FuturaeService.client.deleteAccount(account)
            
            NotificationCenter.default.post(name: .accountsChanged, object: nil)
            
            DispatchQueue.main.async {
                self.alertMessage = (String.success, "Account deleted.")
            }
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = (String.error, error.localizedDescription)
            }
        }
    }
    
    func onLogOut(_ account: FTRAccount) -> Void {
        isLoading = true
        
        Task {
            do {
                try await FuturaeService.client.logoutAccount(account).execute()
                
                NotificationCenter.default.post(name: .accountsChanged, object: nil)
                
                await MainActor.run {
                    self.alertMessage = (String.success, "Account logged out.")
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = (String.error, error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadAccounts() {
        Task {
            do {
                let accounts = try FuturaeService.client.getAccounts()
                
                if accounts.isEmpty {
                    checkForMigratableAccounts()
                    
                    await MainActor.run {
                        self.accountItems = []
                    }
                    return
                } else if migrationBanner != nil {
                    await MainActor.run {
                        self.migrationBanner = nil
                    }
                }
                
                var items: [AccountItem] = []
                
                for account in accounts {
                    let displayName = account.username?.isEmpty == false ? account.username! : account.userId
                    
                    do {
                        let totpResult = try await FuturaeService.client
                            .getTOTP(.with(userId: account.userId))
                            .execute()
                        
                        let totpValue = totpResult.totp
                        let secsInt = Int(totpResult.remainingSecs) ?? 30
                        
                        let item = AccountItem(
                            id: account.userId,
                            account: account,
                            serviceName: account.serviceName ?? "Unknown Service",
                            username: displayName,
                            serviceLogo: account.serviceLogo,
                            totp: totpValue,
                            remainingSecs: secsInt
                        )
                        items.append(item)
                        
                    } catch {
                        let item = AccountItem(
                            id: account.userId,
                            account: account,
                            serviceName: account.serviceName ?? "Unknown Service",
                            username: displayName,
                            serviceLogo: account.serviceLogo,
                            totp: "----",
                            remainingSecs: 0
                        )
                        items.append(item)
                    }
                }
                
                let accountItems = items
                
                await MainActor.run {
                    self.accountItems = accountItems
                    self.startTimer()
                }
                
            } catch {
                await MainActor.run {
                    self.alertMessage = (String.error, error.localizedDescription)
                }
            }
        }
    }
    
    func loadAccountsStatus(){
        Task {
            do {
                let accounts = try FuturaeService.client.getAccounts()
                let status = try await FuturaeService.client.getAccountsStatus(accounts).execute()
                
                await MainActor.run {
                    loadAccounts()
                
                    if let session = (status.accounts.compactMap { $0.sessions }.joined().first), let userId = session.userId, let sessionId = session.sessionId {
                        
                            NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.auth(type: .pushAuth(sessionId: sessionId,
                                                                                                                          userId: userId,
                                                                                                                          multiNumberedChallenge: session.multiNumberedChallenge)))
                        
                    }
                }
                
            } catch { print(error)}
        }
    }
    
    func checkForMigratableAccounts() {
        guard !didCheckMigration else { return }
        
        didCheckMigration = true
        
        Task {
            do {
                let migrationData = try await FuturaeService.client
                    .getMigratableAccounts()
                    .execute()
                let num = migrationData.numberOfAccountsToMigrate
                if num > 0 {
                    await MainActor.run {
                        self.migrationBanner = .success(
                            message: "You have \(num) account(s) to restore. Tap to proceed."
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    self.migrationBanner = .failure(
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
    
    private func startTimer() {
        timerCancellable?.cancel()
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                for i in 0..<self.accountItems.count {
                    self.accountItems[i].remainingSecs -= 1
                    if self.accountItems[i].remainingSecs <= 0 {
                        Task {
                            await self.refetchTOTP(for: i)
                        }
                    }
                }
            }
    }
    
    @MainActor
    private func refetchTOTP(for index: Int) async {
        let userId = accountItems[index].id
        do {
            let totpResult = try await FuturaeService.client
                .getTOTP(.with(userId: userId))
                .execute()
            
            accountItems[index].totp = totpResult.totp
            accountItems[index].remainingSecs = Int(totpResult.remainingSecs) ?? 30
        } catch {
            accountItems[index].totp = "----"
            accountItems[index].remainingSecs = 0
        }
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}
