# 📱 MMS Support (Multimedia Messaging Service)

The SMSGate application supports receiving MMS messages through webhook notifications. This feature allows you to monitor incoming multimedia messages and integrate them into your applications and services.

## 📋 Overview

MMS (Multimedia Messaging Service) support enables your SMSGate to receive and process multimedia messages containing images, videos, audio files, and other attachments. When an MMS message is received, the application triggers a webhook notification with detailed metadata about the message.

!!! note "Receive-Only Support"
    The application currently supports **receiving MMS messages only**. Sending MMS messages is not available.

## 🚀 Prerequisites

The following permissions must be granted to the SMSGate application to enable MMS support:

- **RECEIVE_SMS**: Required for receiving SMS messages
- **RECEIVE_MMS**: **Required for MMS functionality** - enables the app to receive multimedia messages
- **READ_PHONE_STATE**: Optional, for SIM card information

## 📊 MMS Webhook Payload

When an MMS message is received, your webhook will receive a POST request with the following JSON structure:

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

The description of each field can be found in the [Webhook Supported Events](./webhooks.md#supported-events) section.

## 🚫 Limitations

- **Receive-Only**: MMS messages cannot be sent through the API
- **No Attachment Content**: Webhooks provide metadata only, not actual content
- **Carrier Dependencies**: Functionality varies by mobile carrier and network conditions

## 📚 See Also

- [Webhook Configuration](./webhooks.md) - Complete webhook setup guide
- [API Documentation](../integration/api.md) - SMS API reference
- [Webhook Troubleshooting](../faq/webhooks.md) - Webhook-specific issues
