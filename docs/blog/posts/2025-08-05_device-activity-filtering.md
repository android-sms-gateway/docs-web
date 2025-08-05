---
title: Optimizing Device Selection with deviceActiveWithin
description: Learn how to leverage the deviceActiveWithin parameter for precise device targeting and improved message delivery reliability.
date: 2025-08-05
author: SMSGate Team
categories:
  - Features
  - Best Practices
---

# ⏱️ Optimizing Device Selection with deviceActiveWithin

In multi-device deployments, ensuring messages reach active, responsive devices is critical for reliability. The `deviceActiveWithin` parameter provides granular control over device selection based on recent activity, enabling developers to optimize message delivery success rates while maintaining system efficiency.

<!-- more -->

## 1. Definition & Purpose 📌

The `deviceActiveWithin` parameter is a query parameter that filters eligible devices based on their recent activity when sending messages through the API.

### Key Characteristics

- **Type**: Integer (hours)
- **Location**: Query parameter in message sending requests
- **Default Value**: `0` (no activity filtering)
- **Function**: Only devices active within the specified time window are considered for message routing

### Core Purpose

This parameter addresses a critical challenge in multi-device environments: **ensuring message delivery through active, responsive devices**. By filtering out inactive devices, it:

- Reduces message failures due to offline devices
- Improves overall delivery success rates
- Enables more reliable time-sensitive communications
- Provides visibility into device engagement patterns

> **Historical Context**  
> 
> Before this parameter was introduced, developers had to implement custom device health checks or rely on random device selection, which often resulted in failed message attempts when targeting inactive devices.

## 2. Technical Implementation 💻

### API Integration

The parameter works as a query parameter in message sending requests:

```http title="Basic usage with activity filtering"
POST /3rdparty/v1/messages?deviceActiveWithin=12
Content-Type: application/json
Authorization: Basic <credentials>

{
  "textMessage": {
    "text": "Your OTP is 1234"
  },
  "phoneNumbers": ["+1234567890"]
}
```

### How It Works

1. **Device Activity Tracking**: Each device maintains a `lastSeen` timestamp that updates when the device connects to the server
2. **Filtering Logic**: When `deviceActiveWithin=N` is specified, only devices with `lastSeen` within the last N hours are considered
3. **Selection Process**:
    - If `deviceId` is specified: Validates the device meets activity criteria
    - If no `deviceId`: Filters the pool of available devices for random selection

### Implementation Details

- **Activity Window**: Measured in hours (integer values only)
- **Zero Value**: `deviceActiveWithin=0` disables activity filtering (default behavior)
- **Error Handling**: Returns `400 Bad Request` with `No active device with such ID found` error message when no devices meet criteria

```json title="Error response for inactive device"
{
  "message": "No active device with such ID found"
}
```

## 3. Performance Impact ⚡

### Positive Effects

- **Reduced Failures**: Decrease in `Pending` messages
- **Faster Delivery**: Messages reach recipients faster
- **Resource Optimization**: Prevents wasted attempts on offline devices

### Considerations

- **Smaller Device Pool**: More restrictive values reduce available devices for selection
- **Threshold Selection**: Finding the optimal value requires monitoring device activity patterns
- **Error Rate**: Overly restrictive values may increase `400 Bad Request` responses

## 4. Best Practices ✅

### Threshold Selection

| Use Case                | Recommended Value | Rationale                                                    |
| ----------------------- | ----------------- | ------------------------------------------------------------ |
| Critical alerts         | 1-2 hours         | Ensures immediate device availability                        |
| Business communications | 8-12 hours        | Balances availability with device coverage                   |
| Non-urgent messages     | 24-48 hours       | Maximizes device pool while filtering truly inactive devices |

### Implementation Strategy

1. **Start Conservative**: Begin with `deviceActiveWithin=24` and monitor error rates
2. **Gradual Optimization**: Adjust based on observed device activity patterns
3. **Combine with Device Listing**: Verify device status before sending critical messages

```bash title="Pre-check device status"
# Get device list with activity status
curl -X GET https://api.sms-gate.app/3rdparty/v1/devices \
  -u "${SMSGATE_USER}:${SMSGATE_PASS}"

# Sample response
[
  {
    "id": "yVULogr4Y1ksRfnos1Dsw",
    "name": "Primary Device",
    "lastSeen": "2025-08-05T06:30:45Z"
  }
]
```

### Error Handling

Implement robust error handling for cases where no devices meet activity criteria:

```javascript title="Error handling example"
async function sendMessage(message, phoneNumbers, activityWindow = 24) {
  try {
    const response = await fetch(
      `/3rdparty/v1/messages?deviceActiveWithin=${activityWindow}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ textMessage: { text: message }, phoneNumbers })
      }
    );
    
    if (response.status === 400) {
      const error = await response.json();
      if (error.message.includes('No active device')) {
        // Fallback to less restrictive window
        return sendMessage(message, phoneNumbers, activityWindow * 2);
      }
    }
    
    return response;
  } catch (error) {
    // Handle network errors
  }
}
```

## Conclusion: Maximizing Delivery Efficiency 🚀

The `deviceActiveWithin` parameter represents a powerful tool for optimizing SMS delivery reliability in multi-device environments. By intelligently filtering devices based on recent activity, you can significantly improve message success rates while gaining valuable insights into device engagement patterns.

When properly implemented, this feature can reduce delivery failures by preventing wasted attempts on inactive devices.

For advanced use cases, consider combining `deviceActiveWithin` with [explicit device targeting](./2025-07-20_targeting-messages-to-specific-devices.md) and [device health monitoring](../../features/health.md) to create sophisticated delivery strategies that adapt to real-time device conditions.

[Explore Device Management API](https://api.sms-gate.app/#/Devices) | [View Complete API Documentation](https://api.sms-gate.app)
