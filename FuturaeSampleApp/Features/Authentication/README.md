
# [Authentication](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#authenticate-user)

This screen demonstrates how to handle user authentication requests via the Futurae iOS SDK. It supports multiple authentication types, including:

- **Push Auth**
- **Online QR Code**
- **Offline QR Code**
- **Usernameless Auth (QR and URL)**
- **Deep-link URL Auth**

The flow handles session retrieval, user feedback, multi-numbered challenges, and offline verification code display.

---

## 🛠 Getting Started

- `AuthApprovalView` displays the authentication prompt and dynamically adjusts based on the session type.
- `AuthApprovalViewModel` manages the session retrieval, user decisions, and SDK reply handling.

The view is initialized with an `AuthApprovalType`, which encapsulates the input source (e.g. QR code or push session).

---

## 🔍 Flow Overview

### Session Info Retrieval
Upon appearing, the view:
1. Extracts session parameters from the input (`AuthApprovalType`)
2. Calls either:
   - `getSessionInfo` for secure retrieval (if configured)
   - `getSessionInfoWithoutUnlock` for unprotected access
3. Matches the session to an enrolled account

### Display Flow

- For **Online/Push/Usernameless Auth**, the UI shows:
  - Account info (logo, username, service)
  - Metadata from the session (`extraInfo`)
  - Approve / Reject / Fraud buttons

- For **Offline QR**, the app skips session retrieval and instead extracts metadata locally and requests a verification code via:
  ```swift
  getOfflineQRVerificationCode(parameters)
    ```

* For **Multi-numbered Challenges**, the user is prompted to select the correct number before an approval is submitted.

### Sending Replies

Replies are sent with:

```swift
FuturaeService.client.replyAuth(parameters).execute()
```

Different reply parameter builders are used depending on the flow:

* `.replyPush(...)`
* `.replyQRCode(...)`
* `.replyUsernamelessQRCode(...)`
* `.replyUsernamelessAuth(...)`
* `.replyMobileAuth(...)`
* `.replyMultiNumber(...)`

If the authentication flow includes a redirect URL, it is opened automatically after the reply.

---

## ✅ UI States

The screen supports the following views:

* **Loading View** – Shown while session info is loading
* **Approval View** – Displays auth metadata and approval buttons
* **Verification Code View** – For offline QR codes
* **Success View** – Displays the selected reply (e.g. "Approve reply sent")
* **Error View** – In case of network or SDK errors

---

