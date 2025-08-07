---
title: "Mastering Message Retrieval: A Developer's Guide to GET /messages API"
date: 2025-08-07
categories:
  - API
  - Documentation
description: "Comprehensive guide to implementing SMS API message history retrieval using the RESTful GET /messages API endpoint across local and cloud server environments for reliable message tracking."
author: SMSGate Team LLM
---
# 📱 Mastering Message Retrieval: A Developer's Guide to GET /messages API

Have you ever faced a situation where a customer insisted they never received your critical SMS notification, but your logs showed it was sent? Message delivery tracking is a common pain point for developers integrating SMS functionality, leading to frustrated users and time-consuming debugging sessions. In today's mobile-first world, reliable message history isn't just a nice-to-have—it's essential for customer trust, and operational efficiency. The `GET /messages` API provides a robust RESTful solution for programmatically retrieving SMS message histories across both local server deployments and cloud services. In this comprehensive guide, we'll walk through the technical specifications, share real-world code examples in Python and JavaScript, and provide expert tips for optimizing your message retrieval implementation. By the end, you'll have everything needed to master SMS message history management in your applications.

<!-- more -->

<center>
  <img src="/assets/blog/get-messages-api-guide.png" alt="Message Retrieval Guide">
</center>

## 📬 Endpoint Overview

The `GET /messages` endpoint serves as your central hub for accessing SMS message history. Whether you're building a message history dashboard, implementing auditing, or debugging delivery issues, this API provides structured access to your message data. Unlike basic SMS sending functionality, message retrieval requires careful handling of pagination, filtering, and authentication to ensure efficient and secure access to historical data.

This endpoint supports both [local server deployments](../../getting-started/local-server.md) and [cloud-hosted services](../../getting-started/public-cloud-server.md), with implementation differences that we'll explore throughout this guide. The consistent RESTful design ensures your integration remains maintainable whether you're running on-premises or using our scalable cloud infrastructure.

## 🔒 Technical Specifications

### HTTP Method and Path
```http
GET /messages
```

### Authentication Requirements
This endpoint requires Basic Authentication.

!!! tip "Credential Management"
    Store credentials securely using environment variables or secret management systems. Never hardcode credentials in your source code.

### Parameter Deep Dive

| Parameter  | Type    | Required | Default | Description              | Validation                                            |
| ---------- | ------- | -------- | ------- | ------------------------ | ----------------------------------------------------- |
| `state`    | string  | No       | -       | Message processing state | `Pending`, `Processed`, `Sent`, `Delivered`, `Failed` |
| `offset`   | integer | No       | 0       | Pagination offset        | ≥ 0                                                   |
| `limit`    | integer | No       | 50      | Results per page         | 1-100                                                 |
| `from`     | string  | No       | -       | Start timestamp          | RFC3339 format                                        |
| `to`       | string  | No       | -       | End timestamp            | RFC3339 format                                        |
| `deviceId` | string  | No       | -       | Filter by device ID      | Cloud only: 21-character length                       |

### Response Format
Successful requests return a JSON array of message objects with the `X-Total-Count` header indicating total available messages:

```json title="Example Response"
[
  {
    "id": "I6gSljKlTN3Fe-BJpEcrE",
    "deviceId": "uCh54LY9eovMomc2Un2eU",
    "state": "Pending",
    "isHashed": false,
    "isEncrypted": false,
    "recipients": [
      {
        "phoneNumber": "+1234567890",
        "state": "Pending",
        "error": null
      }
    ],
    "states": {
      "Pending": "2025-07-15T12:30:45Z"
    }
  }
]
```

## 💻 Code Examples

=== "Python"
    ```python title="Message Retrieval with Python Requests"
    import requests
    from datetime import datetime, timedelta

    # Configure for your environment
    BASE_URL = "http://localhost:8080"  # Local
    # BASE_URL = "https://api.sms-gate.app/3rdparty/v1"  # Cloud
    AUTH = ("your_username", "your_password")

    # Get messages from last hour
    one_hour_ago = (datetime.utcnow() - timedelta(hours=1)).strftime("%Y-%m-%dT%H:%M:%SZ")
    params = {
        "from": one_hour_ago,
        "limit": 10
    }

    response = requests.get(
        f"{BASE_URL}/messages",
        auth=AUTH,
        params=params
    )

    if response.status_code == 200:
        messages = response.json()
        total = response.headers.get('X-Total-Count')
        print(f"Retrieved {len(messages)} of {total} messages")
    else:
        print(f"Error: {response.status_code} - {response.text}")
    ```

=== "JavaScript"
    ```javascript title="Message Retrieval with Node.js"
    const axios = require('axios');
    const { DateTime } = require('luxon');

    // Configure for your environment
    const BASE_URL = 'http://localhost:8080'; // Local
    // const BASE_URL = 'https://api.sms-gate.app/3rdparty/v1'; // Cloud
    const auth = { username: 'your_username', password: 'your_password' };

    // Get messages from last hour
    const oneHourAgo = DateTime.utc().minus({ hours: 1 }).toISO();
    const params = {
      from: oneHourAgo,
      limit: 10
    };

    axios.get(`${BASE_URL}/messages`, { auth, params })
      .then(response => {
        console.log(`Retrieved ${response.data.length} of ${response.headers['x-total-count']} messages`);
        // Process messages
      })
      .catch(error => {
        console.error(`Error ${error.response?.status}: ${error.response?.data}`);
      });
    ```

=== "cURL"
    ```bash title="Basic Message Retrieval"
    # Local server example
    curl -u user:pass "http://localhost:8080/messages?limit=10"

    # Cloud service example with time filtering
    curl -u user:pass \
      "https://api.sms-gate.app/3rdparty/v1/messages?from=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)"
    ```
## 🧪 Error Handling

| Status Code | Error Type   | Description             | Troubleshooting Guidance                                           |
| ----------- | ------------ | ----------------------- | ------------------------------------------------------------------ |
| 400         | Bad Request  | Invalid parameters      | Check parameter values against validation rules in the table above |
| 401         | Unauthorized | Invalid credentials     | Verify your username/password                                      |
| 500         | Server Error | Unexpected server error | Contact support                                                    |

!!! failure "Common 401 Scenarios"
    1. Using cloud credentials with local server (or vice versa)
    2. Special characters in password not properly encoded

## 💡 Use Cases


### 1. Message History Dashboard
Build a real-time dashboard showing message delivery status across your user base. Filter by `state` and time ranges to identify delivery bottlenecks. The `X-Total-Count` header enables accurate pagination controls for large datasets. With the actual response structure showing recipient-level states, you can create detailed visualizations of delivery success rates.

### 2. Auditing
Retrieve messages within specific date ranges (`from`/`to` parameters) and verify delivery status for audit trails. The consistent message structure with `states` object ensures reliable data extraction for reporting.

### 3. Customer Support Integration
When customers report missing messages, quickly retrieve their message history using phone number filters. The detailed recipient information in the response allows you to pinpoint exactly which recipients had delivery issues and when.

## 🚀 Performance Tips

### Pagination Best Practices

```python
import requests

def get_all_messages(base_url, auth):
    offset = 0
    limit = 50
    all_messages = []
    with requests.Session() as s:
        s.auth = auth
        while True:
            params = {"offset": offset, "limit": limit}
            r = s.get(f"{base_url}/messages", params=params, timeout=10)
            if r.status_code != 200:
                raise RuntimeError(f"GET /messages failed: {r.status_code} {r.text}")
            messages = r.json()
            if not messages:
                break
            all_messages.extend(messages)
            total = int(r.headers.get("X-Total-Count") or 0)
            offset += len(messages)
            # Stop when we’ve reached the reported total (if provided) or page is short.
            if (total and offset >= total) or len(messages) < limit:
                break
    return all_messages
```

!!! tip "Optimization Strategies"
    - **Time-based filtering**: Always use `from`/`to` parameters when querying historical data
    - **Batch processing**: Process messages in chunks of 20-50 (avoid max `limit` values)
    - **Selective fields**: Only request necessary data to reduce payload size
    - **Caching**: Implement client-side caching for frequently accessed message ranges

## 🎉 Conclusion

Mastering the `GET /messages` API unlocks powerful capabilities for managing your SMS communication flow. By implementing proper pagination, error handling, and environment-specific configurations, you can build robust systems that maintain message history integrity while meeting performance requirements.

Ready to implement message retrieval in your application? Start by exploring our [API documentation](../../integration/api.md) and [client libraries](../../integration/client-libraries.md). For advanced use cases, check out our guide on [webhooks for real-time message notifications](../../features/webhooks.md).

What message retrieval challenges have you faced? Share your experiences in the [discussion section](https://github.com/capcom6/android-sms-gateway/discussions)—we'd love to hear how you're using this API in your projects!

## 🔗 Related Posts

- [Targeting Messages to Specific Devices](./2025-07-20_targeting-messages-to-specific-devices.md)
- [Beyond Plain Text: Unlocking the Hidden Power of Data SMS](./2025-07-12_beyond-plain-text-unlocking-data-sms.md)