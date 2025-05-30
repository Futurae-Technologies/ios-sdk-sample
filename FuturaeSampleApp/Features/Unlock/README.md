# [Lock Configuration](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#user-presence-verification)

This module demonstrates how to configure and interact with the **Locking Mechanism** of the FuturaeKit iOS SDK. The SDK provides a secure way to protect sensitive operations through configurable user presence verification.

Supported lock configuration types:
- `.none`: No user verification required
- `.biometricsOnly`: Only biometric authentication (Face ID / Touch ID)
- `.biometricsOrPasscode`: Biometrics or device passcode
- `.sdkPinWithBiometricsOptional`: A custom SDK PIN is required; biometrics can be optionally enabled for convenience

---

## 🛠 Implementation Overview

- `SDKUnlockView` is a SwiftUI screen that handles unlocking the SDK based on the configured lock type. It supports:
  - Custom SDK PIN input with masked digit circles and a numeric keypad
  - Biometric authentication with system prompt
- `SDKUnlockViewModel` manages:
  - Unlock attempts via PIN or biometrics
  - Error feedback and loading state
  - Active unlock methods retrieved from the SDK (e.g., `activeUnlockMethods`)

The unlock view automatically presents the most appropriate unlocking mechanism based on the active configuration.

---

## 🔍 Flow Overview

This screen is used when:

- The SDK is locked (`FTRClient.shared.isLocked == true`) and the user attempts a protected action (e.g., approving a session).
- The user launches the app and must unlock the SDK to access protected content.
- The app explicitly presents the unlock view after certain workflows (e.g., enrollment, changing PIN, enabling biometrics).

### Unlock Logic
1. The app checks which unlock methods are available via `FTRClient.shared.activeUnlockMethods`.
2. Depending on the configuration:
   - If `.sdkPinWithBiometricsOptional`, the SDK PIN is always required. Biometrics can be used only if previously activated.
   - If `.biometricsOrPasscode`, either biometrics or the device passcode will suffice.
3. The unlock action is executed via:
```swift
try await FuturaeService.client.unlock(.with(sdkPin: pin)).execute()
````

or

```swift
try await FuturaeService.client.unlock(.with(biometricsPrompt: "Unlock with Face ID")).execute()
```

4. On success, the `onUnlocked` callback is invoked to return to the protected operation.

---

## 🧩 Notes

* Unlocking the SDK is required before using **protected functions** such as account recovery, TOTP generation, or approving sessions.
* The SDK remains unlocked for the duration configured in `unlockDuration` (default: 60 seconds).
* You can call `FTRClient.shared.lock()` manually when security-sensitive workflows complete.

For more information, see the [SDK lock configuration documentation](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#user-presence-verification).

