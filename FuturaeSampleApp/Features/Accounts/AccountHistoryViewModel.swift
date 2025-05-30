//
//  AccountHistoryViewModel.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 27.2.25.
//


import SwiftUI
import FuturaeKit

final class AccountHistoryViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var activities: [AccountActivityItem] = []
    
    let account: FTRAccount
    
    init(account: FTRAccount) {
        self.account = account
    }
    
    func loadHistory() {
        isLoading = true
        Task {
            do {
                let history = try await FuturaeService.client
                    .getAccountHistory(account)
                    .execute()
                
                await MainActor.run {
                    self.activities = history.activity.map { .init(id: "\($0.timestamp)", activity: $0) }
                    self.isLoading = false
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
