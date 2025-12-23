//
//  FuturaeSDKClient.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 31.3.25.
//

import FuturaeKit

class FuturaeSDKClient: FuturaeSDKClientProtocol {
    var client: FTRClient { FTRClient.shared }
    
    var sdkIsLaunched: Bool {
        FTRClient.sdkIsLaunched
    }
    
    var clientVersion: String {
        FTRClient.clientVersion
    }
    
    func launch(config: FTRConfig) throws {
        try FTRClient.launch(config: config)
        
        let prefs = GlobalPreferences.shared
        if prefs.collections {
            enableAdaptiveCollections(delegate: AdaptiveDelegate())
        }
        
        if prefs.collectionsAuthentication {
            try? enableAdaptiveSubmissionOnAuthentication()
        }
        
        if prefs.collectionsMigration {
            try? enableAdaptiveSubmissionOnAccountMigration()
        }
    }
    
    func enableLogging() {
        FTRClient.enableLogging()
    }
    
    func disableLogging() {
        FTRClient.disableLogging()
    }
    
    func checkDataExists(forAppGroup appGroup: String?, keychainConfig: FTRKeychainConfig?, lockConfiguration: LockConfiguration) -> Bool {
        FTRClient.checkDataExists(forAppGroup: appGroup, keychainConfig: keychainConfig, lockConfiguration: lockConfiguration)
    }
    
    func reset(appGroup: String?) {
        FTRClient.reset(appGroup: appGroup)
    }
    
    func reset(appGroup: String?, keychain: FTRKeychainConfig?, lockConfiguration: LockConfiguration) {
        FTRClient.reset(appGroup: appGroup, keychain: keychain, lockConfiguration: lockConfiguration)
    }
    
    func setDelegate(_ delegate: (any FTRClientDelegate)?) {
        FTRClient.setDelegate(delegate)
    }
    
    func qrCodeType(from qrCode: String) -> FTRQRCodeType {
        FTRClient.qrCodeType(from: qrCode)
    }
    
    var isLocked: Bool {
        client.isLocked
    }
    
    var activeUnlockMethodsValues: [Int] {
        client.activeUnlockMethodsValues
    }
    
    var activeUnlockMethods: [UnlockMethodType] {
        client.activeUnlockMethods
    }
    
    var currentLockConfiguration: LockConfiguration {
        client.currentLockConfiguration
    }
    
    var sdkState: SDKState {
        client.sdkState
    }
    
    var haveBiometricsChanged: Bool {
        client.haveBiometricsChanged
    }
    
    var jailbreakStatus: JailbreakStatus {
        client.jailbreakStatus
    }
    
    var isBeta: Bool {
        client.isBeta
    }
    
    var isAdaptiveEnabled: Bool {
        client.isAdaptiveEnabled
    }
    
    var isAdaptiveSubmissionOnAuthenticationEnabled: Bool {
        client.isAdaptiveSubmissionOnAuthenticationEnabled
    }
    
    var isAdaptiveSubmissionMigrationEnabled: Bool {
        client.isAdaptiveSubmissionMigrationEnabled
    }
    
    var pendingAdaptiveCollections: [[String : Any]] {
        client.pendingAdaptiveCollections
    }
    
    func sdkStateReport() throws -> SDKReport {
        try client.sdkStateReport()
    }
    
    func setUserPresenceDelegate(_ delegate: (any FTRUserPresenceDelegate)?) {
        client.setUserPresenceDelegate(delegate)
    }
    
    func getSessionInfo(_ parameters: SessionParameters) -> AsyncTaskResult<FTRSession> {
        client.getSessionInfo(parameters)
    }
    
    func getSessionInfoWithoutUnlock(_ parameters: SessionParameters) -> AsyncTaskResult<FTRSession> {
        client.getSessionInfoWithoutUnlock(parameters)
    }
    
