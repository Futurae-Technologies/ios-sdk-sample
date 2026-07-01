//
//  AppDelegate.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 26.2.25.
//


import UIKit
import UserNotifications
import FuturaeKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private(set) var pendingDeviceToken: Data?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        setupNotificationCenter(application)
        setupNavigationBarAppearance()
        setupTabBarAppearance()
        NotificationCenter.default.addObserver(self, selector: #selector(onSDKDidLaunch), name: .sdkDidLaunch, object: nil)

        return true
    }

    @objc private func onSDKDidLaunch() {
        registerPendingPushTokenIfNeeded()
    }
}

extension AppDelegate {
    private func setupNotificationCenter(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        let approveAction = UNNotificationAction(identifier: "approve", title: "Approve", options: [])
        let rejectAction = UNNotificationAction(identifier: "reject", title: "Reject", options: [.destructive])
        let approveCategory = UNNotificationCategory(identifier: "auth", actions: [approveAction, rejectAction], intentIdentifiers: [], options: [])
        center.setNotificationCategories([approveCategory])
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
        }
        
        application.registerForRemoteNotifications()
    }

    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Color.bgHeader.uiColor
        appearance.titleTextAttributes = [
            .foregroundColor: Color.neutralWhite.uiColor,
            .font: UIFont.font(.header5)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: Color.neutralWhite.uiColor,
            .font: UIFont.font(.header5)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Color.bgNavbar.uiColor

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Color.inactive.uiColor,
            .font: UIFont.font(.menu)
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = Color.inactive.uiColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = attributes

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Color.neutralWhite.uiColor,
            .font: UIFont.font(.menu)
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = Color.neutralWhite.uiColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension AppDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        guard FuturaeService.client.sdkIsLaunched else {
            pendingDeviceToken = deviceToken
            return
        }

        registerPushToken(deviceToken)
    }

    private func registerPendingPushTokenIfNeeded() {
        guard let token = pendingDeviceToken else { return }
        pendingDeviceToken = nil
        registerPushToken(token)
    }

    private func registerPushToken(_ deviceToken: Data) {
        Task {
            do {
                try await FuturaeService.client.registerPushToken(deviceToken).execute()
                var token = ""
                deviceToken.forEach { token += String(format: "%02x", $0) }
                print("Registered push token: \(token)")
            } catch {
                print("Failed to register push token: \(error)")
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        handleNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        handleNotification(userInfo: notification.request.content.userInfo)
        completionHandler(.sound)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        let data = FTRUtils.notificationInfoFromPayload(userInfo)
        
        if response.actionIdentifier == "approve" || response.actionIdentifier == "reject" {
            guard let sessionId = data.sessionId,
                  let userId = data.userId else {
                return
            }
            
            Task {
                do {
                    let sessionInfo = try await FuturaeService.client.getSessionInfo(SessionParameters.with(id: sessionId,userId: userId)).execute()
                    try await FuturaeService.client.replyAuth(AuthReplyParameters.replyPush(response.actionIdentifier == "approve" ? .approve : .reject,
                                                                                       sessionId: sessionId,
                                                                                       userId: userId,
                                                                                       extraInfo: sessionInfo.extraInfo)).execute()
                } catch {}
            }
            return
        } else {
            handleNotification(userInfo:userInfo)
        }
        
        completionHandler()
    }
    
    func handleNotification(userInfo: [AnyHashable: Any]){
        // FuturaeService.client.handleNotification(userInfo, delegate: self) // Instead of delegating to the SDK let's handle it ourselves
        let data = FTRUtils.notificationInfoFromPayload(userInfo)
        
        switch data.type {
        case .reply:
            guard let sessionId = data.sessionId,
                  let userId = data.userId else {
                return
            }
            
            NotificationCenter.default.post(name: .appRouteChanged,
                                            object: AppRoute.auth(type: .pushAuth(sessionId: sessionId,
                                                                                  userId: userId,
                                                                                  multiNumberedChallenge: data.multiNumberedChallenge)))
        case .qrCode:
            NotificationCenter.default.post(name: .qrTabRequested, object: nil)
        case .unenroll:
            guard let userId = data.userId, let account = try? FuturaeService.client.getAccountByUserId(userId) else {
                return
            }

            let username = account.username ?? ""
            let displayName = username.isEmpty ? userId : username

            do {
                try FuturaeService.client.deleteAccount(account)
                NotificationCenter.default.post(name: .accountsChanged, object: nil)

                DispatchQueue.main.async {
                    if UIApplication.shared.applicationState == .active {
                        let alert = UIAlertController(title: "Account Unenrolled",
                                                      message: "\(displayName) has been unenrolled.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .flatMap { $0.windows }
                            .first { $0.isKeyWindow }?
                            .rootViewController?
                            .present(alert, animated: true)
                    } else {
                        let content = UNMutableNotificationContent()
                        content.title = "Account Unenrolled"
                        content.body = "\(displayName) has been unenrolled."
                        content.sound = .default
                        let request = UNNotificationRequest(identifier: "unenroll-\(userId)", content: content, trigger: nil)
                        UNUserNotificationCenter.current().add(request)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    if UIApplication.shared.applicationState == .active {
                        let alert = UIAlertController(title: "Unenrollment Failed",
                                                      message: "A request to unenroll \(displayName) was received, but something went wrong while removing the account.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .flatMap { $0.windows }
                            .first { $0.isKeyWindow }?
                            .rootViewController?
                            .present(alert, animated: true)
                    } else {
                        let content = UNMutableNotificationContent()
                        content.title = "Unenrollment Failed"
                        content.body = "A request to unenroll \(displayName) was received, but something went wrong while removing the account."
                        content.sound = .default
                        let request = UNNotificationRequest(identifier: "unenroll-error-\(userId)", content: content, trigger: nil)
                        UNUserNotificationCenter.current().add(request)
                    }
                }
            }
        case .arbitraryNotification:
            break
        default:
            break
        }
    }
}
