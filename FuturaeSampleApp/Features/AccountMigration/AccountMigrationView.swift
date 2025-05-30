//
//  AccountMigrationView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 28.2.25.
//


import SwiftUI

struct AccountMigrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AccountMigrationViewModel()
    @StateObject var prefs = GlobalPreferences.shared
    
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle:
                idleView
                
            case .loading:
                loadingView
                
            case .success:
                successView
                
            case .failure(let error):
                errorView(error)
            case .noAccountsToMigrate:
                noAccountsView
            }
        }
        .fullScreenCover(isPresented: $viewModel.showBindingTokenView, content: {
            FlowBindingTokenView {
                viewModel.showBindingTokenView = false
                viewModel.bindingToken = $0
                viewModel.proceedWithMigration()
            }
        })
        .fullScreenCover(isPresented: $viewModel.showPinEntryView, content: {
            PinView(title: String.enterPin) {
                viewModel.showPinEntryView = false
                viewModel.pin = $0
                viewModel.proceedWithMigration()
            }
        })
    }
    
    private var idleView: some View {
        VStack(alignment: .center, spacing: 48) {
            HStack {
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(ImageAsset.closeLarge)
                        .foregroundColor(Color.textDark)
                }
            }
            .padding(.all, 20)
            
            Spacer()
            
            Image(ImageAsset.restoreAccounts)
            
            
            VStack(spacing: 16){
                Text(String.restoreAccounts)
                    .font(.header4)
                    .foregroundColor(Color.textDark)
                
                Text(String.restoreAccountsDescription)
                    .font(.bodySmall)
                    .foregroundColor(Color.textDark)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            RoundedButton(title: String.restoreAccountsCta, icon: nil, action: { viewModel.proceedWithMigration(forceCheck: true) }, style: .primary, isFullWidth: true)
                .padding(.all, 16)
                .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var noAccountsView: some View {
        VStack(alignment: .center, spacing: 48) {
            Spacer()
            
            Image(ImageAsset.restoreAccounts)
            
            
            Text(String.noAccountsToRestoreTitle)
                .font(.header4)
                .foregroundColor(Color.textDark)
            
            Spacer()
            
            RoundedButton(title: String.dismiss, icon: nil, action: { presentationMode.wrappedValue.dismiss() }, style: .outlined, isFullWidth: true)
                .padding(.all, 16)
                .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var loadingView: some View {
        VStack {
            HeaderView(title: String.restoringAccounts, progress: true)
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 16){
                    Text(String.pleaseWait)
                        .font(.header4)
                        .foregroundColor(Color.textDark)
                    
                    Text(String.restoreAccountsPleaseWait)
                        .font(.bodySmall)
                        .foregroundColor(Color.textDark)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    private var successView: some View {
        VStack {
            HeaderView(title: String.successful, image: ImageAsset.successLarge)
            VStack(spacing: 24) {
                Spacer()
                
                Text(String.restoreAccountsSuccessfulTitle)
                    .font(.titleH1)
                    .foregroundColor(Color.textDark)
                
                
                Spacer()
                
                RoundedButton(title: String.dismiss, icon: nil, action: { presentationMode.wrappedValue.dismiss() }, style: .outlined, isFullWidth: true)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    private func errorView(_ error: String) -> some View {
        VStack {
            HeaderView(title: String.failed, image: ImageAsset.errorLarge)
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 16){
                    Text(String.sdkGenericErrorMessage)
                        .font(.header4)
                        .foregroundColor(Color.textDark)
                    
                    Text(error)
                        .font(.bodySmall)
                        .foregroundColor(Color.textDark)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                RoundedButton(title: String.tryAgainCta, icon: nil, action: {
                    viewModel.proceedWithMigration(forceCheck: true)
                }, style: .primary, isFullWidth: true)
                
                RoundedButton(title: String.dismiss, icon: nil, action: { presentationMode.wrappedValue.dismiss() }, style: .outlined, isFullWidth: true)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}
