
# [Enrollment](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#enroll)

This module demonstrates how to enroll a device for a Futurae user using the FuturaeKit iOS SDK.

There are two primary enrollment methods shown:
- via an **activation QR code**
- via an **activation shortcode**

The flow supports both **user-driven** enrollment (scanning a QR code, entering a shortcode) and **silent** enrollment using a pre-provided activation code and optional binding token.

---

## 🛠 Implementation Overview

- `EnrollmentView` is a SwiftUI flow responsible for handling all enrollment paths. It manages:
  - Displaying the enrollment progress and results
  - Prompting the user for a **binding token** or **SDK PIN** if required
  - Showing success or error screens
- `EnrollmentViewModel` contains the logic for:
  - Constructing appropriate `EnrollParameters`
  - Triggering the SDK’s `enroll(...)` method
  - Handling success and updating the UI with the newly enrolled account

Supported sources of enrollment:
- QR scan (`EnrollType.activationCode`)
- Manual entry (`EnrollType.shortCode`)

---

## 🔍 Flow Overview

1. The app routes to the enrollment screen with a `EnrollType` (activation code or shortcode).
2. The view checks if extra steps are required before enrollment:
   - If the SDK lock type is `.sdkPinWithBiometricsOptional` and no PIN is set, the user is prompted to enter one.
   - If **Trusted Session Binding** is enabled, the user is prompted to enter a **binding token**.
3. Once all inputs are collected, enrollment proceeds via:
   ```swift
   try await FuturaeService.client.enroll(parameters: parameters).execute()
    ```

4. If enrollment is successful, the newly enrolled account is retrieved and displayed.
5. On failure, the error is shown and the user can retry.

---

## ✅ Notes

* All combinations of:

  * SDK lock type (none, biometric, PIN)
  * Binding token presence
  * Activation code format (QR or short code)
    are supported.
* `EnrollParameters.with(...)` is used to construct the correct enrollment call for the SDK.
* The final screen confirms enrollment and shows the service name and username (if available).

