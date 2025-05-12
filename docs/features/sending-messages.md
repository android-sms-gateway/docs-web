# Sending Messages 🚀

Send SMS programmatically via API using the `POST /messages` endpoint.

## API Request Structure 📤

```http
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

### Request Fields 🔍

| Parameter            | Type               | Description                                                      | Default                                      | Example                            |
| -------------------- | ------------------ | ---------------------------------------------------------------- | -------------------------------------------- | ---------------------------------- |
| `id`                 | string             | :material-identifier: Optional unique message ID                 | auto-generated                               | "order-1234"                       |
| `message`            | string             | :material-message-text: SMS content (auto-split if >160 chars)   | **required**                                 | "Hello World"                      |
| `phoneNumbers`       | array              | :material-phone: Recipient numbers                               | **required**                                 | `["+1234567890"]`                  |
| `simNumber`          | integer            | :material-sim: SIM card selection (1-3)                          | [see here](./multi-sim.md#sim-card-rotation) | `1`                                |
| `ttl`/`validUntil`   | number/ISO8601     | :material-clock-alert: Message expiration (mutually exclusive)   | never                                        | `3600` or `"2024-12-31T23:59:59Z"` |
| `withDeliveryReport` | boolean            | :material-checkbox-marked: Delivery confirmation                 | `true`                                       | `true`                             |
| `priority`           | integer (-128-127) | :material-priority-high: Send priority (-128 to 127)             | `0`                                          | `100`                              |
| `isEncrypted`        | boolean            | :material-lock: [Message is encrypted](../privacy/encryption.md) | `false`                                      | `true`                             |

!!! info "Additional Notes"
    - Phone numbers should be in E.164 compatible format unless the `skipPhoneValidation` query parameter is set
    - `ttl` and `validUntil` are mutually exclusive
    - Priorities ≥100 bypass all limits/delays
    - Encrypted messages always skip phone validation

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

## Related Guides 📚

- :material-lock: [Message Encryption](../privacy/encryption.md)
- :material-chart-line: [Status Tracking](./status-tracking.md)
- :material-api: [Full API Documentation](https://capcom6.github.io/android-sms-gateway)

!!! tip "Best Practices"
    - Use unique IDs for idempotency
    - Set reasonable TTL values (1-24 hours)
    - Use priority value ≥100 for time-sensitive messages
    - Use webhooks for real-time updates
