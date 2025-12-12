//
//  FuturaeSDKClientProtocol.swift
//  FuturaeSampleApp
//
//  Created by Armend Hasani on 31.3.25.
//

import FuturaeKit

public protocol FuturaeSDKClientProtocol {
    
    // MARK: - Static/Class methods & properties
    var sdkIsLaunched: Bool { get }
    var clientVersion: String { get }
    func launch(config: FTRConfig) throws
    func enableLogging()
    func disableLogging()
    func checkDataExists(forAppGroup appGroup: String?,
                                 keychainConfig: FTRKeychainConfig?,
                                 lockConfiguration: LockConfiguration) -> Bool
    func reset(appGroup: String?)
    func reset(appGroup: String?, keychain: FTRKeychainConfig?, lockConfiguration: LockConfiguration)
    func setDelegate(_ delegate: FTRClientDelegate?)
    func qrCodeType(from qrCode: String) -> FTRQRCodeType

    // MARK: - Properties
    var isLocked: Bool { get }
    var activeUnlockMethodsValues: [Int] { get }
    var activeUnlockMethods: [UnlockMethodType] { get }
    var currentLockConfiguration: LockConfiguration { get }
    var sdkState: SDKState { get }
    var haveBiometricsChanged: Bool { get }
    var jailbreakStatus: JailbreakStatus { get }
    var isBeta: Bool { get }
    var isAdaptiveEnabled: Bool { get }
    var isAdaptiveSubmissionOnAuthenticationEnabled: Bool { get }
    var isAdaptiveSubmissionMigrationEnabled: Bool { get }
    var pendingAdaptiveCollections: [[String: Any]] { get }

    // MARK: - Core SDK functions
    func sdkStateReport() throws -> SDKReport
    func setUserPresenceDelegate(_ delegate: FTRUserPresenceDelegate?)
    func decryptExtraInfo(_ encryptedExtraInfo: String, userId: String) throws -> [FTRExtraInfo]
    func getSessionInfo(_ parameters: SessionParameters) -> AsyncTaskResult<FTRSession>
    func getSessionInfoWithoutUnlock(_ parameters: SessionParameters) -> AsyncTaskResult<FTRSession>
    func openURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any], delegate: FTROpenURLDelegate?)
    func getNotificationData(_ notificationId: String) -> AsyncTaskResult<FTRNotificationData>
    func registerPushToken(_ deviceToken: Data) -> AsyncTask
    func handleNotification(_ payload: [AnyHashable: Any], delegate: FTRNotificationDelegate?)
    func getSynchronousAuthToken(userId: String) throws -> String
    func getOfflineQRVerificationCode(_ parameters: OfflineQRCodeParameters) -> AsyncTaskResult<String>
    func extraInfoFromOfflineQRCode(_ QRCode: String) -> [FTRExtraInfo]
    func getTOTP(_ parameters: TOTPParameters) -> AsyncTaskResult<FTRTotp>
    func getAccounts() throws -> [FTRAccount]
    func getAccountByUserId(_ userId: String) throws -> FTRAccount
    func logoutAccount(_ account: FTRAccount) -> AsyncTask
    func deleteAccount(_ account: FTRAccount) throws
    func getAccountsStatus(_ accounts: [FTRAccount]) -> AsyncTaskResult<FTRAccountsStatus>
    func getPendingSessions(_ accounts: [FTRAccount]) -> AsyncTaskResult<FTRPendingSessions>
    func getAccountHistory(_ account: FTRAccount) -> AsyncTaskResult<FTRAccountHistory>
    func activateBiometrics() throws
    func deactivateBiometrics() throws
    func changeSDKPin(newSDKPin: String) -> AsyncTask
    func getMigratableAccounts() -> AsyncTaskResult<FTRMigrationCheckData>
    func migrateAccounts(_ parameters: MigrationParameters) -> AsyncTaskResult<[FTRAccount]>
    func unlock(_ parameters: UnlockParameters) -> AsyncTask
    func lock() throws
    func appAttestation(appId: String, production: Bool) -> AsyncTask
    func switchToLockConfiguration(_ parameters: SwitchLockParameters) -> AsyncTask
    func updateSDKConfig(appGroup: String?, keychainConfig: FTRKeychainConfig?) -> AsyncTask
    func disableAdaptive()
    func enableAdaptive(delegate: FTRAdaptiveSDKDelegate)
    func enableAdaptiveCollections(delegate: FTRAdaptiveSDKDelegate)
    func disableAdaptiveCollections()
    func collectAndSubmitObservations()
    func enableAdaptiveSubmissionOnAuthentication() throws
    func enableAdaptiveSubmissionOnAccountMigration() throws
    func disableAdaptiveSubmissionOnAuthentication()
    func disableAdaptiveSubmissionOnAccountMigration()
    func setAdaptiveTimeThreshold(_ threshold: Int) throws
    func enroll(parameters: EnrollParameters) -> AsyncTask
    func replyAuth(_ parameters: AuthReplyParameters) -> AsyncTask
    func exchangeTokenForEnrollmentActivationCode(_ exchangeToken: String) -> AsyncTaskResult<String>
    func exchangeTokenForSessionToken(_ exchangeToken: String) -> AsyncTaskResult<String>
}
