# 🚀 Futurae - iOS SDK Sample App

This repository contains a sample iOS application showcasing how to integrate and use the [FuturaeKit SDK](https://github.com/Futurae-Technologies/ios-sdk). It demonstrates the implementation of all major features of the Futurae iOS SDK using Swift architecture.

## 📢 Disclaimer
The SDK Sample App in this repository is provided as is and is intended solely as an example implementation to assist customers in integrating Futurae’s SDKs. This SDK Sample App is not designed for production use, and Futurae does not offer support or maintenance for it. Futurae makes no representations or warranties, express or implied, including but not limited to, any warranties of merchantability or suitability, or fitness for a particular purpose, or non-infringement, regarding the SDK Sample App. Futurae does not warrant that the SDK Sample App will be uninterrupted or error free or without delay.

## 🛠 Getting Started

### 1. **Clone the repository**
```bash
git clone git@github.com:Futurae-Technologies/ios-sdk-sample.git

```

### 2. **Install dependencies**

This project uses Swift Package Manager (SPM). After opening the project in Xcode, the necessary packages should resolve automatically.

Alternatively, the SDK can also be integrated using CocoaPods or Carthage. Please refer to the [SDK Installation Guide](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#installation) for more details.

### 3. **Configuration**

To run the sample:

-   Open `FuturaeSampleApp/SDKConfiguration.swift` and update it with your SDK credentials (`sdkId`, `sdkKey`, `baseUrl`).
    
If you're using app extensions (like `UNNotificationServiceExtension`), you must configure `appGroup` and `keychainAccessGroup`, and enable the corresponding entitlements—**Push Notifications**, **Keychain Sharing**, and **App Groups**—in the **Signing & Capabilities** tab of your Xcode project.
    

### 4. **Run the app**

Build and run the application on a physical device or simulator.

## 🌿 Branches

This app is used internally to test and showcase the iOS SDK. The `main` branch represents the latest stable version.

## 🧩 Architecture

The project uses a modular structure organized by feature. Each feature may include:

-   A SwiftUI `View`
    
-   A `ViewModel` handling business logic
    
-   Shared code in `Common/` (utilities, UI components, etc.)
    

## 📚 Feature Documentation

The sample app covers the following core SDK features:

| Feature / Flow             | Description                                     | README                                                                                          |
|----------------------------|-------------------------------------------------|-------------------------------------------------------------------------------------------------|
| SDK Configuration          | Overview and usage of SDK configuration options | [SDK Configuration](/FuturaeSampleApp/Features/Configuration/README.md)                         |
| Enrollment                 | Flows for enrolling the device                  | [Enrollment](/FuturaeSampleApp/Features/Enrollment/README.md)                                   |
| Accounts                   | Active account list                             | [Accounts](/FuturaeSampleApp/Features/Accounts/README.md)                                       |
| Manual Entry               | Enrolling using short activation code           | [Manual Entry](/FuturaeSampleApp/Features/ManualEntry/README.md)                                |
| QR Code Scanning           | Flows initiated via QR code scanning            | [QR Code Scanning](/FuturaeSampleApp/Features/QRCode/README.md)                                 |
| Unlock SDK                 | Handling unlocking of the SDK                   | [Unlock SDK](/FuturaeSampleApp/Features/Unlock/README.md)                                       |
| Automatic Account Recovery | Account recovery from previous installments     | [Account Recovery](/FuturaeSampleApp/Features/AccountMigration/README.md)                       |
| Authentication             | Handle push, QR, and offline authentication     | [Authentication](/FuturaeSampleApp/Features/Authentication/README.md)                           |


## 📄 Documentation

For detailed information about the SDK, please refer to our [Official iOS SDK Documentation](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/)
    

## 🤝 Contributing

We welcome contributions! Fork the repository, create a feature branch, and submit a pull request.

## 📜 License

This project is licensed under the [Apache License 2.0](https://github.com/Futurae-Technologies/ios-sdk-sample/blob/main/License.txt).
