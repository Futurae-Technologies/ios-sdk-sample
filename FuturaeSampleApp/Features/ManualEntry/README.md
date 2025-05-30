
# [Manual Entry Enrollment](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#enroll-with-activation-shortcode)

This module demonstrates how to enroll a Futurae account using an **activation shortcode** instead of scanning a QR code. It provides a user interface for manually entering a 16-digit code and triggering the enrollment flow using the FuturaeKit iOS SDK.

---

## 🛠 Implementation Overview

- `ManualEntryView` is a SwiftUI screen that:
  - Presents an input field for a 16-digit activation shortcode
  - Formats user input automatically with spaces (`0000 0000 0000 0000`)
  - Submits the code when valid and routes to the enrollment flow
- `ManualEntryViewModel` is responsible for:
  - Managing the shortcode state
  - Validating the code length
  - Formatting the input
  - Posting a route change via `NotificationCenter` to initiate the enrollment flow

---

## 🔍 Flow Overview

1. The user is prompted to enter a 16-digit activation shortcode manually.
2. As the user types, the code is automatically formatted in groups of 4 digits for readability.
3. When the code reaches the required length, the **Submit** button is enabled.
4. On submission, the view model posts a route change:
   ```swift
   NotificationCenter.default.post(name: .appRouteChanged, object: AppRoute.enroll(type: .shortCode(code: ...)))
    ```

5. The app then proceeds to enroll the account using:

   ```swift
   FTRClient.shared.enroll(.with(shortCode: code))
   ```

---

## ✅ Notes

* The `TextField` uses `.asciiCapable` keyboard and disables autocorrection to ensure clean input.
* You can customize the formatting behavior by editing the `formatActivationCode` helper.
* Enrollment via shortcode is particularly useful when QR scanning is not possible or for app-side silent flows.

For more details, refer to the [iOS SDK Enrollment Docs](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#enroll-with-activation-shortcode).

