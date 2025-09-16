# 🚀 Sending Messages

The **Sending Messages** feature provides a comprehensive API for delivering both traditional text messages and binary data messages via SMS. This guide covers the API structure, request parameters, message processing flow, and best practices for reliable message delivery across different scenarios and priorities.

## 📱 Message Types

 SMSGate supports two main message types: text messages and data messages, each with specific characteristics and use cases.

<div class="grid cards" style="width:100%" markdown>

- :material-message-text: **Text Messages**
    - Standard SMS text content
    - Auto-split for messages >160 chars
    - Supports Unicode characters

- :material-database: **Data Messages**
    - Binary data transmission
    - Base64 encoded content
    - Port-based delivery

</div>

## 📤 API Request Structure

=== "Text Message"
    ```http title="Text Message Request Example"
    POST /3rdparty/v1/messages?skipPhoneValidation=true&deviceActiveWithin=12
    Content-Type: application/json
    Authorization: Basic <credentials>

    {
        "textMessage": {
            "text": "Your OTP is 1234"
        },
        "deviceId": "yVULogr4Y1ksRfnos1Dsw",
        "phoneNumbers": ["+1234567890"],
        "simNumber": 1,
        "ttl": 3600,
        "priority": 100
    }
    ```

=== "Data Message (v1.40.0+)"
    ```http title="Data Message Request Example"
    POST /3rdparty/v1/messages?skipPhoneValidation=true&deviceActiveWithin=12
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
        "priority": 100
    }
    ```

=== "Legacy Text Message (Deprecated)"
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

### Query Parameters

| Parameter             | Type    | Description                                                      | Default | Example |
| --------------------- | ------- | ---------------------------------------------------------------- | ------- | ------- |
| `skipPhoneValidation` | boolean | Disable E.164 phone-number validation                            | `false` | `true`  |
| `deviceActiveWithin`  | integer | Only target devices active within the last *N* hours (`0` = off) | `0`     | `12`    |

### Request Fields

