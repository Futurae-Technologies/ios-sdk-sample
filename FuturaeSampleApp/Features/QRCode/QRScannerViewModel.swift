//
//  QRScannerViewModel.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//

import SwiftUI
import AVFoundation
import FuturaeKit

final class QRScannerViewModel: NSObject, ObservableObject {
    @Published var alertMessage: String? = nil
    @Published var isScanning = true
    @Published var usernamelessQRCode: String? = nil
    
    var prefs = GlobalPreferences.shared
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    private let sessionQueue = DispatchQueue(label: "app.sessionQueue")
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .back) else {
            DispatchQueue.main.async {
                self.alertMessage = "No camera found on this device."
            }
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                DispatchQueue.main.async {
                    self.alertMessage = "Unable to add camera input."
                }
                return
            }
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = "Camera input error: \(error.localizedDescription)"
            }
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            DispatchQueue.main.async {
                self.alertMessage = "Unable to add metadata output."
            }
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
    }
    
    func startScanning() {
        guard !captureSession.isRunning else { return }
        sessionQueue.async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.isScanning = true
            }
        }
    }
    
    func stopScanning() {
        guard captureSession.isRunning else { return }
        sessionQueue.async {
            self.captureSession.stopRunning()
            DispatchQueue.main.async {
                self.isScanning = false
            }
        }
    }
    
    private func handleScannedQRCode(_ code: String) {
        stopScanning()
        
        let type = FuturaeService.client.qrCodeType(from: code)
        switch type {
        case .enrollment:
            NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.enroll(type: .activationCode(code: code)))
        case .activationTokenExchange:
            if let activation = FTRUtils.activationTokenExchangeFromQR(code) {
                Task {
                    do {
                        let activationShortCode = try await FuturaeService.client.exchangeTokenForEnrollmentActivationCode(activation.exchangeToken).execute()
                        NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.enroll(type: .shortCode(code: activationShortCode)))
                    } catch {
                        self.showAlertMessage("Failed to retrieve activation code: \(error.localizedDescription)")
                    }
                }
            }
        case .authTokenExchange:
            if let authentication = FTRUtils.authTokenExchangeFromQR(code) {
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
        case .onlineAuth:
            NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.auth(type: .onlineQR(qrCode: code)))
        case .offlineAuth:
            let parameters: OfflineQRCodeParameters
            switch prefs.verificationCodeType {
            case .biometrics:
                parameters = .with(qrCode: code, promptReason: "Use biometrics")
            case .default:
                parameters = .with(qrCode: code)
            case .sdkPin:
                NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.pinInput(title: "Use PIN", callback: { pin in
                    guard let pin = pin else {
                        self.showAlertMessage("PIN code is required.")
                        return
                    }
                    
                    NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.auth(type: .offlineQR(parameters: .with(qrCode: code, sdkPin: pin))))
                }))
                return
            }
            
            NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.auth(type: .offlineQR(parameters: parameters)))
            
        case .invalid:
            showAlertMessage("Invalid QR code.\n(Code: \(code))")
        default:
            DispatchQueue.main.async {
                self.usernamelessQRCode = code
            }
        }
    }
    
    func showAlertMessage(_ string: String){
        DispatchQueue.main.async {
            self.alertMessage = string
        }
    }
}

extension QRScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard isScanning else { return }
        for metadataObject in metadataObjects {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { continue }
            handleScannedQRCode(stringValue)
            break
        }
    }
}

