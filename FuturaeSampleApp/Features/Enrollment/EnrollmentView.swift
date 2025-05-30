//
//  EnrollmentView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 27.2.25.
//

import SwiftUI
import FuturaeKit

struct EnrollmentView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: EnrollmentViewModel
    @StateObject var prefs = GlobalPreferences.shared
    
    init(enrollType: EnrollType, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EnrollmentViewModel(enrollType: enrollType, onDismiss: onDismiss))
    }
    
    var body: some View {
        ZStack {
            if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage)
            } else if let account = viewModel.newAccount {
                newAccountView(account: account)
            } else if viewModel.isLoading {
                loadingView
            } else {
                enrollView
            }
        }
        .onAppear {
            proceedWithEnrollment()
        }
        .fullScreenCover(isPresented: $viewModel.showBindingTokenView, content: {
            FlowBindingTokenView {
                viewModel.showBindingTokenView = false
                viewModel.bindingToken = $0
                proceedWithEnrollment()
            }
        })
        .fullScreenCover(isPresented: $viewModel.showPinEntryView, content: {
            PinView(title: "Setup PIN") {
                viewModel.showPinEntryView = false
                viewModel.pin = $0
                proceedWithEnrollment()
            }
        })
    }
    
    func errorView(_ error: String) -> some View {
        VStack {
            HeaderView(title: String.accountEnrollmentFailed, image: ImageAsset.errorLarge)
            VStack(spacing: 24) {
                Spacer()
                
                Text(error)
                    .font(.header4)
                    .foregroundColor(Color.textDark)
                
                Spacer()
                
                RoundedButton(title: String.tryAgainCta, icon: nil, action: {
                    viewModel.errorMessage = nil
                    viewModel.pin = nil
                    viewModel.bindingToken = nil
                    proceedWithEnrollment()
                }, style: .primary, isFullWidth: true)
                
                RoundedButton(title: String.dismiss, icon: nil, action: { presentationMode.wrappedValue.dismiss() }, style: .outlined, isFullWidth: true)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    func newAccountView(account: FTRAccount) -> some View {
        VStack {
            HeaderView(title: String.accountAdded, image: ImageAsset.successLarge)
            VStack(spacing: 24) {
                Spacer()
                
                if let imageURL = account.serviceLogo, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(width: 72, height: 72)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 2)
                        default:
                            EmptyView()
                        }
                    }
                }
                
                if let title = account.serviceName {
                    Text(title)
                        .font(.titleH1)
                        .foregroundColor(Color.textDark)
                }
                
                if let subtitle = account.username {
                    Text(subtitle)
                        .font(.bodySmall)
                        .foregroundColor(Color.textDark)
                }
                
                
                Spacer()
                
                RoundedButton(title: String.dismiss, icon: nil, action: { presentationMode.wrappedValue.dismiss() }, style: .outlined, isFullWidth: true)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    var loadingView: some View {
        VStack {
            HeaderView(title: String.accountEnrollmentProgress, progress: true)
            VStack(spacing: 24) {
                Spacer()
                
                Text(String.accountEnrollmentPleaseWait)
                    .font(.header5)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.textDark)
                
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    var enrollView: some View {
        VStack {
            HeaderView(title: String.accountEnrollment, dismissType: .close, titleFont: .header4)
            VStack(spacing: 24) {
                Spacer()
                
                Image(ImageAsset.accounts)
                
                Text(String.enrollDescription)
                    .font(.header5)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.textDark)
                
                
                Spacer()
                
                RoundedButton(title: String.enroll, icon: nil, action: proceedWithEnrollment, style: .primary, isFullWidth: true)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    func proceedWithEnrollment(){
        let isPinConfig = prefs.sdkConfigData.lockType == .sdkPinWithBiometricsOptional
        let isSDKPinSet = viewModel.isSDKPinSet
        let isPinCodeEmpty = viewModel.pin?.isEmpty ?? true
        let showPinEntry = isPinConfig && !isSDKPinSet && isPinCodeEmpty
        
        let isBindingEnabled = prefs.flowBinding
        let isBindingTokenEmpty = viewModel.bindingToken?.isEmpty ?? true
        let showBindingToken = isBindingEnabled && isBindingTokenEmpty
        
        if showPinEntry {
            viewModel.showPinEntryView = true
        } else if showBindingToken {
            viewModel.showBindingTokenView = true
        } else {
            viewModel.processEnrollment()
        }
    }
}
