//
//  MoreView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import SwiftUI
import FuturaeKit

struct MoreView: View {
    @StateObject var prefs = GlobalPreferences.shared
    @State private var isDeletingAllAccounts = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HeaderView(title: nil, subtitle: "3.6.7", image: .futurae)
                VStack(alignment: .center) {
                    Image(ImageAsset.poweredBy)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.altBg)
                
                List {
                    Section {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 8) {
                                Link("Learn More", destination: URL(string: "https://www.futurae.com")!)
                                    .foregroundColor(.textDark)
                                    .font(.header5)
                                
                                Text("futurae.com")
                                    .foregroundColor(.textAlt)
                                    .font(.bodySmall)
                            }
                            .padding(.vertical, 8)
                            
                            Spacer()
                            
                            Image(ImageAsset.link)
                        }
                        
                        
                        
                        NavigationLink {
                            SettingsView().environmentObject(prefs)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String.settings)
                                    .foregroundColor(.textDark)
                                    .font(.header5)
                                
                                Text("Configuration options for the sample app and SDK")
                                    .foregroundColor(.textAlt)
                                    .font(.bodySmall)
                            }
                            .padding(.vertical, 8)
                            
                            Spacer()
                        }
                    }
                    
                    Section {
                        Button {
                            NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.migration)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String.restoreAccounts)
                                    .foregroundColor(.textDark)
                                    .font(.header5)
                                
                                Text(String.sdkRestoreDescription)
                                    .foregroundColor(.textAlt)
                                    .font(.bodySmall)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Button {
                            isDeletingAllAccounts = true
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String.sdkReset)
                                    .foregroundColor(.btnRed)
                                    .font(.header5)
                                
                                Text(String.sdkResetSubtitle)
                                    .foregroundColor(.textAlt)
                                    .font(.bodySmall)
                            }
                            .padding(.vertical, 8)
                        }
                        .alert("Are you sure you want to reset?", isPresented: $isDeletingAllAccounts) {
                            Button("Delete", role: .destructive) {
                                prefs.saveBool(.launchSDK, value: false)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    let config = prefs.sdkConfigData.ftrConfig
                                    FuturaeService.client.reset(appGroup: config.appGroup, keychain: config.keychain, lockConfiguration: config.lockConfiguration)
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This will permanently delete all of your accounts. This action cannot be undone!")
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarBackButtonHidden(true)
        }
        
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}

