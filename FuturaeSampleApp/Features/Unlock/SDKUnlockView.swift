//
//  SDKUnlockView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 4.3.25.
//


import SwiftUI
import FuturaeKit

struct SDKUnlockView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SDKUnlockViewModel()
    
    init(onUnlocked: (() -> Void)? = nil, callback: (() -> Void)? = nil) {
        self._viewModel = .init(wrappedValue: .init(onUnlocked: onUnlocked, callback: callback))
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center, spacing: 24) {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(ImageAsset.closeLarge)
                            .foregroundColor(Color.neutralWhite)
                    }
                }
                .padding(.all, 20)
                
                Spacer()
                
                Image(ImageAsset.futurae)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.bodySmall)
                        .foregroundStyle(Color.textError)
                }
                
                if viewModel.canUsePin {
                    Text(String.unlockWithPin)
                        .font(.header5)
                        .foregroundStyle(Color.neutralWhite)
                    
                    
                    HStack(spacing: 12) {
                        ForEach(0..<viewModel.maxPinLength, id: \.self) { index in
                            Circle()
                                .fill(index < viewModel.pin.count ? Color.fillState : Color.emptyState)
                                .frame(width: 12, height: 12)
                        }
                    }
                    
                    KeypadView(
                        enteredPin: $viewModel.pin,
                        maxLength: viewModel.maxPinLength,
                        onComplete: {
                            viewModel.unlockWithPin()
                        }
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                
                if viewModel.canUseBiometrics {
                    VStack {
                        Text(FuturaeService.client.activeUnlockMethods.contains(.biometricsOrPasscode)
                             ? String.unlockWithBiometricsOrCreds : String.unlockWithBiometrics)
                            .font(.header5)
                            .foregroundStyle(Color.neutralWhite)
                        
                        Button(action: {
                            viewModel.unlockWithBiometrics()
                        }) {
                            Image(systemName: "faceid")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 24)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                LoadingView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.screenBg)
        .onAppear(perform: {
            if !viewModel.canUsePin && viewModel.canUseBiometrics {
                viewModel.unlockWithBiometrics()
            }
        })
        .onDisappear(perform: viewModel.callback)
    }
}
