//
//  AccountsView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import SwiftUI
import FuturaeKit

struct AccountsView: View {
    @StateObject private var viewModel = AccountsViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showOTP = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    if let banner = viewModel.migrationBanner {
                        BannerView(banner: banner) {
                            NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.migration)
                        } onClose: {
                            viewModel.migrationBanner = nil
                        }
                    }
                    
                    if !FuturaeService.client.isLocked , let minRemaining = viewModel.minRemaining, minRemaining >= 0, viewModel.totalDuration > 0 {
                        ProgressView(value: Double(minRemaining), total: viewModel.totalDuration)
                            .frame(height: 8)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.semanticGreen))
                            .animation(.linear(duration: 1), value: minRemaining)
                    }
                    
                    if viewModel.accountItems.isEmpty {
                        EmptyInfoView(image: .accounts, title: String.accountsListIsEmpty, subtitle: String.accountsListIsEmptyDescription)
                    } else {
                        List(viewModel.accountItems) { item in
                            AccountRowView(
                                item: item,
                                onGenerateHOTP: viewModel.onGenerateHOTP,
                                onDelete: viewModel.onDelete,
                                onLogOut: viewModel.onLogOut,
                                onGenerateTOTP: viewModel.onGenerateTOTP,
                                showSensitiveContent: showOTP
                            )
                        }
                        .listStyle(PlainListStyle())
                        .accessibilityIdentifier("accounts_list")
                    }
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                    ProgressView(String.processing)
                        .padding(24)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                }
            }
            .navigationTitle(String.bottomNavigationAccountsItem)
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(NotificationCenter.default.publisher(for: .accountsChanged)) { _ in viewModel.loadAccounts() }
            .onAppear {
                viewModel.loadAccounts()
                viewModel.loadAccountsStatus()
                viewModel.loadAccountsPendingSessions()
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.alertMessage = nil } }
            )) {
                Alert(
                    title: Text(viewModel.alertMessage?.title ?? ""),
                    message: Text(viewModel.alertMessage?.message ?? ""),
                    dismissButton: .default(Text(String.ok))
                )
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                showOTP = true
            case .background, .inactive:
                showOTP = false
            @unknown default:
                break
            }
        }
    }
}


struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView()
    }
}

