# [SDK Configuration](https://www.futurae.com/docs/guide/futurae-sdks/mobile-sdk-ios/#configuration-and-initialization)

This screen allows developers to configure and launch the Futurae iOS SDK (`FuturaeKit`) with a customizable setup, supporting a wide range of options such as keychain policies, app group access, and lock configuration settings.

The configuration screen supports five modes:
- **Setup** – Configure and launch the SDK for the first time.
- **Switch Lock** – Change the lock configuration while preserving account state.
- **Update Config** – Update app group or keychain settings.
- **Check Data** – Check if SDK state exists under specific configuration.
- **View** – Read-only view of current configuration.

---

## 🛠 Implementation Overview

- `SDKConfigurationView` provides the UI for entering SDK credentials and toggling platform-related options (like App Groups and Keychain Sharing).
- `SDKConfigurationViewModel` manages the logic to:
  - Launch or reconfigure the SDK
  - Switch lock modes (including prompting for a PIN if necessary)
  - Check for persisted SDK data
  - Persist the configuration to local preferences

All configuration is stored in a `SDKConfigurationData` struct and persisted using `GlobalPreferences`.

---

## 🔧 Configuration Options

### 🔐 Lock Configuration
Supports multiple SDK lock types:
- `None`
- `Biometrics Only`
- `Biometrics or Passcode`
- `SDK PIN (Biometrics Optional)`

Additional options include:
- Unlock duration (2–300 seconds)
- Invalidation of unlock state on biometric changes
- Biometric behavior after PIN change

### 🔒 Keychain Settings
Configure how SDK secrets are stored:
- Use Keychain Access Groups
- Keychain item accessibility (e.g., `.afterFirstUnlockThisDeviceOnly`)

### 📦 App Group Access
Enable use of an App Group to support:
- App extensions (like Notification Services)
- Shared storage across multiple targets

### 🔐 SSL Pinning
Optionally enable SSL pinning for additional transport security.

---

## 🧪 Feature Actions

### Launch SDK
```swift
try FuturaeService.client.launch(config: ftrConfig)
````

### Switch Lock Configuration

```swift
try await FuturaeService.client.switchToLockConfiguration(parameters).execute()
```

### Update SDK Configuration

```swift
try await FuturaeService.client.updateSDKConfig(appGroup:keychainConfig:).execute()
```

### Check SDK Data Exists

```swift
let exists = FuturaeService.client.checkDataExists(forAppGroup:keychainConfig:lockConfiguration:)
```

---

## ✅ Notes

* The `SDKConstants` struct defines static identifiers (e.g., App Group, Keychain Group) which should be updated if used in your app setup.
* If you select `sdkPinWithBiometricsOptional` and no SDK PIN has been configured yet, the app will prompt the user to enter one.
* For testing changes in lock type behavior, use the **Switch Lock Configuration** mode.
