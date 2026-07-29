# 📱 MMS Support (Multimedia Messaging Service)

The SMSGate application supports receiving MMS messages through webhook notifications. This feature allows you to monitor incoming multimedia messages and integrate them into your applications and services.

## 📋 Overview

MMS (Multimedia Messaging Service) support enables your SMSGate to receive and process multimedia messages containing images, videos, audio files, and other attachments. The application provides two distinct MMS webhook events at different stages of message delivery:

- **`mms:received`** — Fires when the MMS **notification** (WAP push) arrives, before the message is downloaded. Provides metadata only (transaction ID, subject, size, content class).
- **`mms:downloaded`** — Fires when the MMS has been **fully downloaded** to the device. Includes the message body, subject, and attachments with base64-encoded content.

!!! note "Receive-Only Support"
    The application currently supports **receiving MMS messages only**. Sending MMS messages is not available.

## 🚀 Prerequisites

The following permissions must be granted to the SMSGate application to enable MMS support:

- **RECEIVE_SMS**: Required for receiving SMS messages
- **RECEIVE_MMS**: **Required for MMS functionality** - enables the app to receive multimedia messages
- **READ_PHONE_STATE**: Optional, for SIM card information

## 📊 MMS Webhook Events

### `mms:received` — Arrival Notification

Triggered when the device receives a WAP push notification for an incoming MMS. This event fires **before** the message content is downloaded and contains metadata only.

```json
{
  "deviceId": "ffffffffceb0b1db0000018e937c815b",
  "event": "mms:received",
  "id": "Ey6ECgOkVVFjz3CL48B8C",
  "payload": {
    "messageId": "mms_12345abcde",
    "sender": "+1234567891",
    "recipient": "+1234567890",
    "simNumber": 1,
    "transactionId": "T1234567890ABC",
    "subject": "Photo attachment",
    "size": 125684,
    "contentClass": "IMAGE_BASIC",
    "receivedAt": "2025-08-23T05:15:30.000+07:00"
  },
  "webhookId": "<unique-id>"
}
```

Field descriptions can be found in the [Webhook Supported Events](./webhooks.md#supported-events) section.

### `mms:downloaded` — Full Content

Triggered when the MMS content has been fully downloaded to the device content provider. This event fires **after** `mms:received` and includes the message body and attachments.

```json
{
  "deviceId": "ffffffffceb0b1db0000018e937c815b",
  "event": "mms:downloaded",
  "id": "Ey6ECgOkVVFjz3CL48B8C",
  "payload": {
    "messageId": "mms_12345abcde",
    "sender": "+1234567891",
    "recipient": "+1234567890",
    "simNumber": 1,
    "body": "Hello! Here is the photo.",
    "subject": "Photo attachment",
    "attachments": [
      {
        "partId": 1,
        "contentType": "image/jpeg",
        "name": "photo.jpg",
        "size": 125684,
        "data": "/9j/4AAQ..."
      }
    ],
    "receivedAt": "2025-08-23T05:15:35.000+07:00"
  },
  "webhookId": "<unique-id>"
}
```

Field descriptions can be found in the [Webhook Supported Events](./webhooks.md#supported-events) section.

!!! tip "Attachment Data"
    The `data` field in each attachment contains the raw content encoded in Base64 when available and may be `null` if the content is unavailable. This enables programmatic processing — for example, decoding and saving images, or forwarding attachments to other services.

## 🚫 Limitations

- **Receive-Only**: MMS messages cannot be sent through the API
- **`mms:received` Metadata Only**: The arrival notification provides metadata only — no message text or attachment content is included
- **`mms:downloaded` Attachment Size**: Large attachments may impact webhook payload size and delivery performance. The attachment `size` and `data` fields may be `null` if the content is unavailable
- **Carrier Dependencies**: Functionality varies by mobile carrier and network conditions

## 📚 See Also

- [Webhook Configuration](./webhooks.md) - Complete webhook setup guide
- [API Documentation](../integration/api.md) - SMS API reference
- [Webhook Troubleshooting](../faq/webhooks.md) - Webhook-specific issues
