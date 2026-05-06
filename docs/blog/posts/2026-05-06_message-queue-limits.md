---
title: "Introducing Message Queue Limits: Better Queue Management for SMS Delivery"
date: 2026-05-06
categories:
  - Features
  - API
  - Infrastructure
description: "Learn about the new message queue limits feature for SMSGate Cloud and Private Server deployments. Protect your infrastructure from overwhelmed devices and ensure reliable message delivery."
author: SMSGate Team
---

# 📨 Introducing Message Queue Limits: Better Queue Management for SMS Delivery

We're announcing a new **Message Queue Limits** feature that adds configurable rate limiting and queue management capabilities to the SMS Gateway server. This feature helps prevent devices from being overwhelmed with message processing tasks and ensures reliable SMS delivery across your infrastructure.

<!-- more -->

## 🎯 Why Queue Limits Matter

In high-volume SMS operations, it's crucial to manage message queues effectively:

1. **Prevent Device Overload**: Devices can become overwhelmed with thousands of pending messages
2. **Stale Message Buildup**: Old pending messages can accumulate when devices go offline
3. **Resource Protection**: Shared infrastructure needs protection from misbehaving devices
4. **Reliability**: Ensures messages are processed within acceptable timeframes

## ⚙️ How Queue Limits Work

The limiter component monitors device message queues and enforces three types of limits:

| Limit Type          | Description                                             |
| ------------------- | ------------------------------------------------------- |
| **Max Pending**     | Maximum number of pending messages in a device's queue  |
| **Max Pending Age** | Maximum age of pending messages before they're rejected |
| **Max Failed**      | Maximum failed messages in a time window                |

When any limit is exceeded, the API returns **HTTP 503 Service Unavailable** with a descriptive error:

```json
{
  "error": "QueueLimitExceeded",
  "message": "queue limits exceeded: <reason>"
}
```

!!! info "Common Error Reasons"
    - `too many pending messages: X / Y` - Device queue has too many pending messages
    - `too old pending message: <timestamp>` - Oldest pending message exceeds the configured age limit
    - `too many failed messages` - All recent messages have failed

## 🖥️ Server Type Differences

The queue limits behavior varies depending on your deployment type:

=== "Public Cloud"
    For **Public Cloud** deployments, the system enforces **automatic queue management** with a fixed 24-hour limit:

    | Limit Type          | Behavior                          |
    | ------------------- | --------------------------------- |
    | **Max Pending Age** | Automatically set to **24 hours** |
    | Other Limits        | Not configurable (unlimited)      |

    This automatic limit protects the shared infrastructure from devices with stale pending messages and ensures fair resource allocation across all users.

=== "Private Server"
    For **self-hosted Private Server** deployments, **all queue limits are configurable**. See [Private Server Documentation](../features/private-server.md#-message-queue-limits) for detailed configuration options.

## ✅ Best Practices

1. **Use Message TTL**: Always set `ttl` or `validUntil` to prevent messages from queuing indefinitely
2. **Start Conservative**: Begin with lower limits and adjust based on observed device performance
3. **Monitor Metrics**: Watch the limiter metrics to understand when limits are triggered

## 🔄 Migration Notes

- The queue limits feature is **opt-in** by default (all limits set to 0/unlimited)
- Existing deployments will continue to work without changes
- To enable limits, configure at least one of the queue limit parameters
- On Public Cloud, the 24-hour oldest message limit is always active and cannot be disabled

## 📚 Learn More

- [Sending Messages Guide](../features/sending-messages.md#-server-queue-limits) - Queue limits overview
- [Private Server Documentation](../features/private-server.md#-message-queue-limits) - Detailed configuration
- [API Error Handling](../faq/errors.md) - Troubleshooting guide

We're committed to providing reliable SMS delivery infrastructure. The queue limits feature gives you more control over message processing and helps maintain service quality across all your devices.
