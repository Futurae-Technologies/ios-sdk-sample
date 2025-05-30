# [Accounts](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#account-status)

This module demonstrates how to display a list of enrolled accounts using the FuturaeKit iOS SDK, along with options to interact with each account: generate TOTP/HOTP tokens, view account history, or remove accounts.

---

## 🛠 Implementation Overview

- `AccountsView` is the main SwiftUI screen responsible for:
  - Displaying a list of enrolled accounts
  - Showing TOTP values and expiration timers
  - Handling account deletion and logout
  - Displaying a migration banner if account recovery is available

- `AccountsViewModel` handles:
  - Fetching and updating account data
  - TOTP generation with `FTRClient.shared.getTOTP(...)`
  - HOTP generation using `getSynchronousAuthToken(...)`
  - Logout via `logoutAccount(...)`
  - Detecting available account migrations

- `AccountHistoryView` is a SwiftUI screen that displays the authentication history of a selected account.
- `AccountHistoryViewModel` fetches history using `getAccountHistory(...)`.

---

## 🔍 Flow Overview

### Account List
- When the screen appears, `loadAccounts()` is called to retrieve and display enrolled accounts.
- For each account:
  - A current **TOTP** is generated and displayed.
  - A countdown bar updates every second and re-fetches TOTP upon expiration.
  - Locked accounts show an indicator instead of TOTP.

### Interactions
- **Tap an account**: Navigate to `AccountHistoryView` to see past authentications.
- **Long-press actions** (via UI buttons):
  - Generate **HOTP** using `getSynchronousAuthToken(...)`, and copy to clipboard.
  - **Log out**: Calls `logoutAccount(...)` and removes the account.
  - **Delete**: Calls `deleteAccount(...)` for local-only removal.

### Account Migration
If the SDK detects accounts eligible for recovery (via `getMigratableAccounts()`), a **migration banner** is shown:
- Tap the banner to navigate to the Account Recovery flow.
- See [Account Recovery README](https://github.com/Futurae-Technologies/ios-sdk-sample/blob/main/FuturaeSampleApp/Features/AccountMigration/README.md) for more information.

---

## ✅ Notes

- All TOTP updates and timers are handled with Combine and `Timer.publish`.
- This view does not unlock the SDK automatically. If it is locked, TOTP generation will not succeed.
- `AccountItem` is a model that aggregates SDK account data with current TOTP and remaining seconds.

For more information on accounts operations, see the [Futurae iOS SDK Documentation](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#account-status).
