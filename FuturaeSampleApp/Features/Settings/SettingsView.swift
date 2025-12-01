//
//  SettingsView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import SwiftUI
import FuturaeKit

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject var prefs = GlobalPreferences.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: String.settings, dismissType: .back, titleFont: .header5, paddingBottom: 12)
            List {
                Section {
                    NavigationLink("Debug Utilities", destination: SDKFunctionsView())
                }
                
                if prefs.sdkConfigData.lockType == .sdkPinWithBiometricsOptional {
                    Section(header: Text("SDK PIN")) {
                        Button("Change SDK PIN"){
                            NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.pinInput(title: "Input new PIN", callback: { pin in
                                viewModel.changeSDKPin(pin: pin)
                            }))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("Activate biometrics", isOn: $prefs.sdkPinBiometrics)
                                .onChange(of: prefs.sdkPinBiometrics) {
                                    prefs.saveBool(.sdkPinBiometrics, value: prefs.sdkPinBiometrics)
                                    prefs.sdkPinBiometrics ? viewModel.activateBiometrics() : viewModel.deactivateBiometrics()
                                }
                                .onAppear {
                                    if prefs.sdkPinBiometrics && !FuturaeService.client.activeUnlockMethods.contains(.biometrics) {
                                        prefs.sdkPinBiometrics = false
                                    }
                                }
                            Text("Bypass SDK PIN input by unlocking with biometrics")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Picker("Offline Verification Code", selection: $prefs.verificationCodeType) {
                                ForEach(VerificationCodeType.allCases, id: \.self) { type in
                                    Text("\(type.description)")
                                }
                            }
                            .onChange(of: prefs.verificationCodeType, { _, newValue in
                                prefs.save(newValue)
                            })
                            
                            Text("Determines how the verification code is generated and presented to the user")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                        
                        
                        Toggle("Allow PIN Change with Biometric Unlock", isOn: $prefs.sdkConfigData.allowPinChangeWithBiometricUnlock)
                            .onChange(of: prefs.sdkConfigData.allowPinChangeWithBiometricUnlock) { saveSDKConfig() }
                            .font(.footnote)
                        Toggle("Deactivate Biometrics After PIN Change", isOn: $prefs.sdkConfigData.deactivateBiometricsAfterPinChange)
                            .onChange(of: prefs.sdkConfigData.deactivateBiometricsAfterPinChange) { saveSDKConfig() }
                            .font(.footnote)
                    }
                }
                
                Section(header: Text("SDK Configuration")) {
                    ConfigOptionRow(title: "View", description: "View the current configuration values", destination: SDKConfigurationView(prefs: prefs, mode: .view))
                    ConfigOptionRow(title: "Update", description: "Update SDK configuration values (App Group and Keychain)", destination: SDKConfigurationView(prefs: prefs, mode: .updateConfig))
                    ConfigOptionRow(title: "Switch", description: "Switch the lock configuration to another type", destination: SDKConfigurationView(prefs: prefs, mode: .switchLock))
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Flow Binding", isOn: $prefs.flowBinding)
                            .onChange(of: prefs.flowBinding) { prefs.saveBool(.flowBinding, value: prefs.flowBinding) }
                            .accessibilityIdentifier("toggle_flow_binding")
                        Text("This enables flow binding token input during account enrollment and recovery")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Allow fetching session info without unlock",  isOn: Binding(
                            get: { prefs.sessionInfoType == .unprotected },
                            set: { newValue in
                                prefs.sessionInfoType = newValue ? .unprotected : .protected
                                prefs.save(sessionType: prefs.sessionInfoType)
                            }
                        ))
                        .accessibilityIdentifier("toggle_session_fetch_unprotected")
                        
                        Text("Determines if the protected or unprotected session method will be used")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                
                Section(header: Text("Adaptive")) {
                    ConfigOptionRow(title: "Permissions", description: "Enable permissions for collections before enabling adaptive", destination: AdaptivePermissionsView())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Data collections", isOn: $prefs.collections)
                            .onChange(of: prefs.collections) {
                                if prefs.collections {
                                    FuturaeService.client.enableAdaptiveCollections(delegate: AdaptiveDelegate())
                                } else {
                                    FuturaeService.client.disableAdaptiveCollections()
                                    FuturaeService.client.disableAdaptiveSubmissionOnAuthentication()
                                    FuturaeService.client.disableAdaptiveSubmissionOnAccountMigration()
                                    prefs.saveBool(.collectionsAuthentication, value: false)
                                    prefs.saveBool(.collectionsMigration, value: false)
                                }
                                
                                prefs.saveBool(.collections, value: prefs.collections)
                            }
                        Text("This enables collecting adaptive observations and sending them to the server.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                    
                    if prefs.collections {
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("Authentication", isOn: $prefs.collectionsAuthentication)
                                .onChange(of: prefs.collectionsAuthentication) {
                                    if prefs.collectionsAuthentication {
                                        try? FuturaeService.client.enableAdaptiveSubmissionOnAuthentication()
                                    } else {
                                        FuturaeService.client.disableAdaptiveSubmissionOnAuthentication()
                                    }
                                    
                                    prefs.saveBool(.collectionsAuthentication, value: prefs.collectionsAuthentication)
                                }
                            Text("This enables whether adaptive collections are required during authentication.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("Migration", isOn: $prefs.collectionsMigration)
                                .onChange(of: prefs.collectionsMigration) {
                                    if prefs.collectionsMigration {
                                        try? FuturaeService.client.enableAdaptiveSubmissionOnAccountMigration()
                                    } else {
                                        FuturaeService.client.disableAdaptiveSubmissionOnAccountMigration()
                                    }
                                    
                                    prefs.saveBool(.collectionsMigration, value: prefs.collectionsMigration)
                                }
                            Text("This enables whether adaptive collections are required during account migration.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Stepper(value: $prefs.collectionsThreshold, in: 0...30, step: 5) {
                                Text("Adaptive Time Threshold: \(Int(prefs.collectionsThreshold))s")
                            }
                            .onChange(of: prefs.collectionsThreshold) {
                                try? FuturaeService.client.setAdaptiveTimeThreshold(Int($1))
                                prefs.saveDouble(.collectionsThreshold, value: prefs.collectionsThreshold)
                            }
                            Text("Set the time in seconds for which the last adaptive collection should be returned until a new collection starts.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                        
                    }
                    
                    ConfigOptionRow(title: "Collections", description: "View list of generated adaptive collections so far", destination: AdaptiveCollectionsView())
                }
                
                if prefs.sdkConfigData.lockType != .none {
                    Section(header: Text("Unlock mechanism")) {
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("Floating unlock button", isOn: $prefs.floatingButton)
                                .onChange(of: prefs.floatingButton) { prefs.saveBool(.floatingButton, value: prefs.floatingButton) }
                            Text("This will display a button for unlocking the SDK on top of other views. Button also displays remaining seconds until lock.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("Unlock screen when locked", isOn: $prefs.unlockScreenWhenLocked)
                                .onChange(of: prefs.unlockScreenWhenLocked) { prefs.saveBool(.unlockScreenWhenLocked, value: prefs.unlockScreenWhenLocked) }
                            Text("This will automatically show the unlock screen when the SDK is locked.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView("Processing...")
                    .padding(24)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
            }
        }
        
        .navigationBarBackButtonHidden(true)
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
    
    func saveSDKConfig() {
        prefs.save(sdkConfigData: prefs.sdkConfigData)
        viewModel.alertMessage = (title: "Relaunch App", message: "For changes to take effect please close and re-open the app")
    }
}

struct ConfigOptionRow<Destination: View>: View {
    let title: String
    let description: String?
    let destination: Destination

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            NavigationLink(title, destination: destination)
            
            if let description = description {
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
