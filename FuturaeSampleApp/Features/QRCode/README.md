# [QR Codes](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#online-qr-code)

This module demonstrates how to handle **Futurae QR codes** using the FuturaeKit iOS SDK. It provides a complete SwiftUI-based scanner integrated with the SDK’s QR code parsing and flow routing.

The SDK supports multiple types of QR codes, including those for device enrollment, online and offline authentication, and usernameless sessions.

---

## 🛠 Implementation Overview

- `QRScannerView` is a SwiftUI screen that:
  - Displays a live camera preview
  - Shows a scanning reticle
  - Handles permission and scanning lifecycle
  - Initiates flows based on scanned QR code content
- `QRScannerViewModel` is responsible for:
  - Initializing and managing the `AVCaptureSession`
  - Handling scanned QR data
  - Calling `FuturaeService.client.qrCodeType(from:)` to identify the QR type
  - Triggering appropriate app routes (e.g., enrollment, auth, PIN entry)

---

## 🔍 Flow Overview

Futurae QR codes can represent four distinct flows:

1. **Enrollment QR Code**  
   - Detected as `.enrollment`
   - Triggers `AppRoute.enroll(type: .activationCode(code: ...))`

2. **Online Authentication QR Code**  
   - Detected as `.onlineAuth`
   - Triggers `AppRoute.auth(type: .onlineQR(qrCode: ...))`

3. **Offline Authentication QR Code**  
   - Detected as `.offlineAuth`
   - Uses user-selected method from preferences (`.biometrics`, `.sdkPin`, `.default`)
   - Triggers biometric prompt or PIN entry view, then generates verification code using:
     ```swift
     FTRClient.shared.getOfflineQRVerificationCode(...)
     ```

4. **Usernameless QR Code**  
   - Detected as `.usernameless`
   - Prompts the user to select one of the enrolled accounts
   - Then initiates the usernameless auth flow with selected account

If the QR code is invalid or cannot be parsed, the user is notified via an alert.

---

## 🧩 Notes

- The scanner uses `AVCaptureMetadataOutput` to detect QR codes.
- The SDK method `qrCodeType(from:)` returns the appropriate enum case from:
  ```swift
  .enrollment, .onlineAuth, .offlineAuth, .usernameless, .invalid
    ```

* QR scanning is paused automatically after a code is detected to prevent duplicate processing.
* Recovery and retry flows are handled via SwiftUI `.alert` and `.fullScreenCover`.

For more, see the [SDK QR Code documentation](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#online-qr-code).

