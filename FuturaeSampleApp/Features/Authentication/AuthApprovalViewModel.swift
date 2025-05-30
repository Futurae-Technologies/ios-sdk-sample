//
//  AuthApprovalViewModel.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import SwiftUI
import FuturaeKit


final class AuthApprovalViewModel: ObservableObject {
    @Published var session: FTRSession? = nil
    @Published var extraInfo: [FTRExtraInfo]? = nil
    @Published var account: FTRAccount? = nil
    @Published var offlineVerificationCode: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var multiNumberChoice: Int? = nil
    @Published var replied: String? = nil
    @Published var selectedReply: AuthReplyType? = nil
    @Published var showMultiNumberChoice: Bool = false
    
    var prefs = GlobalPreferences.shared
    
    let onDismiss: () -> Void
    let authType: AuthApprovalType
        
    init(authType: AuthApprovalType, onDismiss: @escaping () -> Void) {
        self.authType = authType
        self.onDismiss = onDismiss
    }
    
    func fetchSessionInfo() {
        Task {
            do {
                var usernamelessUserId: String?
                
                let parameters: SessionParameters
                switch authType {
                case .onlineQR(let qrCode):
                    guard let userId = FTRUtils.userId(fromQRCode: qrCode),
                          let sessionToken = FTRUtils.sessionToken(fromQRCode: qrCode) else {
                        await MainActor.run {
                            self.errorMessage = "Invalid QR Code"
                            self.isLoading = false
                        }
                        return
                    }
                    parameters = .with(token: sessionToken, userId: userId)
                case .usernameless(let qrCode, let userId):
                    guard let sessionToken = FTRUtils.sessionToken(fromQRCode: qrCode) else {
                        await MainActor.run {
                            self.errorMessage = "Invalid QR Code"
                            self.isLoading = false
                        }
                        return
                    }
                    parameters = .with(token: sessionToken, userId: userId)
                    usernamelessUserId = userId
                case .usernamelessUrl(let sessionToken, let userId, _):
                    parameters = .with(token: sessionToken, userId: userId)
                    usernamelessUserId = userId
                case .pushAuth(let sessionId, let userId, _):
                    parameters = .with(id: sessionId, userId: userId)
                case .url(let sessionToken, let userId, _):
                    parameters = .with(token: sessionToken, userId: userId)
                case .offlineQR(let parameters):
                    let userId = FTRUtils.userId(fromQRCode: parameters.qrCode)
                    let account = try FuturaeService.client.getAccounts().first { $0.userId == userId }
                    
                    await MainActor.run {
                        self.account = account
                        self.extraInfo = FuturaeService.client.extraInfoFromOfflineQRCode(parameters.qrCode)
                    }
                    
                    return
                }
                
                await MainActor.run {
                    isLoading = true
                }
                
                let sessionTask: AsyncTaskResult<FTRSession>
                if prefs.sessionInfoType == .protected {
                    sessionTask = FuturaeService.client.getSessionInfo(parameters)
                } else {
                    sessionTask = FuturaeService.client.getSessionInfoWithoutUnlock(parameters)
                }
                
                
                let session = try await sessionTask.execute()
                
                let account = try FuturaeService.client.getAccounts().first { $0.userId == session.userId || $0.userId == usernamelessUserId }
                
                await MainActor.run {
                    self.session = session
                    self.extraInfo = session.extraInfo
                    self.account = account
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

    func replyAuth(_ reply: AuthReplyType) {
        if reply == .approve, let choices = session?.multiNumberedChallenge, !choices.isEmpty && multiNumberChoice == nil {
            selectedReply = reply
            showMultiNumberChoice = true
            return
        }
        
        isLoading = true
        
        Task {
            switch authType {
            case .offlineQR(let parameters):
                await retrieveOfflineQRCode(parameters)
                return
            case .usernameless(let qrCode, let userId):
                await replyAuth(parameters: .replyUsernamelessQRCode(reply, qrCode: qrCode, userId: userId, extraInfo: extraInfo))
            case .usernamelessUrl(let sessionToken, let userId, let redirect):
                await replyAuth(parameters: .replyUsernamelessAuth(reply, sessionToken: sessionToken, userId: userId, extraInfo: extraInfo), redirect: redirect)
            case .onlineQR(let qrCode):
                await replyAuth(parameters: .replyQRCode(reply, qrCode: qrCode, extraInfo: extraInfo))
            case .pushAuth(let sessionId, let userId, _):
                await replyAuth(parameters:  multiNumberChoice != nil ?
                    .replyMultiNumber(reply, multiNumberChoice: multiNumberChoice!, sessionId: sessionId, userId: userId, extraInfo: extraInfo) :
                    .replyPush(reply, sessionId: sessionId, userId: userId, extraInfo: extraInfo)
                )
            case .url(let sessionToken, let userId, let redirect):
                await replyAuth(parameters: .replyMobileAuth(reply, sessionToken: sessionToken, userId: userId, extraInfo: extraInfo), redirect: redirect)
            }
        }
    }
    
    func retrieveOfflineQRCode(_ parameters: OfflineQRCodeParameters) async{
        do {
            let code = try await FuturaeService.client
                .getOfflineQRVerificationCode(parameters)
                .execute()
            
            await MainActor.run {
                self.isLoading = false
                self.offlineVerificationCode = code
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func replyAuth(parameters: AuthReplyParameters, redirect: String? = nil) async {
        do {
            try await FuturaeService.client.replyAuth(parameters)
                .execute()
            
            NotificationCenter.default.post(name: .authenticationProcessed, object: nil)
            
            await MainActor.run {
                switch parameters.reply {
                case .approve:
                    self.replied = "Approve"
                case .reject:
                    self.replied = "Reject"
                case .fraud:
                    self.replied = "Fraud"
                default:
                    break
                }
                
                self.isLoading = false
            }
            
            if let redirect = redirect, let redirectURL = URL(string: redirect) {
                await UIApplication.shared.open(redirectURL)
            }
        } catch {
            await MainActor.run {
                self.multiNumberChoice = nil
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
