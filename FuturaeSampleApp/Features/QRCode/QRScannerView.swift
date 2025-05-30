//
//  QRScannerView.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import SwiftUI

struct QRScannerView: View {
    @StateObject private var viewModel = QRScannerViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                CameraPreview(viewModel: viewModel)
                
                Image(ImageAsset.qr)
            }
            .navigationTitle(String.bottomNavigationScanItem)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.startScanning()
            }
            .onDisappear {
                viewModel.stopScanning()
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.alertMessage = nil } }
            )) {
                Alert(
                    title: Text("QR Scan Result"),
                    message: Text(viewModel.alertMessage ?? ""),
                    dismissButton: .default(Text(String.ok), action: {
                        viewModel.startScanning()
                    })
                )
            }
            .fullScreenCover(isPresented: Binding<Bool>(
                get: { viewModel.usernamelessQRCode != nil },
                set: { if !$0 { viewModel.usernamelessQRCode = nil } }
            )) {
                if let code = viewModel.usernamelessQRCode {
                    UsernamelessAccountSelectorView() { selectedUserId in
                        DispatchQueue.main.async {
                            viewModel.usernamelessQRCode = nil
                            
                            NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.auth(type: .usernameless(qrCode: code, userId: selectedUserId)))
                        }
                    }
                }
            }

        }
        
    }
}


