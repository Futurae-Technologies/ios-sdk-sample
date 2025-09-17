//
//  NotificationService.swift
//  notifications
//
//  Created by Armend Hasani on 17.3.25.
//

import UserNotifications
import FuturaeKit

final class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    var sdkConfig: FTRConfig { GlobalPreferences.shared.sdkConfigData.ftrConfig }
    
    let EXTRA_INFO_ENC_KEY = "extra_info_enc"
    let NOTIFICATION_ID_KEY = "notification_id"
    let DEVICE_TOKEN_KEY = "ftr_device_token"
    let NOTIFICATION_AUTH_CATEGORY = "auth"
    let USER_ID_KEY = "user_id"

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }
        
        if let encrypted = bestAttemptContent.userInfo[EXTRA_INFO_ENC_KEY] as? String,
           let userId = bestAttemptContent.userInfo[USER_ID_KEY] as? String {
            if !launchSDK(bestAttemptContent: bestAttemptContent, contentHandler: contentHandler){
                return
            }
            
            if let decrypted = try? FuturaeService.client.decryptExtraInfo(encrypted, userId: userId) {
                bestAttemptContent.body =  decrypted.compactMap {
                    "\($0.key): \($0.value)"
                }.joined(separator: ", ")
            }
            
            bestAttemptContent.categoryIdentifier = NOTIFICATION_AUTH_CATEGORY
            contentHandler(bestAttemptContent)
            return
        }
        
        if let notificationId = request.content.userInfo[NOTIFICATION_ID_KEY] as? String {
            if !launchSDK(bestAttemptContent: bestAttemptContent, contentHandler: contentHandler){
                return
            }
            
            Task {
                do {
                    let data = try await FuturaeService.client.getNotificationData(notificationId).execute()
                    let payload =  data.payload.compactMap {
                        "\($0.key): \($0.value)"
                    }.joined(separator: ", ")
                    bestAttemptContent.body = "Arbitrary Push Notification \(data.notificationId), \(data.userId) \(payload)"
                    contentHandler(bestAttemptContent)
                } catch {
                    bestAttemptContent.body = error.localizedDescription
                    contentHandler(bestAttemptContent)
                }
            }
        } else {
            bestAttemptContent.categoryIdentifier = NOTIFICATION_AUTH_CATEGORY
            contentHandler(bestAttemptContent)
        }
    }
    
    func launchSDK(bestAttemptContent: UNMutableNotificationContent, contentHandler: @escaping (UNNotificationContent) -> Void) -> Bool {
        if FuturaeService.client.sdkIsLaunched {
            if FuturaeService.client.haveBiometricsChanged {
                bestAttemptContent.body = "Biometrics have changed"
                contentHandler(bestAttemptContent)
                return false
            }
            
            return true
        }
        
        do {
            try FuturaeService.client.launch(config: sdkConfig)
            
            if FuturaeService.client.haveBiometricsChanged {
                bestAttemptContent.body = "Biometrics have changed"
                contentHandler(bestAttemptContent)
                return false
            }
            
            return true
        } catch let error {
            bestAttemptContent.body = error.localizedDescription
            contentHandler(bestAttemptContent)
            return false
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
