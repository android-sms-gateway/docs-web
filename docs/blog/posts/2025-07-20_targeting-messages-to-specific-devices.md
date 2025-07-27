---
title: Targeting Messages to Specific Devices
description: Learn how to precisely route SMS messages to specific devices in multi-device setups using device identifiers.
date: 2025-07-20
author: SMSGate Team
categories:
  - Features
  - Tutorials
---

# 🎯 Targeting Messages to Specific Devices

In multi-device setups, the ability to target specific devices is crucial for advanced SMS operations. This guide explains how to precisely route messages using device identifiers.

> **Historical Context**  
> 
> Before device targeting was introduced, users had to register multiple accounts (each with a single device) to achieve similar targeting precision. The current device targeting feature eliminates this complexity by allowing multiple devices under one account.

<!-- more -->

## 🆔 Obtaining Device IDs

First, retrieve your device IDs using the device listing API:

```bash title="List all devices"
curl -X GET \
  https://api.sms-gate.app/3rdparty/v1/devices \
  -u "${SMSGATE_USER}:${SMSGATE_PASS}"
```

Sample response:

```json
[
  {
    "id": "yVULogr4Y1ksRfnos1Dsw",
    "name": "Samsung Galaxy S23",
    "lastSeen": "2025-07-20T08:30:45Z"
  },
  {
    "id": "GhYSOK_rNnjPUzDyV2E-u",
    "name": "Google Pixel 7",
    "lastSeen": "2025-07-20T07:15:22Z"
  }
]
```

> Use the **id** value from the listing response as the **deviceId** field in subsequent requests.

## ✉️ Targeted Message Sending

Include the `deviceId` parameter in your send request:

```bash hl_lines="6" title="Target specific device"
curl -X POST https://api.sms-gate.app/3rdparty/v1/messages \
  -u "${SMSGATE_USER}:${SMSGATE_PASS}" \
  --json '{
    "textMessage": {"text": "Server alert: CPU overload"},
    "phoneNumbers": ["+19165551234"],
    "deviceId": "yVULogr4Y1ksRfnos1Dsw"
}'
```

## 🚨 Critical Considerations

!!! warning "Device Removal Impact"
    Deleting a device (`DELETE /devices/{id}`) will remove all its pending messages. Always confirm device status before removal.

!!! tip "Webhook Targeting"
    Combine device-specific messaging with targeted webhooks:
    ```json
    {
      "url": "https://your-server.com/alerts",
      "event": "sms:sent",
      "deviceId": "yVULogr4Y1ksRfnos1Dsw"
    }
    ```

## ✅ Best Practices

1. **Verify device status** before sending critical messages
2. **Cache device IDs** to reduce API calls
3. **Monitor device health** using ping webhooks

Precise device targeting enables sophisticated SMS workflows while maintaining security and efficiency across your device fleet.

[Explore Device Management API](https://api.sms-gate.app/#/Devices)
