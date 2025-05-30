//
//  AccountHistoryView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 27.2.25.
//


import SwiftUI
import FuturaeKit

struct AccountHistoryView: View {
    @StateObject private var viewModel: AccountHistoryViewModel
    
    var account: FTRAccount { viewModel.account }
    
    init(account: FTRAccount) {
        _viewModel = StateObject(wrappedValue: AccountHistoryViewModel(account: account))
    }
    
    var body: some View {
        ZStack {
            VStack {
                HeaderView(title: account.serviceName, subtitle: account.username, imageURL: account.serviceLogo, dismissType: .back, paddingBottom: 12)
                
                if viewModel.activities.isEmpty && !viewModel.isLoading {
                    EmptyInfoView(image: .noActivity, title: String.accountHistoryBlankSlateTitle, subtitle: nil)
                } else {
                    List(viewModel.activities) { activity in
                        ActivityRowView(activity: activity)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                ProgressView(String.loadingHistory)
                    .padding(24)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Alert(
                title: Text(String.error),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text(String.ok))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .authenticationProcessed)) { _ in viewModel.loadHistory() }
        .onAppear { viewModel.loadHistory() }
    }
}
