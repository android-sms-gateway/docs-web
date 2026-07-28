# 📖 Reading Messages

The app not only allows receiving incoming messages in real-time via webhooks but also enables reading previously received messages using the API or exporting them via webhooks.

## 📋 API Endpoints

The app provides three endpoints for reading messages:

| Endpoint                                                          | Method | Description                                          |
| ----------------------------------------------------------------- | ------ | ---------------------------------------------------- |
| [`GET /inbox`](#get-inbox)                                        | GET    | List incoming messages with filtering and pagination |
| [`POST /inbox/refresh`](#post-inboxrefresh)                       | POST   | Refresh inbox messages without triggering webhooks   |
| [`POST /3rdparty/v1/inbox/refresh`](#post-3rdpartyv1inboxrefresh) | POST   | Export messages via webhooks                         |


!!! note
    The `/inbox` endpoints group is only available in the Local Server Mode.

### GET /inbox

Retrieves incoming messages with filtering and pagination support.

**Endpoint:** `GET /inbox`

**Query Parameters:**

| Parameter  | Type    | Required | Description                                                        |
| ---------- | ------- | -------- | ------------------------------------------------------------------ |
| `type`     | string  | No       | Filter by message type: `SMS`, `DATA_SMS`, `MMS`, `MMS_DOWNLOADED` |
| `limit`    | integer | No       | Maximum messages to return (1-500, default: 50)                    |
| `offset`   | integer | No       | Number of messages to skip (default: 0)                            |
| `from`     | string  | No       | Start of date range (ISO 8601 format)                              |
| `to`       | string  | No       | End of date range (ISO 8601 format)                                |
| `deviceId` | string  | No       | Filter by device ID                                                |

**Example Request:**
```bash title="List inbox messages"
curl -u <username>:<password> \
  "http://<device_local_ip>:8080/inbox?type=SMS&limit=10&offset=0"
```

**Response:**
```json title="Response"
[
  {
    "id": "PyDmBQZZXYmyxMwED8Fzy",
    "type": "SMS",
    "sender": "+79990001234",
    "recipient": "+79990001234",
    "simNumber": 1,
    "contentPreview": "Hello World!",
    "createdAt": "2020-01-01T00:00:00Z"
  }
]
```

**Response Headers:**
- `X-Total-Count`: Total number of messages available

### POST /inbox/refresh

Refreshes inbox messages without triggering webhooks. This re-processes messages internally.

**Endpoint:** `POST /inbox/refresh`

**Request Body:**
```json title="Request body"
{
  "deviceId": "<device-id>",
  "since": "2024-01-01T00:00:00Z",
  "until": "2024-12-31T23:59:59Z"
}
```

**Example Request:**
```bash title="Refresh inbox messages"
curl -X POST -u <username>:<password> \
  -H "Content-Type: application/json" \
  -d '{ "deviceId": "<device-id>", "since": "2024-01-01T00:00:00Z", "until": "2024-12-31T23:59:59Z" }' \
  http://<device_local_ip>:8080/inbox/refresh
```

### POST /3rdparty/v1/inbox/refresh

Triggers inbox refresh with configurable webhook delivery mode.

**Endpoint:** `POST /3rdparty/v1/inbox/refresh`

**Request Body:**
```json title="Request body"
{
  "deviceId": "<device-id>",
  "since": "2024-01-01T00:00:00Z",
  "until": "2024-12-31T23:59:59Z",
  "webhookDelivery": "Individual"
}
```

**Webhook Delivery Modes:**

| Value        | Description                                                    |
| ------------ | -------------------------------------------------------------- |
| `Individual` | Each message triggers its own webhook (default behavior)       |
| `Batch`      | Messages are grouped into batch webhooks (up to 100 per batch) |
| `Disabled`   | Messages are saved but no webhooks are triggered               |

**Example — Export with Batch Webhooks:**
```bash title="Batch export"
curl -X POST -u <username>:<password> \
  -H "Content-Type: application/json" \
  -d '{
    "since": "2024-06-01T00:00:00Z",
    "until": "2024-06-30T23:59:59Z",
    "webhookDelivery": "Batch"
  }' \
  https://api.sms-gate.app/3rdparty/v1/inbox/refresh
```

**Example — Export without Webhooks:**
```bash title="Silent export"
curl -X POST -u <username>:<password> \
  -H "Content-Type: application/json" \
  -d '{
    "since": "2024-06-01T00:00:00Z",
    "until": "2024-06-30T23:59:59Z",
    "webhookDelivery": "Disabled"
  }' \
  https://api.sms-gate.app/3rdparty/v1/inbox/refresh
```

## 🔧 How to Use

### Option 1: Direct API Access (GET /inbox)

Use this for direct access to message history in the Local Server Mode:

```bash title="Query inbox"
curl -u <username>:<password> \
    "http://<device_local_ip>:8080/inbox?type=SMS&limit=50"
```

### Option 2: Export via Webhooks (POST /3rdparty/v1/inbox/refresh)

Use this to process historical messages through your existing webhook handler:

1. Register the webhook event (e.g. `sms:received` or `sms:batch:received`) as described in the [Webhooks](../features/webhooks.md) guide if you haven't done so already.
2. Send a request with the desired `webhookDelivery` mode:
    ```bash title="Individual export"
    curl -u <username>:<password> \
      -H "Content-Type: application/json" \
      -d '{
        "since": "2024-01-01T00:00:00Z",
        "until": "2024-12-31T23:59:59Z",
        "webhookDelivery": "Individual"
      }' \
      https://api.sms-gate.app/3rdparty/v1/inbox/refresh
    ```
3. After receiving the request, the device will send webhooks for each message in the inbox for the specified period.

## 📝 Notes

* For `Individual` mode, webhooks are sent for each message independently, so the order of messages is not guaranteed.
* For `Batch` mode, messages are delivered in chronological order in batch payloads of up to 100 messages.
* It is recommended to split long periods into shorter ones to avoid excessive load on your webhook receiver.
* The export webhooks retry policy is the same as described in the [Webhooks](../features/webhooks.md) guide.
* The ID for incoming messages is generated based on the content of the message and is not guaranteed to be unique.
* Use the `X-Total-Count` header from the `GET /inbox` response to implement pagination.

## 📚 See Also

- [Webhooks Documentation](../features/webhooks.md) - For real-time message notifications and batch webhooks
- [API Integration Guide](../integration/api.md) - For detailed API specifications
- [Local Server Mode](../getting-started/local-server.md) - For inbox API in local mode
