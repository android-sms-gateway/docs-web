# FAQ - Webhooks ❓

## The `sms:received` webhook is not triggering :material-message-question:

If your SMS-received webhook isn't firing, try these solutions:

1. **RCS Interference** :material-chat-processing:  
    ```diff
    - RCS messages don't trigger SMS webhooks
    + Fix: Disable RCS in Google Messages
    ```
    **Steps**:
    - [ ] Install [Google Messages](https://play.google.com/store/apps/details?id=com.google.android.apps.messaging)
    - [ ] Set as default SMS app
    - [ ] Go to Settings → RCS Chats → Disable

2. **Third-Party App Issues** :material-application-import:  
    ```diff
    - Some third-party messaging apps may interfere with SMS event broadcasting.
    + Fix: Use the device's default messaging app or Google Messages
    ```

3. **Permission Check** :material-shield-key:  
    Verify that the app has the necessary permissions

    - [ ] SMS permission granted
    - [ ] Not battery optimized
    - [ ] Background activity allowed

## Can I use webhooks with an HTTP server without encryption? :material-lock-question:

Due to Android OS restrictions and app policy, webhook events can only be received through an encrypted HTTPS connection.

!!! note "Exceptions"

    - Loopback IP address `127.0.0.1` in :material-server: Local mode can be used without encryption.

!!! tip "Private IPs"

    Use [Project CA](../services/ca.md#private-webhook-certificate) :material-certificate: to issue a valid certificate for private IP addresses.

## How to use webhooks with self-signed certificate? :material-certificate-outline:

Support for user-provided self-signed certificates will be removed in version 2.x of the app. It is strongly recommended to use the [project's CA](../services/ca.md#private-webhook-certificate) for generating certificates instead.
    
!!! tip "Migration"

    1. Update the app to the [latest version](https://github.com/capcom6/android-sms-gateway/releases/latest)
    2. [Generate Webhook cert](../services/ca.md#cli)
    3. Update server config to use the new cert
    4. Remove self-signed certs from the device

## How to use webhooks without internet access? :material-wifi-off:

By default, webhooks require internet access and will wait until it's available to improve deliverability. However, if you're using the app in an isolated environment without internet access, you can disable this requirement. Here's how:
    
1. Open app → **Settings** tab
2. Navigate to **Webhooks** section
3. Toggle off "Require Internet connection"
    
!!! warning "Tradeoff"
    
    Disabling internet access requirement may affect the reliability of webhook delivery for external endpoints


### How to manage webhooks for specific devices? :material-cellphone-link:

1. Get device ID from API response when listing devices
2. Include `device_id` parameter when registering webhooks:
   ```json
   {
     "url": "https://your-server.com/webhooks",
     "event": "sms:received",
     "device_id": "MxKw03Q2ZVoomrLeDLlMO"
   }
   ```
3. Webhooks without `device_id` will apply to all devices

## Still Having Issues? :material-chat-question:

Visit our [Support Forum](https://github.com/capcom6/android-sms-gateway/discussions) :material-forum: or contact us at [support@sms-gate.app](mailto:support@sms-gate.app) :material-email:

Include these details:

- App version :material-cellphone-information:
- Android version :material-android:
- Full webhook configuration :material-code-json:
