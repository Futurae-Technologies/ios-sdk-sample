//
//  PrivacyProtection.swift
//  FuturaeSampleApp
//
//  Created by Dimitrios Tsigouris on 1/12/26.
//
import UIKit

@available(iOSApplicationExtension, unavailable)
final class PrivacyProtection {

    static let shared = PrivacyProtection()
    private var window: UIWindow?
    private var blurView: UIVisualEffectView?

    var blurIntensity: CGFloat = 1.0

    private init() {}

    func enable() {
        guard window == nil else { return }

        let overlayWindow: UIWindow
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState != .unattached }) {
            overlayWindow = UIWindow(windowScene: scene)
        } else {
            overlayWindow = UIWindow(frame: UIScreen.main.bounds)
        }

        overlayWindow.windowLevel = UIWindow.Level.alert + 1000
        overlayWindow.backgroundColor = .clear
        overlayWindow.isHidden = false

        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blur = UIVisualEffectView(effect: blurEffect)
        blur.alpha = blurIntensity
        blur.frame = overlayWindow.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        overlayWindow.addSubview(blur)

        self.window = overlayWindow
        self.blurView = blur
    }

    func disable() {
        window?.isHidden = true
        window = nil
        blurView = nil
    }
}
