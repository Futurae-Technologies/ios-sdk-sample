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
    @StateObject var prefs = GlobalPreferences.shared
    
    var body: some Scene {
        WindowGroup {
            if prefs.launchSDK {
                MainTabView()
                    .environmentObject(prefs)
                    .onReceive(NotificationCenter.default.publisher(for: .appRouteChanged)) { self.appRoute = $0.object as? AppRoute }
                    .fullScreenCover(isPresented: Binding<Bool>(get: { appRoute != nil }, set: { if !$0 { appRoute = nil }})) { viewForRoute(appRoute) }
                    .onOpenURL { handleURL(url: $0) }
            } else {
                SDKConfigurationView(prefs: prefs, mode: .setup)
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
        case .authentication:
            if let authentication = FTRUtils.authenticationDataFromURL(url) {
                NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.auth(type: .url(sessionToken: authentication.sessionToken,
                                                                                                         userId: authentication.userId,
                                                                                                         redirect: authentication.mobileAuthRedirectUri
                                                                                                        )))
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
}
