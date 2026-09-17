# 📱 MMS Support (Multimedia Messaging Service)

The SMSGate application supports both sending and receiving MMS messages. You can send multimedia content via the API and receive incoming MMS messages through webhook notifications.

## 📋 Overview

MMS (Multimedia Messaging Service) support enables your SMSGate to:

- **Send** multimedia messages (images, videos, audio, other attachments) via the [Messages API](../integration/api.md) by using the `mmsMessage` payload on `POST /3rdparty/v1/messages`.
- **Receive** and process incoming multimedia messages via webhook notifications.

Two distinct MMS webhook events fire at different stages of incoming message delivery:

- **`mms:received`** — Fires when the MMS **notification** (WAP push) arrives, before the message is downloaded. Provides metadata only (transaction ID, subject, size, content class).
- **`mms:downloaded`** — Fires when the MMS has been **fully downloaded** to the device. Includes the message body, subject, and attachments with base64-encoded content.

Outgoing MMS delivery status is reported through the existing outbound SMS webhook events (`sms:sent`, `sms:failed`, `sms:cancelled`) — see [Delivery Status and Webhooks](#delivery-status-and-webhooks).

## 📨 Sending MMS Messages

You can send MMS messages via the `POST /3rdparty/v1/messages` endpoint by including an `mmsMessage` field instead of `textMessage`. The request envelope must contain **exactly one** of `message`, `textMessage`, `dataMessage`, or `mmsMessage`.

### Request Structure

```json
{
  "phoneNumbers": ["+1234567890"],
  "mmsMessage": {
    "subject": "Hello",
    "text": "World",
    "attachments": [
      {
        "contentType": "image/png",
        "name": "picture.png",
        "data": "BASE64DATA"
      }
    ]
  }
}
```

### Wire Format Rules

- `mmsMessage` is one of the mutually exclusive payload variants. Combining it with `message`, `textMessage`, or `dataMessage` is rejected with HTTP 400.
- `subject` and `text` are optional; a valid MMS must specify a **non-empty `text` or at least one attachment**.
- `attachments` is an optional array and is **omitted from the JSON body entirely when empty**. `subject`, `text`, and attachment `name` are omitted when null/empty.
- Each attachment has `contentType` (required), `data` (required, base64-encoded content), and `name` (optional).
- No MIME allowlist is enforced: any `contentType` is accepted, and the client is responsible for sending a type the carrier will accept (for example `image/png`, `image/jpeg`, `video/mp4`, `audio/mpeg`).
- No size limit is enforced server-side at this time. Real-world limits come from your mobile carrier (typically 300KB-1MB per MMS) — keep attachments within carrier bounds.

### Fields

| Field         | Type   | Required | Description                                                         |
| ------------- | ------ | -------- | ------------------------------------------------------------------- |
| `subject`     | string | No       | MMS subject line                                                    |
| `text`        | string | No       | Text body of the MMS (non-empty `text` or >= 1 attachment required) |
| `attachments` | array  | No       | Array of attachment objects (omitted when empty)                    |

Each attachment object:

| Field         | Type   | Required | Description                               |
| ------------- | ------ | -------- | ----------------------------------------- |
| `contentType` | string | Yes      | MIME type (e.g. `image/png`, `video/mp4`) |
| `data`        | string | Yes      | Base64-encoded content                    |
| `name`        | string | No       | Filename                                  |

!!! note "Validation"
    - A valid MMS contains a **non-empty `text` or at least one attachment**; a request with neither is rejected.
    - Each attachment requires `contentType` and base64-encoded `data`.
    - The base64 content is decoded on the device, which composes the MMS and submits it to the carrier.

### Example (cURL)

```bash
curl -X POST -u <username>:<password> \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumbers": ["+1234567890"],
    "mmsMessage": {
      "subject": "Hello",
      "text": "World",
      "attachments": [
        {
          "contentType": "image/png",
          "name": "picture.png",
          "data": "BASE64DATA"
        }
      ]
    }
  }' \
  https://api.sms-gate.app/3rdparty/v1/messages
```

## 💻 SDK Examples

Outbound MMS is officially supported by the Go and Rust SDKs. Each example below produces the same wire payload as the [request structure above](#request-structure).

=== "Go"

    ```go
    // import "github.com/android-sms-gateway/client-go/smsgateway"
    subject := "Hello"
    text := "World"
    name := "picture.png"

    msg := smsgateway.Message{
        PhoneNumbers: []string{"+1234567890"},
        MmsMessage: &smsgateway.MmsMessage{
            Subject: &subject,
            Text:    &text,
            Attachments: []smsgateway.MmsAttachment{
                {
                    ContentType: "image/png",
                    Name:        &name,
                    Data:        "BASE64DATA",
                },
            },
        },
    }

    state, err := client.Send(ctx, msg)
    ```

    JSON marshaling omits `subject`, `text`, `name`, and `attachments` when they are unset, mirroring the wire rules above.

=== "Rust"

    ```rust
    use android_sms_gateway::{
        Client, ClientConfig,
        types::{MmsAttachment, MmsMessage, Message, SendOptions},
    };

    let client = Client::new(ClientConfig::new().with_basic_auth("username", "password"))?;

    let message = Message {
        phone_numbers: vec!["+1234567890".into()],
        mms_message: Some(MmsMessage {
            subject: Some("Hello".into()),
            text: Some("World".into()),
            attachments: vec![MmsAttachment {
                content_type: "image/png".into(),
                name: Some("picture.png".into()),
                data: "BASE64DATA".into(),
            }],
        }),
        ..Default::default()
    };

    let state = client.send(&message, &SendOptions::new()).await?;
    ```

## 📊 Delivery Status and Webhooks

Outgoing MMS messages follow the same [message lifecycle](./status-tracking.md#message-lifecycle) as SMS messages: they are enqueued with `POST /3rdparty/v1/messages`, tracked via `GET /3rdparty/v1/messages/{id}`, and can be cancelled with `DELETE /3rdparty/v1/messages/{id}` while pending.

Status reporting for outbound MMS differs from SMS in two important ways:

- **No delivery receipts on Android**: `Sent` is the terminal success state for MMS — there is no `Delivered` state and no `sms:delivered` event for MMS messages.
- **Status arrives via the existing `sms:*` events**: the Android app reports outbound MMS results **directly** with the standard, fixed payloads of the existing `sms:sent`, `sms:failed`, and `sms:cancelled` events. There are **no `mms:*` outbound events** and no server-side MMS webhook changes — register webhooks for `sms:sent`, `sms:failed`, and `sms:cancelled` to track outgoing MMS.

Incoming MMS events (`mms:received`, `mms:downloaded`) are unchanged.

!!! note "Attachment Data Is Not Downloadable"
    There is no server endpoint to download attachments of **outgoing** MMS messages. Keep a copy of anything you send if you need it later; the server only stores the submitted base64 payload for delivery to the device.

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

- **`mms:received` Metadata Only**: The arrival notification provides metadata only — no message text or attachment content is included
- **`mms:downloaded` Attachment Size**: Large attachments may impact webhook payload size and delivery performance. The attachment `size` and `data` fields may be `null` if the content is unavailable
- **No Delivery Receipts**: Android does not provide delivery receipts for MMS — `Sent` is the terminal success state and `sms:delivered` never fires
- **Outgoing Attachments Not Downloadable**: The server exposes no endpoint to download attachments of outgoing messages
- **Carrier Dependencies**: Functionality varies by mobile carrier and network conditions

## 📚 See Also

- [Sending Messages](./sending-messages.md) - API payload reference for all message types
- [Webhook Configuration](./webhooks.md) - Complete webhook setup guide
- [Status Tracking](./status-tracking.md) - Message lifecycle and status monitoring
- [API Documentation](../integration/api.md) - Messages API reference
- [Webhook Troubleshooting](../faq/webhooks.md) - Webhook-specific issues
