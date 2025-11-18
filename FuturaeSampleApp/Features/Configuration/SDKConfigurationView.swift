//
//  SDKConfigurationView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 28.2.25.
//


import SwiftUI
import FuturaeKit

struct SDKConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SDKConfigurationViewModel
    
    init(prefs: GlobalPreferences, mode: SDKConfigMode) {
        _viewModel = StateObject(wrappedValue: .init(prefs: prefs, mode: mode))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: title, dismissType: viewModel.mode == .setup ? nil : .back, titleFont: .header5, paddingBottom: 12)
            ZStack {
                Form {
                    if viewModel.mode == .setup || viewModel.mode == .view {
                        Section(header: Text("SDK Credentials")) {
                            TextField("SDK ID", text: $viewModel.sdkConfigData.sdkId).disabled(viewModel.mode == .view)
                            TextField("SDK Key", text: $viewModel.sdkConfigData.sdkKey).disabled(viewModel.mode == .view)
                            TextField("Base URL", text: $viewModel.sdkConfigData.baseUrl).disabled(viewModel.mode == .view)
                            Toggle("SSL Pinning", isOn: $viewModel.sdkConfigData.sslPinning).disabled(viewModel.mode == .view)
                        }
                    }
                    
                    if viewModel.mode == .setup || viewModel.mode == .view || viewModel.mode == .updateConfig {
                        Section(header: Text("App & Keychain Groups")) {
                            Toggle("Use App Group", isOn: $viewModel.sdkConfigData.useAppGroup).disabled(viewModel.mode == .view)
                            Toggle("Use Keychain Access Group", isOn: $viewModel.sdkConfigData.useKeychainAccessGroup).disabled(viewModel.mode == .view)
                        }
                        
                        Section(header: Text("Keychain Accessibility")) {
                            Picker("Items Accessibility", selection: $viewModel.sdkConfigData.keychainAccessibility) {
                                ForEach(KeychainAccessibilityType.allCases, id: \.self) { access in
                                    Text(access.description)
                                }
                            }.disabled(viewModel.mode == .view)
                        }
                    }
                    
                    if viewModel.mode == .setup || viewModel.mode == .view || viewModel.mode == .switchLock {
                        Section(header: Text("Lock Configuration")) {
                            Picker("Lock Type", selection: $viewModel.sdkConfigData.lockType) {
                                ForEach(LockType.allCases, id: \.self) { type in
                                    Text("\(type.description)")
                                }
                            }.disabled(viewModel.mode == .view)
                            
                            
                            if viewModel.sdkConfigData.lockType != .none {
                                Stepper(value: $viewModel.sdkConfigData.unlockDuration, in: 2...300, step: 15) {
                                    Text("Unlock Duration: \(Int(viewModel.sdkConfigData.unlockDuration))s")
                                }.disabled(viewModel.mode == .view)
                                Toggle("Invalidated by Biometrics Change", isOn: $viewModel.sdkConfigData.invalidatedByBiometricsChange).disabled(viewModel.mode == .view)
                            }
                            
                            if viewModel.sdkConfigData.lockType == .sdkPinWithBiometricsOptional {
                                Toggle("Allow PIN Change with Biometric Unlock", isOn: $viewModel.sdkConfigData.allowPinChangeWithBiometricUnlock)
                                    .font(.footnote)
                                    .disabled(viewModel.mode == .view)
                                Toggle("Deactivate Biometrics After PIN Change", isOn: $viewModel.sdkConfigData.deactivateBiometricsAfterPinChange)
                                    .font(.footnote)
                                    .disabled(viewModel.mode == .view)
                            }
                        }
                    }
                    
                    Section(header: Text("Integrity Verdict")) {
                        Toggle("IV Enabled", isOn: $viewModel.sdkConfigData.ivEnabled).disabled(viewModel.mode == .view)
                        if viewModel.sdkConfigData.ivEnabled {
                            TextField("IV TEAM ID", text: $viewModel.sdkConfigData.ivTeamId).disabled(viewModel.mode == .view)
                            Toggle("IV Production", isOn: $viewModel.sdkConfigData.ivProduction).disabled(viewModel.mode == .view)
                            TextField("IV TIMEOUT", value: $viewModel.sdkConfigData.ivBlockingTimeout, format: .number)
                                .keyboardType(.numberPad)
                                .disabled(viewModel.mode == .view)
                        }
                    }
                    
                    Section {
                        Toggle("Save configuration in preferences", isOn: $viewModel.sdkConfigData.savePrefs).disabled(viewModel.mode == .view)
                        Toggle("Launch SDK on app launch", isOn: $viewModel.sdkConfigData.saveLaunch).disabled(viewModel.mode == .view)
                    }
                    
                    Section {
                        switch viewModel.mode {
                        case .setup:
                            Button("Launch SDK") {
                                viewModel.launchSDK()
                            }
                        case .switchLock:
                            Button("Switch") {
                                if viewModel.sdkConfigData.lockType == .sdkPinWithBiometricsOptional {
                                    NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.pinInput(title: "Setup PIN", callback: { pin in
                                        viewModel.pin = pin
                                        viewModel.switchLockConfiguration()
                                    }))
                                } else {
                                    viewModel.switchLockConfiguration()
                                }
                            }
                        case .updateConfig:
                            Button("Update") {
                                viewModel.updateConfiguration()
                            }
                        case .checkDataExists:
                            Button("Check") {
                                viewModel.checkDataExists()
                            }
                        case .view:
                            Button("Go back") {
                                dismiss()
                            }
                        }
                    }
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                    ProgressView("Processing...")
                        .padding(24)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                }
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
    
    var title: String {
        switch viewModel.mode {
        case .setup:
            return "SDK Configuration"
        case .switchLock:
            return "Switch Lock Configuration"
        case .updateConfig:
            return "Update SDK Configuration"
        case .checkDataExists:
            return "Check SDK Data"
        case .view:
            return "View SDK Configuration"
        }
    }
}