| Parameter            | Type               | Description                                                      | Default                                      | Example                                 |
| -------------------- | ------------------ | ---------------------------------------------------------------- | -------------------------------------------- | --------------------------------------- |
| `id`                 | string             | :material-identifier: Optional unique message ID                 | auto-generated                               | "order-1234"                            |
| `deviceId`           | string             | :material-target: Device ID                                      | `null`                                       | "dev_abc123"                            |
| `textMessage`        | object             | :material-message-text: Text message content                     | `null`                                       | `{ "text": "Hello" }`                   |
| `textMessage.text`   | string             | Text content (auto-split if >160 chars)                          | **required**                                 | "Hello World"                           |
| `dataMessage`        | object             | :material-database: Data message content                         | `null`                                       | `{ "data": "SGVsbG8=", "port": 53739 }` |
| `dataMessage.data`   | string             | Base64-encoded data                                              | **required**                                 | "SGVsbG8="                              |
| `dataMessage.port`   | integer            | Destination port (0-65535)                                       | **required**                                 | `53739`                                 |
| `message`            | string             | ⚠️ Deprecated: Use `textMessage.text` instead                     | `null`                                       | "Hello World"                           |
| `phoneNumbers`       | array              | :material-phone: Recipient numbers                               | **required**                                 | `["+1234567890"]`                       |
| `simNumber`          | integer            | :material-sim: SIM card selection (1-3)                          | [see here](./multi-sim.md#sim-card-rotation) | `1`                                     |
| `ttl`/`validUntil`   | integer/RFC3339    | :material-clock-alert: Message expiration (mutually exclusive)   | never                                        | `3600` or `"2024-12-31T23:59:59Z"`      |
| `withDeliveryReport` | boolean            | :material-checkbox-marked: Delivery confirmation                 | `true`                                       | `true`                                  |
| `priority`           | integer (-128-127) | :material-priority-high: Send priority (-128 to 127)             | `0`                                          | `100`                                   |
| `isEncrypted`        | boolean            | :material-lock: [Message is encrypted](../privacy/encryption.md) | `false`                                      | `true`                                  |

!!! warning "Mutual Exclusivity"
    Only one of `textMessage`, `dataMessage`, or the deprecated `message` field may be specified per request

!!! info "Additional Notes"
    - Phone numbers must be **E.164-compatible**—except when **the message is encrypted** or `skipPhoneValidation=true`
    - `ttl` and `validUntil` are mutually exclusive
    - Priorities ≥100 bypass all limits/delays
    - Data messages require app v1.40.0+ and server v1.24.0+

## 💻 Code Examples

### Text Message

Send `Your OTP is 1234` to `+1234567890` without phone number validation via device with ID `yVULogr4Y1ksRfnos1Dsw` if it was active within the last 12 hours. Skip phone number validation and expire the message after 1 hour. Use SIM card slot #1 and set priority to 100 to bypass all limits/delays.

=== "cURL"
    ```bash title="Send Text Message using cURL"
    curl -X POST "https://api.sms-gate.app/3rdparty/v1/messages?skipPhoneValidation=true&deviceActiveWithin=12" \
      -u "username:password" \
      --json '{
        "textMessage": {
          "text": "Your OTP is 1234"
        },
        "deviceId": "yVULogr4Y1ksRfnos1Dsw",
        "phoneNumbers": ["+1234567890"],
        "simNumber": 1,
        "ttl": 3600,
        "priority": 100
      }'
    ```

=== "Python"
    ```python title="Send Text Message using Python"
    import requests
    from requests.auth import HTTPBasicAuth

    url = "https://api.sms-gate.app/3rdparty/v1/messages"
    params = {"skipPhoneValidation": True, "deviceActiveWithin": 12}

    payload = {
        "textMessage": {"text": "Your OTP is 1234"},
        "deviceId": "yVULogr4Y1ksRfnos1Dsw",
        "phoneNumbers": ["+1234567890"],
        "simNumber": 1,
        "ttl": 3600,
        "priority": 100,
    }

    headers = {
        "Content-Type": "application/json",
    }

    response = requests.post(
        url,
        params=params,
        json=payload,
        headers=headers,
        auth=HTTPBasicAuth("username", "password"),
    )
    print(response.json())
    ```

=== "JavaScript"
    ```javascript title="Send Text Message using JavaScript"
    const axios = require('axios');

    const url = 'https://api.sms-gate.app/3rdparty/v1/messages';
    const params = {
        skipPhoneValidation: true,
        deviceActiveWithin: 12
    };

    const payload = {
        textMessage: {
            text: 'Your OTP is 1234'
        },
        deviceId: 'yVULogr4Y1ksRfnos1Dsw',
        phoneNumbers: ['+1234567890'],
        simNumber: 1,
        ttl: 3600,
        priority: 100
    };

    const headers = {
        'Content-Type': 'application/json',
    };

    axios.post(url, payload, {
        params,
        headers,
        auth: { username: 'username', password: 'password' }
    })
    ```

### Data Message

Send `SGVsbG8gRGF0YSBXb3JsZCE=` (base64-encoded `Hello Data World!`) to `+1234567890` without phone number validation and expire the message after 1 hour. Use SIM card slot #1 and set priority to 100 to bypass all limits/delays.

=== "cURL"
    ```bash title="Send Data Message using cURL"
    curl -X POST "https://api.sms-gate.app/3rdparty/v1/messages?skipPhoneValidation=true&deviceActiveWithin=12" \
      -u "username:password" \
      --json '{
        "dataMessage": {
          "data": "SGVsbG8gRGF0YSBXb3JsZCE=",
          "port": 53739
        },
        "phoneNumbers": ["+1234567890"],
        "simNumber": 1,
        "ttl": 3600,
        "priority": 100
      }'
    ```

=== "Python"
    ```python title="Send Data Message using Python"
    import base64

    import requests
    from requests.auth import HTTPBasicAuth

    url = "https://api.sms-gate.app/3rdparty/v1/messages"
    params = {"skipPhoneValidation": True, "deviceActiveWithin": 12}

    # Sample data: "Hello Data World!" encoded as base64
    message_data = base64.b64encode(b"Hello Data World!").decode("ascii")

    payload = {
        "dataMessage": {"data": message_data, "port": 53739},
        "phoneNumbers": ["+1234567890"],
        "simNumber": 1,
        "ttl": 3600,
        "priority": 100,
    }

    headers = {
        "Content-Type": "application/json",
    }

    response = requests.post(
        url,
        params=params,
        json=payload,
        headers=headers,
        auth=HTTPBasicAuth("username", "password"),
    )
    print(response.json())
    ```

=== "JavaScript"
    ```javascript title="Send Data Message using JavaScript"
    const axios = require('axios');

    const url = 'https://api.sms-gate.app/3rdparty/v1/messages';
    const params = {
        skipPhoneValidation: true,
        deviceActiveWithin: 12
    };

    // Sample data: "Hello Data World!" encoded as base64
    const messageData = Buffer.from('Hello Data World!', 'utf8').toString('base64');

    const payload = {
        dataMessage: {
            data: messageData,
            port: 53739
        },
        phoneNumbers: ['+1234567890'],
        simNumber: 1,
        ttl: 3600,
        priority: 100
    };

    const headers = {
        'Content-Type': 'application/json',
    };

    axios.post(url, payload, {
        params,
        headers,
        auth: { username: 'username', password: 'password' }
    })
    ```

## 🏗️ Message Processing Stages

The steps apply to [Cloud](../getting-started/public-cloud-server.md) and [Private](../getting-started/private-server.md) modes. For [Local](../getting-started/local-server.md) mode, server-side step 2 is skipped.

1. **API Submission**  
    The external app makes a `POST` request to the `/messages` endpoint.

2. **Server Processing**  
    1. Validate payload.
    2. Add message to the queue.
    3. Send a push notification to the device.
    4. Provide messages to the device, sorted by priority, then by enqueue time (descending by default for LIFO; ascending if FIFO is configured).

3. **Device Handling**  
    1. Receive messages from the server.
    2. Add messages to the local queue with `Pending` state.
    3. Get messages one by one from the queue, sorted by priority, then by enqueue time (descending by default for LIFO; ascending if FIFO is configured).
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

## ⚙️ Rate-Limiting and Delays

SMSGate provides mechanisms to control message sending rates and introduce delays between messages. These features help ensure reliable message delivery and compliance with carrier regulations. Configuration can be done through the app's user interface or programmatically via the API.

The primary way to manage rate-limiting and delays is through the app's user interface:

1. **Access Settings**:
    - Open the **Settings** tab within the app.
    - Navigate to **Messages**.

2. **Configure Delays**:
    - **Delay between messages**:
        - Specify a minimum and maximum time (in seconds) to introduce a random delay between sending messages.
        - This helps to simulate a more human-like sending pattern, reducing the likelihood of messages being flagged as spam.

3. **Set Rate Limits**:
    - **Limits**:
        - Specify the maximum number of messages that can be sent within a specified period (minute, hour, or day).
        - When the limit is reached, the app will pause sending messages until the limit period resets.

!!! note "Multiple Recipients"
    When a request includes multiple `phoneNumbers`, it is treated as a single logical message. Delay and rate‑limit evaluations occur once per request, not per recipient. On a single device, the SMS for all recipients are sent back‑to‑back within the same processing slot (not truly simultaneous).

## ⚡ Message Priority

Control message processing order using the `priority` field. Higher priority messages are processed first.

| Level  | Range      | Description                            |
| ------ | ---------- | -------------------------------------- |
| High   | 100 to 127 | Highest priority, bypasses rate limits |
| Normal | 0 to 99    | Standard processing (default)          |
| Low    | -128 to -1 | Low priority                           |

!!! note "Equal Priority Handling"
    When messages share the same `priority` value, the processing order can be configured. By default, messages are processed in **LIFO order** (Last-In-First-Out), but **FIFO order** (First-In-First-Out) can be chosen in the application settings.

!!! tip "Use Cases"
    - :material-run-fast: **High** – time-sensitive messages (OTPs, alerts)
    - :material-walk: **Normal** – routine communications (notifications, reminders)
    - :material-timer-sand: **Low** – non-urgent bulk traffic (marketing, backups)

## 📚 See Also

- [API Documentation](https://api.sms-gate.app) - Complete API reference
- [Data SMS Support](./data-sms.md) - Sending binary data via SMS
- [Message Encryption](../privacy/encryption.md) - Securing message content
- [Multi-SIM Support](./multi-sim.md) - Managing multiple SIM cards
- [Settings Management](./settings-management.md) - Configure rate limits and delays
- [Status Tracking](./status-tracking.md) - Monitor message delivery status