    func openURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey : Any], delegate: (any FTROpenURLDelegate)?) {
        client.openURL(url, options: options, delegate: delegate)
    }
    
    func getNotificationData(_ notificationId: String) -> AsyncTaskResult<FTRNotificationData> {
        client.getNotificationData(notificationId)
    }
    
    func registerPushToken(_ deviceToken: Data) -> AsyncTask {
        client.registerPushToken(deviceToken)
    }
    
    func handleNotification(_ payload: [AnyHashable : Any], delegate: (any FTRNotificationDelegate)?) {
        client.handleNotification(payload, delegate: delegate)
    }
    
    func getSynchronousAuthToken(userId: String) throws -> String {
       try client.getSynchronousAuthToken(userId: userId)
    }
    
    
    func getOfflineQRVerificationCode(_ parameters: OfflineQRCodeParameters) -> AsyncTaskResult<String> {
        client.getOfflineQRVerificationCode(parameters)
    }
    
    func extraInfoFromOfflineQRCode(_ QRCode: String) -> [FTRExtraInfo] {
        client.extraInfoFromOfflineQRCode(QRCode)
    }
    
    func getTOTP(_ parameters: TOTPParameters) -> AsyncTaskResult<FTRTotp> {
        client.getTOTP(parameters)
    }
    
    func getAccounts() throws -> [FTRAccount] {
        try client.getAccounts()
    }
    
    func getAccountByUserId(_ userId: String) throws -> FTRAccount {
        try client.getAccountByUserId(userId)
    }
    
    func logoutAccount(_ account: FTRAccount) -> AsyncTask {
        client.logoutAccount(account)
    }
    
    func deleteAccount(_ account: FTRAccount) throws {
        try client.deleteAccount(account)
    }
    
    func getAccountsStatus(_ accounts: [FTRAccount]) -> AsyncTaskResult<FTRAccountsStatus> {
        client.getAccountsStatus(accounts)
    }
    
    func getAccountHistory(_ account: FTRAccount) -> AsyncTaskResult<FTRAccountHistory> {
        client.getAccountHistory(account)
    }
    
    func activateBiometrics() throws {
        try client.activateBiometrics()
    }
    
    func deactivateBiometrics() throws {
        try client.deactivateBiometrics()
    }
    
    func changeSDKPin(newSDKPin: String) -> AsyncTask {
        client.changeSDKPin(newSDKPin: newSDKPin)
    }
    
    func getMigratableAccounts() -> AsyncTaskResult<FTRMigrationCheckData> {
        client.getMigratableAccounts()
    }
    
    func migrateAccounts(_ parameters: MigrationParameters) -> AsyncTaskResult<[FTRAccount]> {
        client.migrateAccounts(parameters)
    }
    
    func unlock(_ parameters: UnlockParameters) -> AsyncTask {
        client.unlock(parameters)
    }
    
    func lock() throws {
        try client.lock()
    }
    
    func appAttestation(appId: String, production: Bool) -> AsyncTask {
        client.appAttestation(appId: appId, production: production)
    }
    
    func switchToLockConfiguration(_ parameters: SwitchLockParameters) -> AsyncTask {
        client.switchToLockConfiguration(parameters)
    }
    
    func updateSDKConfig(appGroup: String?, keychainConfig: FTRKeychainConfig?) -> AsyncTask {
        client.updateSDKConfig(appGroup: appGroup, keychainConfig: keychainConfig)
    }
    
    func disableAdaptive() {
        client.disableAdaptive()
    }
    
    func enableAdaptive(delegate: any FTRAdaptiveSDKDelegate) {
        client.enableAdaptive(delegate: delegate)
    }
    
    func enableAdaptiveCollections(delegate: any FTRAdaptiveSDKDelegate) {
        client.enableAdaptiveCollections(delegate: delegate)
    }
    
    func disableAdaptiveCollections() {
        client.disableAdaptiveCollections()
    }
    
    func collectAndSubmitObservations() {
        client.collectAndSubmitObservations()
    }
    
    func enableAdaptiveSubmissionOnAuthentication() throws {
        try client.enableAdaptiveSubmissionOnAuthentication()
    }
    
    func enableAdaptiveSubmissionOnAccountMigration() throws {
        try client.enableAdaptiveSubmissionOnAccountMigration()
    }
    
    func disableAdaptiveSubmissionOnAuthentication() {
        client.disableAdaptiveSubmissionOnAuthentication()
    }
    
    func disableAdaptiveSubmissionOnAccountMigration() {
        client.disableAdaptiveSubmissionOnAccountMigration()
    }
    
    func setAdaptiveTimeThreshold(_ threshold: Int) throws {
        try client.setAdaptiveTimeThreshold(threshold)
    }
    
    func enroll(parameters: EnrollParameters) -> AsyncTask {
        client.enroll(parameters: parameters)
    }
    
    func replyAuth(_ parameters: AuthReplyParameters) -> AsyncTask {
        client.replyAuth(parameters)
    }
}
