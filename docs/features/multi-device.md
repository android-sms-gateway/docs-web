# 📱📱 Multi-Device Support

The app supports multiple devices for a single account in **Cloud** or **Private Server** modes, distributing messages across all connected devices.

## ➕ Adding a Device

Both methods use the same registration dialog. It opens when you start the service on a device that is not registered yet:

1. Open the app on the new device
2. Activate :material-cloud: **Cloud Server**
3. Tap **Start Service** - if the device is not registered yet, a dialog opens with three tabs: **Sign Up** (default), **Sign In**, and **By Code**

![First start registration dialog with the By Code tab active](../assets/first-start-dialog.png){ width="480" }

The dialog cannot be dismissed by tapping outside; tap **Cancel** to abort without starting the service.

!!! tip "Join Later or Recover Access"
    :gear: **Settings** → **Cloud Server** → **Sign in to existing account** opens the same dialog on demand whenever Cloud Server mode is enabled - even if the device is already registered. Signing in replaces the current registration.

=== ":material-account-key: Username & Password"
    !!! tip
        Use this method for trusted devices, which will have full access to the account.

    **Steps 📋**

    1. Open the registration dialog (see above)
    2. Choose the **Sign In** tab
    3. Enter username and password
    4. Confirm to join the account
    5. Wait for Cloud Server information in the Home tab

=== ":material-lock-reset: One-Time Code"
    !!! tip
        Use this method for untrusted devices, which will only have limited access to the account.

    **Generate Code 🔑**

    1. On an already-registered device:  
       :gear: Settings → Cloud Server → Login code  
       The generator is visible only while the device is registered.
    2. Wait for code to appear
    3. Long press to copy

    **Apply Code 📲**

    1. Open the registration dialog (see above)
    2. Choose the **By Code** tab
    3. Enter the code
    4. Confirm with "Continue"

## 📨 Message Distribution

=== ":fontawesome-solid-dice: Random Selection (Default)"
    ```bash
    curl https://api.sms-gate.app/3rdparty/v1/messages \
      -u "username:password" \
      --json '{
        "textMessage": {"text": "Test message"},
        "phoneNumbers": ["+19162255887"]
    }'
    ```

=== ":material-target: Explicit Selection"
    ```bash
    curl https://api.sms-gate.app/3rdparty/v1/messages \
      -u "username:password" \
      --json '{
        "textMessage": {"text": "Test message"},
        "phoneNumbers": ["+19162255887"],
        "deviceId": "dev_abc123"
    }'
    ```

## ⚙️ Device Management

### API Endpoints

=== ":material-api: List Devices"
    ```bash
    curl -X GET \
      https://api.sms-gate.app/3rdparty/v1/devices \
      -u "username:password"
    ```
    [API Documentation](https://api.sms-gate.app/#/User/get_3rdparty_v1_devices)

=== ":material-delete: Remove Device"
    ```bash
    curl -X DELETE \
      https://api.sms-gate.app/3rdparty/v1/devices/DEVICE_ID \
      -u "username:password"
    ```
    [API Documentation](https://api.sms-gate.app/#/User/delete_3rdparty_v1_devices__id_)

!!! danger "Device Removal Warning"
    Deleting a device will remove all associated messages, including pending ones. This action cannot be undone.
