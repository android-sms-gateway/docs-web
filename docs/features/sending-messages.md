# Sending Messages 🚀

The Sending Messages feature provides a comprehensive API for delivering both traditional text messages and binary data messages via SMS. This guide covers the API structure, request parameters, message processing flow, and best practices for reliable message delivery across different scenarios and priorities.

## API Request Structure 📤

### Text Message
```http title="Text Message Request Example"
POST /3rdparty/v1/messages
Content-Type: application/json
Authorization: Basic <credentials>

{
  "textMessage": {
    "text": "Your OTP is 1234"
  },
  "phoneNumbers": ["+1234567890"],
  "simNumber": 1,
  "ttl": 3600,
  "withDeliveryReport": true,
  "priority": 100,
  "isEncrypted": false
}
```

### Data Message (v1.40.0+)
```http title="Data Message Request Example"
POST /3rdparty/v1/messages
Content-Type: application/json
Authorization: Basic <credentials>

{
  "dataMessage": {
    "data": "SGVsbG8gRGF0YSBXb3JsZCE=",
    "port": 53739
  },
  "phoneNumbers": ["+1234567890"],
  "simNumber": 1,
  "ttl": 3600,
  "withDeliveryReport": true,
  "priority": 100,
  "isEncrypted": false
}
```

### Legacy Text Message (Deprecated)
```http title="Legacy Message Request Example"
POST /3rdparty/v1/messages
Content-Type: application/json
Authorization: Basic <credentials>

{
  "id": "custom-id-123",
  "message": "Your OTP is 1234",
  "phoneNumbers": ["+1234567890"],
  "simNumber": 1,
  "ttl": 3600,
  "withDeliveryReport": true,
  "priority": 100,
  "isEncrypted": false
}
```

### Request Fields

| Parameter            | Type               | Description                                                      | Default                                      | Example                                 |
| -------------------- | ------------------ | ---------------------------------------------------------------- | -------------------------------------------- | --------------------------------------- |
| `id`                 | string             | :material-identifier: Optional unique message ID                 | auto-generated                               | "order-1234"                            |
| `textMessage`        | object             | :material-message-text: Text message content                     | `null`                                       | `{ "text": "Hello" }`                   |
| `textMessage.text`   | string             | Text content (auto-split if >160 chars)                          | **required**                                 | "Hello World"                           |
| `dataMessage`        | object             | :material-database: Data message content                         | `null`                                       | `{ "data": "SGVsbG8=", "port": 53739 }` |
| `dataMessage.data`   | string             | Base64-encoded data                                              | **required**                                 | "SGVsbG8="                              |
| `dataMessage.port`   | integer            | Destination port (0-65535)                                       | **required**                                 | `53739`                                 |
| `message`            | string             | ⚠️ Deprecated: Use `textMessage.text` instead                     | `null`                                       | "Hello World"                           |
| `phoneNumbers`       | array              | :material-phone: Recipient numbers                               | **required**                                 | `["+1234567890"]`                       |
| `simNumber`          | integer            | :material-sim: SIM card selection (1-3)                          | [see here](./multi-sim.md#sim-card-rotation) | `1`                                     |
| `ttl`/`validUntil`   | number/ISO8601     | :material-clock-alert: Message expiration (mutually exclusive)   | never                                        | `3600` or `"2024-12-31T23:59:59Z"`      |
| `withDeliveryReport` | boolean            | :material-checkbox-marked: Delivery confirmation                 | `true`                                       | `true`                                  |
| `priority`           | integer (-128-127) | :material-priority-high: Send priority (-128 to 127)             | `0`                                          | `100`                                   |
| `isEncrypted`        | boolean            | :material-lock: [Message is encrypted](../privacy/encryption.md) | `false`                                      | `true`                                  |

!!! warning "Mutual Exclusivity"
    Only one of `textMessage`, `dataMessage`, or the deprecated `message` field may be specified per request

!!! info "Additional Notes"
    - Phone numbers should be in E.164 compatible format unless `skipPhoneValidation=true`
    - `ttl` and `validUntil` are mutually exclusive
    - Priorities ≥100 bypass all limits/delays
    - Encrypted messages always skip phone validation
    - Data messages require app v1.40.0+ and server v1.24.0+

## Message Processing Stages 🏗️

The steps apply to [Cloud](../getting-started/public-cloud-server.md) and [Private](../getting-started/private-server.md) modes. For [Local](../getting-started/local-server.md) mode, server-side step 2 is skipped.

1. **API Submission**  
    The external app makes a `POST` request to the `/messages` endpoint.

2. **Server Processing**  
    1. Validate payload.
    2. Add message to the queue.
    3. Send a push notification to the device.
    4. Provide messages to the device, sorted by priority and enqueue time.

3. **Device Handling**  
    1. Receive messages from the server.
    2. Add messages to the local queue with `Pending` state.
    3. Get messages one by one from the queue, sorted by priority and enqueue time.
    4. Apply limits/delays. Skip this step for messages with priority >= 100.
    5. Send SMS via Android SMS API and set the message status to `Processed`.

4. **Status Tracking**  
    Refer to the [Status Tracking](./status-tracking.md#message-lifecycle) guide to monitor the message status.

!!! tip "Best Practices"
    - **Batch Sending**:
        - Split large batches into small groups
        - Add delays between batches
        - Use priority ≥100 to bypass rate limits
    - **Message Handling**:
        - Use unique IDs for idempotency
        - Always set TTL values
        - Implement exponential backoff for retries
    - **Monitoring**:
        - Use webhooks for real-time status updates
        - Monitor for [`RESULT_ERROR_LIMIT_EXCEEDED` errors](../faq/errors.md#result_error_limit_exceeded-error-)

## Message Priority ⚡

Control message processing order using the `priority` field. Higher priority messages are processed first.

| Level  | Range      | Description                            |
| ------ | ---------- | -------------------------------------- |
| High   | 100 to 127 | Highest priority, bypasses rate limits |
| Normal | 0 to 99    | Standard processing (default)          |
| Low    | -128 to -1 | Low priority                           |


!!! tip "Use Cases"
    - :material-run-fast: **High** – time-sensitive messages (OTPs, alerts)
    - :material-walk: **Normal** – routine communications (notifications, reminders)
    - :material-timer-sand: **Low** – non-urgent bulk traffic (marketing, backups)

## See Also 📚

- [Status Tracking](./status-tracking.md) - Monitor message delivery status
- [Data SMS Support](./data-sms.md) - Sending binary data via SMS
- [Message Encryption](../privacy/encryption.md) - Securing message content
- [Multi-SIM Support](./multi-sim.md) - Managing multiple SIM cards
- [API Documentation](https://capcom6.github.io/android-sms-gateway) - Complete API reference