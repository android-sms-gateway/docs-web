# 🚀 SMS Gateway for Android™

<div align="center">
    <img src="/assets/logo.png" alt="Logo">
</div>

SMS Gateway for Android turns your Android smartphone into an SMS and MMS gateway. It's a lightweight application that allows you to send SMS messages programmatically via an API and receive webhooks on incoming SMS and MMS messages. This makes it ideal for integrating messaging functionality into your own applications or services.

<p align="center"><img src="/assets/screenshot.png" alt="App UI screenshot" width="480"></p>


## Features

📱 Core Functionality:

- 🆓 **No registration required:** No registration or email is required to create an account. In local mode, you don't need an account at all!
- 📨 **Send and Receive SMS via API:** Use [our API](./integration/api.md) to send messages directly from your applications or services.
- 🤖 **Support for Android 5.0 and above:** Compatible with Android 5.0 and later versions. [See Android 15 Note](./faq/general.md#does-the-app-support-android-15)

💬 Message Handling:

- 📜 **Multipart messages:** Send long messages with auto-partitioning.
- 📊 **Message status tracking:** Monitor the status of sent messages in real-time.
- 🔔 **Real-time incoming message notifications:** Receive instant SMS and MMS notifications via [webhooks](./features/webhooks.md).
- 📖 **Retrieve previously received messages:** Access your message history via [Reading Messages](./features/reading-messages/).

🔒 Security and Privacy:

- 🔐 **End-to-end encryption:** Encrypts message content and recipients' phone numbers before sending them to the API and decrypts them on the device.
- 🏢 **Private server support:** Use a backend server in your own infrastructure for enhanced security.

🔧 Advanced Features:

- 💳 **Multiple SIM card support:** Supports devices with [multiple SIM cards](./features/multi-sim.md).
- 📱📱 **Multiple device support:** Connect [multiple devices](./features/multi-device.md) to the same account with Cloud or Private server. Messages sent via the server are distributed across all connected devices.
- 💾 **Data SMS support:** Send and receive binary [data payloads](./features/data-sms.md) via SMS for IoT commands, encrypted messages, and other specialized use cases.

🔌 Integration:

- 🪝 **Webhooks:** Set up [webhooks](./features/webhooks.md) to be triggered on specified events.
- 🚀 **Twilio Fallback Service:** Provides a fallback mechanism for Twilio SMS messages using SMSGate. See [Twilio Fallback Service](./services/twilio-fallback.md) for more information.

## Ideal For

- 🔐 **Authentication & Verification:** Secure user accounts and transactions with SMS-based two-factor authentication, minimizing the risk of unauthorized access.
- 📩 **Transactional Messages:** Send confirmation messages for user actions, enhancing the reliability and perception of your brand.
- ⏰ **SMS Reminders:** Prompt users about upcoming events or appointments to ensure engagement and reduce missed opportunities.
- 🔔 **SMS Notifications:** Deliver immediate notifications to users for important updates, offers, and service enhancements.
- 📊 **User Feedback:** Solicit and collect user feedback through SMS, providing valuable insights for improving your services.

*Note*: It is not recommended to use this for batch sending due to potential mobile operator restrictions.

## Project Stage

The project is currently in the active development stage. We are actively working on adding more features and improving the existing ones. However, some projects already use it in production.

## Get Started

Getting started with SMS Gateway for Android is easy and straightforward. No registration, email, or phone number is required to create an account and start using the app.

Check out our [Getting Started Guide](getting-started/index.md) to learn how to install and use SMS Gateway for Android.

## Contributing

Interested in contributing? Read our [Contributing Guide](contributing.md) to find out how you can help.

## License

This project is licensed under the [Apache License 2.0](license.md).

## Contact

If you have any questions or suggestions, feel free to reach out through the following channels:

- **Issue Tracker:** [https://github.com/capcom6/android-sms-gateway/issues](https://github.com/capcom6/android-sms-gateway/issues)
- **Email:** [support@sms-gate.app](mailto:support@sms-gate.app)
- **Discord:** [Join our Discord server](https://discord.gg/vv9raFK4gX)

### Links

- **Website:** [https://sms-gate.app](https://sms-gate.app)
- **Documentation:** [https://docs.sms-gate.app](https://docs.sms-gate.app)
- **Status Page:** [https://status.sms-gate.app](https://status.sms-gate.app)
- **Project:** [https://github.com/android-sms-gateway](https://github.com/android-sms-gateway)
- **Main Repository:** [https://github.com/capcom6/android-sms-gateway](https://github.com/capcom6/android-sms-gateway)
- **Author GitHub:** [capcom6](https://github.com/capcom6)
