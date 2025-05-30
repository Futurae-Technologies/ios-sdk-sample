//
//  AuthApprovalView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import SwiftUI
import FuturaeKit

struct AuthApprovalView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: AuthApprovalViewModel
    
    init(authType: AuthApprovalType, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: AuthApprovalViewModel(authType: authType, onDismiss: onDismiss))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if let reply = viewModel.replied {
                repliedView(reply)
            } else if let code = viewModel.offlineVerificationCode {
                verificationCodeView(code)
            } else if let account = viewModel.account {
                authView(account)
            }
        }
        .onAppear { viewModel.fetchSessionInfo() }
        .confirmationDialog("Choose a Number", isPresented: $viewModel.showMultiNumberChoice, titleVisibility: .visible) {
            ForEach(viewModel.session?.multiNumberedChallenge ?? [], id: \.self) { number in
                Button("\(number)") {
                    viewModel.multiNumberChoice = number
                    
                    if let reply = viewModel.selectedReply {
                        viewModel.replyAuth(reply)
                    }
                }
            }
            Button(String.cancel, role: .cancel) {}
        }
    }
    
    func repliedView(_ reply: String) -> some View {
        VStack {
            HeaderView(title: String.successful, image: ImageAsset.successLarge)
            VStack(spacing: 24) {
                Spacer()
                
                Text("\(reply) reply sent.")
                    .font(.titleH1)
                    .foregroundColor(Color.textDark)
                
                
                Spacer()
                
                RoundedButton(title: String.dismiss, icon: nil, action: { presentationMode.wrappedValue.dismiss() }, style: .outlined, isFullWidth: true)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    func authView(_ account: FTRAccount) -> some View {
        VStack {
            VStack {
                HeaderView(title: account.serviceName, subtitle: account.username, imageURL: account.serviceLogo, dismissType: .close, paddingBottom: 12)
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .center, spacing: 4) {
                            if let type = viewModel.session?.type {
                                Text(type)
                                    .font(.header5)
                                    .foregroundColor(Color.textDark)
                            }
                            
                            HStack(spacing: 8) {
                                Text(Date(), style: .date)
                                    .font(.bodySmall)
                                    .foregroundColor(Color.textAlt)
                                
                                Text(Date(), style: .time)
                                    .font(.bodySmall)
                                    .foregroundColor(Color.textAlt)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 30)
                        
                        if let extras = viewModel.extraInfo, !extras.isEmpty {
                            ForEach(extras, id: \.key) { info in
                                VStack(spacing: 8) {
                                    Text(info.key)
                                        .font(.bodySmall)
                                        .foregroundStyle(Color.textDark)
                                        .padding(.horizontal, 30)
                                    
                                    Text(info.value)
                                        .font(.header5)
                                        .foregroundStyle(Color.textDark)
                                        .padding(.horizontal, 30)
                                }
                                
                                .padding(.bottom, 16)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .foregroundStyle(Color.neutralWhite)
                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 2)
            
            VStack(spacing: 12) {
                RoundedButton(title: String.approve, icon: ImageAsset.approve, action: { viewModel.replyAuth(.approve) }, style: .success, isFullWidth: true)
                
                switch viewModel.authType {
                case .offlineQR:
                    EmptyView()
                default:
                    HStack(spacing: 16) {
                        RoundedButton(title: "Reject", icon: ImageAsset.decline, action: { viewModel.replyAuth(.reject) }, style: .reject, isFullWidth: true)
                        RoundedButton(title: "Fraud", icon: ImageAsset.decline, action: { viewModel.replyAuth(.fraud) }, style: .reject, isFullWidth: true)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
        }
    }
    
    func verificationCodeView(_ code: String) -> some View {
        VStack {
            if let account = viewModel.account {
                HeaderView(title: account.serviceName, subtitle: account.username, imageURL: account.serviceLogo, paddingBottom: 12)
            }
            
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 12)  {
                    Text(String.offlineVerificationCode)
                        .font(.header4)
                        .foregroundColor(Color.textDark)
                    Text(String.offlineVerificationCodePrompt)
                        .font(.bodySmall)
                        .foregroundColor(Color.textAlt)
                }
                
                HStack(spacing: 8) {
                    ForEach(Array(code.spaced()), id: \.self) { digit in
                        VStack(alignment: .center) {
                            Text(String(digit))
                                .font(.titleH1)
                                .foregroundColor(Color.textDark)
                            
                            if digit != " " {
                                Rectangle()
                                    .frame(width: 22, height: 2)
                                    .foregroundColor(Color.textDark)
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    RoundedButton(title: String.dismiss, icon: nil, action: { presentationMode.wrappedValue.dismiss() }, style: .outlined, isFullWidth: true)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    func errorView(_ error: String) -> some View {
        VStack {
            HeaderView(title: "Authentication reply failed", image: ImageAsset.errorLarge)
            VStack(spacing: 24) {
                Spacer()
                
                Text(error)
                    .font(.header4)
                    .foregroundColor(Color.textDark)
                
                Spacer()
                
                RoundedButton(title: String.tryAgainCta, icon: nil, action: {
                    viewModel.fetchSessionInfo()
                }, style: .primary, isFullWidth: true)
                
                RoundedButton(title: String.dismiss, icon: nil, action: { presentationMode.wrappedValue.dismiss() }, style: .outlined, isFullWidth: true)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    var loadingView: some View {
        VStack {
            HeaderView(title: "Authentication", progress: true)
            VStack(spacing: 24) {
                Spacer()
                
                Text(String.pleaseWait)
                    .font(.header5)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.textDark)
                
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}

struct AuthApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        AuthApprovalView(authType: .offlineQR(parameters: .with(qrCode: ""))) {
            //
        }
    }
}
