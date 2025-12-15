//
//  FuturaeSampleApp.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//

import SwiftUI
import FuturaeKit

@main
struct FuturaeSampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var appRoute: AppRoute? = nil
    @State var alertMessage: String? = nil
    
    @StateObject var prefs = GlobalPreferences.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if prefs.launchSDK {
                    MainTabView()
                        .environmentObject(prefs)
                } else {
                    SDKConfigurationView(prefs: prefs, mode: .setup)
                }
            }
            .onOpenURL { handleURL(url: $0) }
            .fullScreenCover(isPresented: Binding<Bool>(get: { appRoute != nil }, set: { if !$0 { appRoute = nil }})) { viewForRoute(appRoute) }
            .onReceive(NotificationCenter.default.publisher(for: .appRouteChanged)) {
                guard let route = $0.object as? AppRoute, !(appRoute?.sameTypeAs(route) ?? false) else { return }
                
                if route.requiresUnlock && FuturaeService.client.isLocked {
                    NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.unlock(callback: {
                        NotificationCenter.default.post(name: .appRouteChanged, object: route)
                    }))
                    
                    return
                }
                
                self.appRoute = route
            }
            .alert(isPresented: Binding<Bool>(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage ?? "Unknown"),
                    dismissButton: .default(Text(String.ok))
                )
            }
        }
    }
    
    func onDismiss() {
        appRoute = nil
    }
    
    func handleURL(url: URL?){
        guard let url = url else { return }
        
        // FuturaeService.client.openURL(url, options: options, delegate: self) // Instead of delegating to the SDK let's handle it ourselves
        
        switch FTRUtils.typeFromURL(url) {
        case .activation:
            if let activation = FTRUtils.activationDataFromURL(url) {
                NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.enroll(type: .activationCode(code: activation.activationCode)))
            }
        case .activationExchangeToken:
            if let activation = FTRUtils.activationTokenExchangeFromURL(url) {
                Task {
                    do {
                        let activationCode = try await FuturaeService.client.exchangeTokenForEnrollmentActivationCode(activation.exchangeToken).execute()
                        NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.enroll(type: .activationCode(code: activationCode)))
                    } catch {
                        self.showAlertMessage("Failed to retrieve activation code: \(error.localizedDescription)")
                    }
                }
            }
        case .authentication:
            if let authentication = FTRUtils.authenticationDataFromURL(url) {
                NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.auth(type: .url(sessionToken: authentication.sessionToken,
                                                                                                         userId: authentication.userId,
                                                                                                         redirect: authentication.mobileAuthRedirectUri
                                                                                                        )))
            }
            
        case .authenticationExchangeToken:
            if let authentication = FTRUtils.authTokenExchangeFromURL(url) {
                Task {
                    do {
                        let sessionToken = try await FuturaeService.client.exchangeTokenForSessionToken(authentication.exchangeToken).execute()
                        NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.auth(type: .url(sessionToken: sessionToken,
                                                                                                                 userId: authentication.userId,
                                                                                                                 redirect: nil
                                                                                                                )))
                    } catch {
                        self.showAlertMessage("Failed to retrieve session token: \(error.localizedDescription)")
                    }
                }
            }
        case .usernamelessAuth:
            if let data = FTRUtils.usernamelessAuthDataFromURL(url) {
                self.appRoute = .usernamelessSelector(sessionToken: data.sessionToken,
                                                      redirect: data.mobileAuthRedirectUri)
            }
        default:
            break
        }
    }
    
    func viewForRoute(_ appRoute: AppRoute?) -> some View {
        ZStack {
            switch appRoute {
            case .auth(let type):
                AuthApprovalView(authType: type, onDismiss: onDismiss)
            case .enroll(let type):
                EnrollmentView(enrollType: type, onDismiss: onDismiss)
            case .migration:
                AccountMigrationView(onDismiss: onDismiss)
            case .unlock(let callback):
                SDKUnlockView(onUnlocked: onDismiss, callback: callback)
            case .pinInput(let title, let callback):
                PinView(title: title) { pin in
                    onDismiss()
                    callback?(pin)
                }
            case .usernamelessSelector(let sessionToken, let redirect):
                UsernamelessAccountSelectorView() { selectedUserId in
                    onDismiss()
                    NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.auth(type: .usernamelessUrl(sessionToken: sessionToken,
                                                                                                                         userId: selectedUserId,
                                                                                                                         redirect: redirect
                                                                                                                        )))
                }
            default:
                Text("Unknown route")
            }
        }
    }
    
    func showAlertMessage(_ string: String){
        DispatchQueue.main.async {
            self.alertMessage = string
        }
    }
}
