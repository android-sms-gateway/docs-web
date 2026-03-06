# ❌ FAQ - Errors

## 🛡️ "Does not have `android.permission.SEND_SMS`" Error

The app requires the `android.permission.SEND_SMS` permission to send SMS messages. While the app requests this permission on first launch, if for any reason it wasn't granted you may need to grant it manually.

=== "Via Settings"

    1. :gear: Open device Settings → Apps → SMSGate
    2. :material-shield-key: Navigate to Permissions → SMS
    3. :material-toggle-switch: Enable SMS permission
        
    !!! tip "Hidden Permissions"
        On some devices:

        1. Tap ⋮ menu → "All permissions"
        2. Locate SMS under "Not allowed" section
        3. Change to "Allow"

    !!! tip "Restricted Settings"
        If the permission is grayed out:

        1. Tap **More** → **Allow restricted settings**
        2. Navigate to Permissions → SMS and enable it

    !!! note "Community Contribution"
        Special thanks to *@mabushey* and *@AlexxIT* for the SMS permission solution!
        [:material-github: Issue #184](https://github.com/capcom6/android-sms-gateway/issues/184)  
        [:material-github: Issue #280](https://github.com/capcom6/android-sms-gateway/issues/280)

=== "Via ADB"

    1. :material-android: Enable **USB Debugging** on your device (Settings → Developer Options)
    2. :material-usb: Connect your device to a computer with ADB installed
    3. :material-shield-key: Grant permissions via ADB:
        ```bash title="Grant SMS Permissions via ADB"
        adb shell pm grant me.capcom.smsgateway android.permission.SEND_SMS
        adb shell pm grant me.capcom.smsgateway android.permission.RECEIVE_SMS
        adb shell pm grant me.capcom.smsgateway android.permission.READ_PHONE_STATE
        ```
    4. :material-restart: Reboot your device

    !!! warning "Important"
        - The SMS permission will remain grayed out in Settings even after granting via ADB - this is expected behavior on Android 15+
        - You only need to do this once (permissions persist after app updates)
        - If you uninstall and reinstall the app, you'll need to grant permissions again via ADB

## ⚠️ `RESULT_ERROR_GENERIC_FAILURE` Error

The `RESULT_ERROR_GENERIC_FAILURE` error can occur for various reasons:

- :money_with_wings: **Low Balance**: Check SIM balance
- :material-signal-off: **Network Issues**: Verify signal bars, try airplane mode toggle
- :material-sim-off: **SIM Problems**:
    - Reinsert SIM card.
    - Test in a different device.
    - Contact carrier for activation status.
- 📋 **Delivery Reports**: Try to disable delivery reports by adding `"withDeliveryReport": false` to your request.

## 🚫 `RESULT_ERROR_LIMIT_EXCEEDED` Error

The `RESULT_ERROR_LIMIT_EXCEEDED` error occurs when:

1. Reaching Android's internal SMS queue limit
2. Exceeding carrier-imposed sending limits
3. Triggering anti-spam protections
4. Sending long messages with many parts (9+ SMS parts)

This error indicates the system has blocked further messages to prevent abuse. Key considerations:

- **Android Queue Limit**: The OS restricts sending to many messages in a short period. The limits can be adjusted via ADB, see [this guide](https://www.xda-developers.com/change-sms-limit-android/)
- **Carrier Limits**: Most carriers allow 30-200 SMS/hour. Exceeding may cause temporary blocks. Always consult your carrier's policy.
- **SIM Risks**: High-volume sending may lead to carrier penalties or SIM blocking. Always check your carrier's Terms of Service (ToS).

**See Also 📚**

- [How can I avoid mobile operator restrictions?](./general.md#how-can-i-avoid-mobile-operator-restrictions) FAQ entry.

## 📶 `RESULT_RIL_MODEM_ERR` Error

The `RESULT_RIL_MODEM_ERR` error usually indicates a problem with the device's modem or the communication between the application and the modem. This error can stem from various causes:

- SIM card not properly seated  
- Outdated modem firmware  

!!! tip "Troubleshooting Checklist"
    1. :material-restart: Reboot device  
    2. :material-sim: Clean SIM contacts with alcohol swab
    3. :material-update: Install latest OS updates  
    4. :material-factory: Reset network settings

## 📱 `RESULT_NO_DEFAULT_SMS_APP` Error

The `RESULT_NO_DEFAULT_SMS_APP` error occurs when no default SMS app is set on the device or when the default SIM for sending SMS messages hasn't been configured. To resolve this issue, follow these steps:

1. Open :gear: Settings → Apps → Default apps  
2. Select default messaging app  
3. Choose preferred SIM for sending in the default messaging app

!!! tip "API Workaround"
    To send SMS using a specific SIM card, provide the SIM card slot number in the `simNumber` field of your request.

    ```json title="Explicit SIM Specification" hl_lines="4"
    {
        "textMessage": { "text": "Test"},
        "phoneNumbers": ["+1234567890"],
        "simNumber": 1
    }
    ```

## 📴 `Can't send message: No SIMs found` Error

This error occurs when the app cannot detect any SIM cards on the device. There are several possible causes for this issue:

=== "Hardware Issues"  
 
    - :material-sim-alert: SIM not fully inserted  
    - :material-chip: SIM card has poor contact  
    - :material-wrench: Damaged SIM tray
 
=== "Software Issues"  
 
    1. :material-shield-refresh: For Xiaomi devices:
        - Enable Developer Options (tap Build Number 7x)
        - Disable MIUI optimizations to prevent the app from requesting permissions repeatedly
        - Reboot device
 
    2. :material-key-chain: Ensure the app has all required permissions in your device settings or via ADB.  
        ```bash
        adb shell pm list permissions | grep READ_PHONE_STATE
        ```

!!! tip "Debugging"
    If the problem persists, try using the SIM card in another device to rule out hardware issues.
