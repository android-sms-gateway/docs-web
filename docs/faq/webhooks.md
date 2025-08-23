# ❓ FAQ - Webhooks

## :material-message-question: The `sms:received` webhook is not triggering

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

## 🔒 Can I use webhooks with an HTTP server without encryption?

Due to Android OS security requirements and the app's privacy policy, webhook events can only be received through an encrypted HTTPS connection. This ensures sensitive SMS data (like OTP codes) is protected during transmission.

!!! note "Exceptions"

    - Loopback IP address `127.0.0.1` in :material-server: Local mode can be used without encryption.

!!! important "Private IP Addresses (RFC1918)"
    Webhooks to private IP addresses (like `10.x.x.x`, `172.16.x.x` to `172.31.x.x`, and `192.168.x.x`) **must** use HTTPS.

    This is because Android enforces HTTPS by default for all addresses.

!!! tip "Solutions for Local Networks"
    Use these approaches for local webhook endpoints:
    
    1. **Project CA Certificates**  
        Generate a trusted certificate for your private IP using our [Certificate Authority](../services/ca.md#private-webhook-certificate) :material-certificate:
    
    2. **Localhost with Reverse Port Forwarding**  
        Use `127.0.0.1` with ADB reverse port forwarding to access local servers
    
    3. **Secure Tunnels**  
        Services like [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/) or [ngrok](https://ngrok.com/) provide HTTPS endpoints for local servers

    4. **Insecure Build Variant** (Not Recommended)  
        For local development and testing, use the [insecure build variant](#using-http-webhooks-in-local-development) that allows communication over HTTP without SSL.

??? note "Security Rationale"
    This requirement balances:

    - **Privacy protection** for SMS data
    - **Android platform security** defaults (cleartext restrictions)
    - **Practical flexibility** through the Project CA
    
    While SMS has inherent security limitations, HTTPS provides essential transport-layer protection for webhook payloads.

## :material-certificate-outline: How to use webhooks with a self-signed certificate?

Support for user-provided self-signed certificates will be removed in version 2.x of the app. It is strongly recommended to use the [project's CA](../services/ca.md#private-webhook-certificate) for generating certificates instead.
    
!!! tip "Migration"

    1. Update the app to the [latest version](https://github.com/capcom6/android-sms-gateway/releases/latest)
    2. [Generate Webhook cert](../services/ca.md#cli)
    3. Update server config to use the new cert
    4. Remove self-signed certs from the device

## :material-wifi-off: How to use webhooks without internet access?

By default, webhooks require internet access and will wait until it's available to improve deliverability. However, if you're using the app in an isolated environment without internet access, you can disable this requirement. Here's how:
    
1. Open app → **Settings** tab
2. Navigate to **Webhooks** section
3. Toggle off "Require Internet connection"
    
!!! warning "Tradeoff"    
    Disabling internet access requirement may affect the reliability of webhook delivery for external endpoints

## :material-cellphone-link: How to manage webhooks for specific devices?

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

## :material-test-tube: Using HTTP Webhooks in Local Development

We provide an **insecure build variant** that allows HTTP webhook endpoints for local network deployments.

!!! warning "Production Use Prohibited"
    This build **MUST NOT** be used in public environments as it disables critical security protections. It is strictly for local development and deployment on trusted networks.

### When to Use

Use this build when:

- Testing webhook integrations on local networks (e.g., `192.168.0.100:9876`)
- Developing without a valid SSL certificate
- Needing to test HTTP endpoints during development

### How to Obtain

1. Visit the [GitHub Releases](https://github.com/capcom6/android-sms-gateway/releases) page
2. Download the `app-insecure.apk` file
3. Install following the [standard installation process](../installation.md)

!!! note "Security Considerations"
    - Always revert to the standard (secure) build for production use
    - Never expose insecure builds to public networks
    - This build bypasses Android's cleartext traffic restrictions

## 📨 Why do I receive multiple delivery reports for a single message?

When sending SMS messages longer than the standard character limits (160 characters for GSM/7-bit encoding or 70 characters for Unicode), the message is automatically split into multiple parts. 

Each message part is:

- Sent independently by the carrier
- Processed separately at the network level
- Delivered with its own confirmation receipt

You'll receive separate `sms:delivered` events for each part, but they share the same:

- `messageId` (links all parts to the original message)
- `phoneNumber` (recipient)

See also: [Multipart Message Behavior](../features/webhooks.md#multipart-message-behavior)

## :material-multimedia: Why isn't my MMS webhook triggering?

If your MMS webhook isn't firing, check these potential issues:

1. **Message Type Verification** :material-message-check:
    ```diff
    - Ensure the received message is actually an MMS
    + MMS messages contain attachments (images, videos, audio)
    ```
    **Verification Steps**:
    - [ ] Check if message has multimedia attachments
    - [ ] Verify message size exceeds typical SMS limits
    - [ ] Confirm sender is sending MMS, not SMS or RCS

2. **App Permissions** :material-shield-key:
    ```diff
    - MMS requires additional permissions
    + Ensure RECEIVE_MMS permission is granted
    ```
    **Required Permissions**:
    - [ ] SMS permission
    - [ ] MMS permission

3. **Webhook Registration** :material-webhook:
    ```diff
    - Use correct event type for MMS
    + Event must be "mms:received" (not "sms:received")
    ```

## :material-attachment: Can I receive MMS attachments in webhooks?

The webhook system provides MMS metadata but does **not** include actual attachment content.

## :material-chat-question: Still Having Issues?

Visit our [Support Forum](https://github.com/capcom6/android-sms-gateway/discussions) :material-forum: or contact us at [support@sms-gate.app](mailto:support@sms-gate.app) :material-email:

Include these details:

- App version :material-cellphone-information:
- Android version :material-android:
- Full webhook configuration :material-code-json:
