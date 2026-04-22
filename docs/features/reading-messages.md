# 📖 Reading Messages

The app not only allows receiving incoming messages in real-time via webhooks but also enables reading previously received messages using the API or exporting them via webhooks.

## 📋 API Endpoints

The app provides three endpoints for reading messages:

| Endpoint                                                   | Method | Description                                          |
| ---------------------------------------------------------- | ------ | ---------------------------------------------------- |
| [`GET /inbox`](#get-inbox)                                 | GET    | List incoming messages with filtering and pagination |
| [`POST /inbox/refresh`](#post-inboxrefresh)                | POST   | Refresh inbox messages without triggering webhooks   |
| [`POST /messages/inbox/export`](#post-messagesinboxexport) | POST   | Export messages via webhooks                         |


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

### POST /messages/inbox/export

Initiates export of inbox messages via webhooks. Triggers `sms:received` webhook for each message in the specified period.

**Endpoint:** `POST /messages/inbox/export`

**Request Body:**
```json title="Request body"
{
  "deviceId": "<device-id>",
  "since": "2024-01-01T00:00:00Z",
  "until": "2024-12-31T23:59:59Z"
}
```

**Example Request:**
```bash title="Export messages via webhooks"
curl -X POST -u <username>:<password> \
  -H "Content-Type: application/json" \
  -d '{ "deviceId": "<device-id>", "since": "2024-01-01T00:00:00Z", "until": "2024-12-31T23:59:59Z" }' \
  https://api.sms-gate.app/3rdparty/v1/messages/inbox/export
```

## 🔧 How to Use

### Option 1: Direct API Access (GET /inbox)

Use this for direct access to message history in the Local Server Mode:

```bash title="Query inbox"
curl -u <username>:<password> \
    "http://<device_local_ip>:8080/inbox?type=SMS&limit=50"
```

### Option 2: Export via Webhooks (POST /messages/inbox/export)

Use this to process historical messages through your existing webhook handler:

1. Register the `sms:received` webhook as described in the [Webhooks](../features/webhooks.md) guide if you haven't done so already.
2. Send a request with `deviceId` and period to the `POST /messages/inbox/export` endpoint:
    ```bash title="Export messages"
    curl -u <username>:<password> \
      -H "Content-Type: application/json" \
      -d '{ "deviceId": "<device-id>", "since": "2024-01-01T00:00:00Z", "until": "2024-12-31T23:59:59Z" }' \
      https://api.sms-gate.app/3rdparty/v1/messages/inbox/export
    ```
3. After receiving the request, the device will send `sms:received` webhooks for each message in the inbox for the specified period.

## 📝 Notes

* The webhook will be sent for each message independently, so the order of messages is not guaranteed.
* It is recommended to split long periods into shorter ones to avoid excessive load on your webhook receiver.
* The export webhooks retry policy is the same as described in the [Webhooks](../features/webhooks.md) guide.
* The ID for incoming messages is generated based on the content of the message and is not guaranteed to be unique.
* Use the `X-Total-Count` header from the `GET /inbox` response to implement pagination.

## 📚 See Also

- [Webhooks Documentation](../features/webhooks.md) - For real-time message notifications
- [API Integration Guide](../integration/api.md) - For detailed API specifications
- [Local Server Mode](../getting-started/local-server.md) - For inbox API in local mode
