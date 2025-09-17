//
//  RootView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//

import SwiftUI
import FuturaeKit

struct MainTabView: View {
    @State var error: Error? = nil
    @StateObject var prefs = GlobalPreferences.shared
    @State private var selectedTab: Int = 0
    
    init() {
        do {
            if !FuturaeService.client.sdkIsLaunched {
                FuturaeService.client.enableLogging()
                try FuturaeService.client.launch(config: GlobalPreferences.shared.sdkConfigData.ftrConfig)
            }
        } catch {
            self._error = .init(initialValue: error)
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if FuturaeService.client.sdkIsLaunched {
                TabView(selection: $selectedTab) {
                    AccountsView()
                        .tabItem {
                            VStack {
                                Image(ImageAsset.account)
                                Text(String.bottomNavigationAccountsItem)
                            }
                        }
                        .tag(0)

                    QRScannerView()
                        .tabItem {
                            VStack {
                                Image(ImageAsset.qrScanner)
                                Text(String.bottomNavigationScanItem)
                                
                            }
                        }
                        .tag(1)

                    ManualEntryView()
                        .tabItem {
                            VStack {
                                Image(ImageAsset.manualEntry)
                                Text(String.bottomNavigationManualEntryItem)
                            }
                        }
                        .tag(2)

                    MoreView()
                        .tabItem {
                            VStack {
                                Image(ImageAsset.more)
                                Text(String.bottomNavigationMoreItem)
                            }
                        }
                        .tag(3)
                }
                
                FloatingUnlockButton {
                    NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.unlock(callback: nil))
                }
                .padding(.trailing, 20)
                .padding(.top, 10)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .qrTabRequested)) { _ in self.selectedTab = 1 }
        .alert(isPresented: Binding<Bool>(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Alert(
                title: Text(String.error),
                message: Text(error?.localizedDescription ?? "Unknown"),
                primaryButton: .default(Text(String.ok)),
                secondaryButton: .destructive(Text(String.sdkReset)) {
                    prefs.saveBool(.launchSDK, value: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let config = prefs.sdkConfigData.ftrConfig
                        FuturaeService.client.reset(appGroup: config.appGroup, keychain: config.keychain, lockConfiguration: config.lockConfiguration)
                    }
                }
            )
        }
    }
}
