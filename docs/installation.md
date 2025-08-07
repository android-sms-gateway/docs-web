# 📲 Installation

The recommended way to install the application is from a prebuilt APK.

## 🔍 Prerequisites

The app requires an Android device with Android 5.0 (Lollipop) or later.

### Permissions

Grant the following permissions for full functionality:

- **SEND_SMS**: Essential for sending SMS messages.
- **READ_PHONE_STATE**: Allows SIM card selection, if utilized.
- **RECEIVE_SMS**: Required for receiving SMS messages and sending `sms:received` webhook.

## 📦 Installing from APK

1. Visit the [Releases page](https://github.com/capcom6/android-sms-gateway/releases) on GitHub.
2. Select and download the most recent APK.
3. Move the APK file to your Android device.
4. Access **Settings** > **Security** or **Privacy** on your device.
5. Activate **Unknown sources** to allow installations from non-Play Store sources.
6. Use a file manager to find the APK file on your device.
7. Tap the APK to begin installation.
8. Complete the setup as prompted on-screen.


### Build Variants

The application is available in two build variants:

- **Standard (Secure) Build**: Recommended for most users. Enforces HTTPS for all communications (except `127.0.0.1`).
- **Insecure Build**: For advanced users during local development. Allows HTTP webhook endpoints on local networks. **Not recommended for production use.**

*See also: [Using HTTP Webhooks in Local Development](./faq/webhooks.md#using-http-webhooks-in-local-development)*

## 🔒 Private Server Integration

For instructions on setting up a private server, refer to [Getting Started - Private Server](./getting-started/private-server.md)

## 📚 See Also

- [Getting Started - Private Server](./getting-started/private-server.md)
- [Getting Started - Public Cloud Server](./getting-started/public-cloud-server.md)