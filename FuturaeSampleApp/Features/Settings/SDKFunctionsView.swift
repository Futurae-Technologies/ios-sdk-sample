//
//  DebugView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 7.3.25.
//

import SwiftUI
import FuturaeKit
import LocalAuthentication

struct ActiveSession: Identifiable, Hashable {
    var id: String { sessionId }
    
    let sessionId: String
    let userId: String
}

struct TextSheet: Identifiable {
    var id: String { title }
    let title: String
    let text: String
}

struct SDKFunctionsView: View {
    @StateObject var prefs = GlobalPreferences.shared
    @State var alertMessage: (title: String, message: String)? = nil
    @State var isLoading = false
    
    
    @State var showActiveSessions = false
    @State var activeSessions: [ActiveSession] = []
    
    @State private var textSheet: TextSheet?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(title: "SDK Functions", dismissType: .back, titleFont: .header5, paddingBottom: 12)
                List {
                    Section {
                        Button("Lock SDK") {
                            lockSDK()
                        }
                        
                        Button("Get active sessions"){
                            getActiveSessions()
                        }
                        .confirmationDialog("Select a session", isPresented: $showActiveSessions, titleVisibility: .visible) {
                           ForEach(activeSessions, id: \.self) { session in
                                Button("\(session.sessionId) - \(session.userId)"){
                                    handleSession(session)
                                }
                            }
                            
                            Button("Cancel", role: .cancel) { }
                        }
                        
                        Button("Get accounts status"){
                            getAccountsStatus()
                        }
                        
                        Button("Check if Biometrics Changed") {
                            haveBiometricsChanged()
                        }
                        Button("Get SDK Report") {
                            getSDKReport()
                        }
                        Button("Check Biometrics Permission") {
                            biometricsPermission()
                        }
                        Button("Perform App Attestation") {
                            appAttestation()
                        }
                        Button("Check Jailbreak Status") {
                            jailbreakStatus()
                        }
                        Button("Check Offline Accounts Status") {
                            offlineAccountsStatus()
                        }
                    }
                    
                }
            }
            
            if isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView("Processing...")
                    .padding(24)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(item: $textSheet) {
            TextDetailView(title: $0.title, text: $0.text)
        }
        .alert(isPresented: Binding<Bool>(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Alert(
                title: Text(alertMessage?.title ?? ""),
                message: Text(alertMessage?.message ?? ""),
                dismissButton: .default(Text(String.ok))
            )
        }
    }
    
    func lockSDK(){
        do {
            try FuturaeService.client.lock()
            self.alertMessage = ("Lock SDK", String.success)
        } catch {
            self.alertMessage = ("Lock SDK error", error.localizedDescription)
        }
    }
    
    func haveBiometricsChanged(){
        self.alertMessage = ("Have biometrics changed", FuturaeService.client.haveBiometricsChanged ? "Yes" : "No")
    }
    
    func getSDKReport(){
        isLoading = true
        
        do {
            let report = try FuturaeService.client.sdkStateReport()
            
            self.textSheet = .init(title: "Report", text:"\(report.report) \n\nLogs:\n\n\(report.logs)")
        } catch {
            self.alertMessage = ("Lock SDK error", error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func biometricsPermission(){
        isLoading = true
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Request permission") { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertMessage = ("Biometrics permission error", error.localizedDescription)
                } else {
                    self.alertMessage = ("Biometrics permission", granted ? "Granted" : "Denied")
                }
                isLoading = false
            }
        }
    }
    
    func appAttestation(){
        isLoading = true
        
        Task {
            do {
                try await FuturaeService.client.appAttestation(appId: SDKConstants.appId, production: false).execute()
                self.alertMessage = ("Attestation success", "App integrity verified")
                isLoading = false
            } catch {
                self.alertMessage = ("Attestation failure", error.localizedDescription)
                isLoading = false
            }
        }
    }
    
    func jailbreakStatus(){
        let status = FuturaeService.client.jailbreakStatus
        self.alertMessage = ("Jailbreak", "status: \(status.jailbroken ? "Device is jailbroken" : "Jailbreak not detected")\n\n" + (status.message ?? ""))
    }
    
    func offlineAccountsStatus(){
        do {
            let accounts = try FuturaeService.client.getAccounts()
            let accountsInfo = accounts.reduce("") { result, account in
                result + createAccountDescription(account)
            }
            
            self.textSheet = .init(title: "Offline accounts", text: accountsInfo)
        } catch {
            self.alertMessage = ("Offline accounts error", "\(error.localizedDescription)")
        }
        
    }
    
    func createAccountDescription(_ account: FTRAccount) -> String {
        var dateString = ""
        
        if let date = account.enrolledAt {
            let localDateFormatter = DateFormatter()
            localDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            localDateFormatter.timeZone = TimeZone.current
            
            let localDateString = localDateFormatter.string(from: date)
            dateString = localDateString
            print("Local Time: \(localDateString)")
        } else {
            print("Failed to parse date.")
        }
        
        var info = "userid: \(account.userId)\n"
        info += "usename: \(account.username ?? "N/A")\n"
        info += "service name: \(account.serviceName ?? "N/A")\n"
        info += "locked_out: \(account.lockedOut ? "YES" : "NO")\n"
        info += "enrolled: \(account.enrolled ? "YES" : "NO")\n"
        info += "enrolled at: \(dateString)\n"
        return info
    }
    
    func handleSession(_ session: ActiveSession){
        NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.auth(type: .pushAuth(sessionId: session.sessionId,
                                                                                                      userId: session.userId,
                                                                                                      multiNumberedChallenge: nil)))
    }
    
    func getAccountsStatus(){
        isLoading = true
        
        Task {
            do {
                let accounts = try FuturaeService.client.getAccounts()
                let status = try await FuturaeService.client.getAccountsStatus(accounts).execute()
                
                await MainActor.run {
                    self.isLoading = false
                    self.textSheet = .init(title: "Accounts status", text: "\(status.asDictionary.description)")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.alertMessage = (String.error, "\(error.localizedDescription)")
                }
            }
        }
    }
    
    func getActiveSessions(){
        isLoading = true
        
        Task {
            do {
                let accounts = try FuturaeService.client.getAccounts()
                let status = try await FuturaeService.client.getAccountsStatus(accounts).execute()
                var active = [ActiveSession]()
                status.accounts.forEach { account in
                    account.sessions?.forEach { session in
                        active.append(.init(sessionId: session.sessionId ?? "N/A", userId: session.userId ?? "N/A"))
                    }
                }
                
                await MainActor.run {
                    self.isLoading = false
                    self.activeSessions = active
                    self.showActiveSessions = true
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.alertMessage = (String.error, "\(error.localizedDescription)")
                }
            }
        }
    }
}
