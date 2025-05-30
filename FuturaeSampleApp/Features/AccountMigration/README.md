# [Automatic Account Recovery](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#automatic-account-recovery)

This module demonstrates how to implement **Automatic Account Recovery** using the FuturaeKit iOS SDK. It provides a complete SwiftUI-based example to help you integrate account migration into your own app.

The feature allows users to recover Futurae accounts from a previous installation—either on a different device (via iCloud or encrypted iTunes backup) or the same device after reinstalling the app. The SDK securely restores accounts if the necessary migration data is available and compatible.

If [Trusted Session Binding](https://www.futurae.com/docs/api/auth?json#create-trusted-session-binding-token) or [Adaptive Account Recovery](https://www.futurae.com/docs/guide/adaptive-account-recovery/) is enabled, the app also handles those scenarios.

---

## 🛠 Implementation Overview

- `AccountMigrationView` is a SwiftUI flow that walks the user through checking for migratable accounts, confirming restoration, and completing the process.
- `AccountMigrationViewModel` encapsulates the core logic:
  - Checks for migratable accounts using `FTRClient.shared.getMigratableAccounts()`
  - Triggers migration via `FTRClient.shared.migrateAccounts(...)`
  - Handles requirements like SDK PIN input or binding token input if needed
- The view displays different UI states (`idle`, `loading`, `success`, `failure`, `noAccountsToMigrate`) and presents modals when user input is required.

---

## 🔍 Flow Breakdown

1. The app starts by calling `getMigratableAccounts()`.
   - If the SDK is already initialized and has **no accounts**, and migration data exists, the SDK returns metadata indicating if recovery is possible and whether a **PIN** is required.
2. If migration is possible:
   - If `pinProtected == true` or the lock type is `.sdkPinWithBiometricsOptional`, the user is prompted to enter their SDK PIN.
   - If the app is configured to use **Trusted Session Binding**, the user is also prompted for a binding token.
3. Once prerequisites are satisfied, `migrateAccounts()` is called.
   - On success, accounts are restored and propagated via `NotificationCenter`.
   - Errors are caught and displayed to the user.
4. If `numberOfAccountsToMigrate == 0`, a "no accounts to migrate" message is shown.

---

## ✅ Notes

- Recovery will **only succeed if no accounts are already enrolled** in the SDK on the current installation.
- If `Adaptive Account Recovery` is enabled, the SDK internally performs risk analysis. If the environment is untrusted, migration will be blocked.
- To use `Trusted Session Binding`, provide the token during the `migrateAccounts()` call via `MigrationParameters`.

---

For more details, refer to the [iOS SDK Docs on Account Recovery](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#automatic-account-recovery).
