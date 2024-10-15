# Privacy Policy

We are committed to transparency and the protection of user privacy. This document outlines how we handle information within our app.

## Data Handling

### Local Server

- **Public IP Retrieval**: 
    - The app retrieves your public IP address via the Cloud or Private server, depending on your settings.
    - This request includes the app version and, if applicable, the Cloud or Private server token.

### Cloud Server

- **Encrypted Communication**: All communication between the app and the cloud server is protected with secure encryption protocols, safeguarding your data during transit.
- **End-to-End Encryption**: We offer optional AES-based end-to-end encryption. When enabled:
    - Messages and phone numbers are encrypted before being sent to the API.
    - Data remains encrypted during transmission and is only decrypted on the user's device when sending the SMS.
    - This ensures that no entity, including us (the service provider), the hosting provider, or any intermediaries, can access message contents or recipient details.
- **Message Handling**: If end-to-end encryption is not used:
    - Message content and recipient information are transformed into a SHA256 hash within 15 minutes of device acknowledgment.
    - This prevents the storage of this information in plain text.
- **Limited Data Sharing**: Only necessary data is shared with the server to facilitate cloud services, including:
    - Device manufacturer
    - Device model
    - App version
    - Firebase Cloud Messaging (FCM) token

### Private Server

- **Push Notification Handling**: 
    - Push notifications are routed through the cloud server.
    - These notifications contain only the device's FCM token.
    - No SMS content or recipient information is included in these notifications.

## User Privacy

- **No Usage Statistics Collection**: 
    - We do not track or collect any usage statistics, including crash reports.
    - Your app interactions remain private and unmonitored.

## Your Rights

- You have the right to access, correct, or delete your personal data.
- For any privacy-related inquiries or requests, please contact us at [privacy@sms-gate.app](mailto:privacy@sms-gate.app).

## Data Retention

- **Unused Accounts**: Accounts that have been inactive for 1 year will be automatically deleted with all associated data including pending messages.
- **Processed Messages**: Information related to processed messages will be retained for 1 month, after which it will be deleted.

## Policy Updates

- **Version History**:
    - Prior to version 1.22: The external service [ipify](https://www.ipify.org) was used for public IP retrieval.

We are committed to keeping you informed about how we protect your privacy. Any future changes to this policy will be updated here.

By using our app, you agree to the terms outlined in this privacy policy.

