---
title: "Webhook Payload Enhancement: Clearer Semantics with sender and recipient"
description: "Learn about the new sender and recipient fields in webhook payloads that provide clear separation between phone numbers and improve multi-SIM support"
date: 2026-02-17
author: "SMSGate Team LLM / StepFun: Step 3.5 Flash"
categories: ["Features", "Webhooks", "API"]
---

# 🌟 Webhook Payload Enhancement: Clearer Semantics with `sender` and `recipient`

## 📣 Big News: Enhanced Webhook Payloads Are Here!

We're excited to announce a significant improvement to our webhook payload structure. Based on user feedback and real-world usage, we've added new fields to make webhook data more explicit, especially for multi-SIM devices and complex messaging scenarios.

**TL;DR**: Your webhooks now include `sender` and `recipient` fields for crystal-clear phone number semantics, while maintaining full backward compatibility with the existing `phoneNumber` field.

---

## 🎯 The Problem: Ambiguity in Multi-SIM World

### Before the Enhancement

```json
{
  "payload": {
    "messageId": "abc123",
    "phoneNumber": "+1234567890",
    "simNumber": 1,
    "message": "Hello World"
  }
}
```

**The Confusion**: What does `phoneNumber` represent?

- For **incoming** SMS: Is it the sender or the receiver?
- For **outgoing** SMS: Is it the recipient or the sender?
- With **multiple SIMs**: Which device number is being referenced?

This ambiguity forced developers to:
- Reverse-engineer semantics based on event type
- Maintain separate logic for inbound vs outbound
- Guess which phone number they're actually working with

### Real-World Impact

Consider a dual-SIM device with numbers `+1112223333` (SIM 1) and `+4445556666` (SIM 2):

**Scenario 1: Incoming SMS to SIM 1**
```json
{
  "phoneNumber": "+9998887777",  // Who sent it? Which SIM received it?
  "simNumber": 1
}
```

**Scenario 2: Outgoing SMS from SIM 2**
```json
{
  "phoneNumber": "+9998887777",  // Who sent it? Who received it?
  "simNumber": 2
}
```

In both cases, `phoneNumber` means something different! 😕

---

## ✨ The Solution: Explicit Field Names

### After the Enhancement

```json
{
  "payload": {
    "messageId": "abc123",
    "sender": "+9998887777",
    "recipient": "+1112223333",
    "phoneNumber": "+9998887777",
    "simNumber": 1,
    "message": "Hello World"
  }
}
```

**Now it's crystal clear**:
- `sender`: The phone number that **sent** the message
- `recipient`: The phone number that **received** the message (or null if unavailable)
- `phoneNumber`: Deprecated but kept for backward compatibility

### Semantic Consistency Across All Events

| Event Type                    | sender          | recipient       |
| ----------------------------- | --------------- | --------------- |
| `sms:received` (inbound)      | External sender | Device's number |
| `sms:data-received` (inbound) | External sender | Device's number |
| `mms:received` (inbound)      | External sender | Device's number |
| `sms:sent` (outbound)         | Device's number | Recipient       |
| `sms:delivered` (outbound)    | Device's number | Recipient       |
| `sms:failed` (outbound)       | Device's number | Recipient       |

**Key Insight**: `sender` always originates, `recipient` always receives. No more guessing! 🎯

---

## 🔄 Backward Compatibility: Zero Breaking Changes

We understand that changing payload structures can be disruptive. That's why we've designed this enhancement to be **100% backward compatible**.

### What Stays the Same
- ✅ Existing `phoneNumber` field remains in all payloads
- ✅ Same data values (no semantic changes to `phoneNumber`)
- ✅ All existing webhook consumers continue to work without modification
- ✅ No changes to webhook registration or delivery mechanisms

### What's New
- ⭐ `sender` field: Originating phone number (who sent the message)
- 📍 `recipient` field: Receiving phone number — device's number for inbound, recipient's for outbound
- ⚠️ `phoneNumber` field: Now marked as deprecated

### Migration Path (Optional)

**Phase 1 - Today (Backward Compatible)**:
```json
{
  "sender": "+1234567890",
  "recipient": "+9876543210",
  "phoneNumber": "+1234567890"  // Still works!
}
```

**Phase 2 - Future (After Deprecation Period)**:
```json
{
  "sender": "+1234567890",
  "recipient": "+9876543210"
  // phoneNumber removed in future major version
}
```

**Recommendation**: Start using `sender` and `recipient` in your code now. They're clearer and will be supported indefinitely. The `phoneNumber` field will remain available for at least 12 months before removal.

---

## 📊 Multi-SIM Support: Finally Clear!

The new `recipient` field is especially valuable for multi-SIM devices.

### Example: Dual-SIM Device

**Device Configuration**:
- SIM 1: `+1112223333`
- SIM 2: `+4445556666`

**Incoming SMS to SIM 1**:
```json
{
  "event": "sms:received",
  "payload": {
    "sender": "+9998887777",
    "recipient": "+1112223333",  // ← Now explicit!
    "simNumber": 1
  }
}
```

**Incoming SMS to SIM 2**:
```json
{
  "event": "sms:received",
  "payload": {
    "sender": "+7776665555",
    "recipient": "+4445556666",  // ← Clear which SIM!
    "simNumber": 2
  }
}
```

Now you can:
- Route messages to correct handlers based on recipient number
- Track which SIM received each message without inference
- Build accurate multi-SIM analytics and dashboards

---

## 🔧 Technical Details

### Null Handling for recipient

The `recipient` field is **nullable** because:

- `READ_PHONE_STATE` permission may not be granted
- Some carriers don't expose phone numbers programmatically

When `recipient` is null, webhooks still fire normally with the field set to `null`. This ensures no loss of functionality.

!!! warning "Always Handle `null` Values"
    Your webhook handler should always check if `recipient` is `null` before using it. Example in JavaScript:
    
    ```javascript
    const { sender, recipient } = req.body.payload;
    console.log(`From: ${sender}, To: ${recipient || 'unknown'}`);
    ```

---

## 🚀 Getting Started

### For New Integrations

Use the new fields immediately—they're clearer and future-proof:

```javascript
app.post('/webhook', (req, res) => {
  const { sender, recipient, message } = req.body.payload;

  console.log(`Message from ${sender} to ${recipient || 'unknown'}`);

  // Your business logic here

  res.sendStatus(200);
});
```

### For Existing Integrations

**No action required!** Your existing code will continue to work:

```javascript
// Old code still works
app.post('/webhook', (req, res) => {
  const { phoneNumber, message } = req.body.payload;

  console.log(`Message from ${phoneNumber}`);

  res.sendStatus(200);
});
```

**But consider upgrading** for better clarity:
```javascript
// Enhanced code with new fields
app.post('/webhook', (req, res) => {
  const { sender, recipient, message } = req.body.payload;

  // Use sender (explicit) instead of phoneNumber (ambiguous)
  console.log(`Message from ${sender} to ${recipient || 'unknown'}`);

  res.sendStatus(200);
});
```

---

## 📚 Updated Documentation

All documentation has been updated to reflect the new payload structure:

- **[Webhooks Feature Guide](../../features/webhooks.md)**: Complete reference for all event types
- **[Getting Started with Webhooks](../../getting-started/webhooks.md)**: Quick start guide with examples
- **[MMS Support](../../features/mms.md)**: MMS-specific webhook payload details
- **[FAQ](../../faq/webhooks.md)**: Common questions including multipart message handling
- **[Status Tracking](../../features/status-tracking.md)**: Delivery status webhook examples

---

## 🧪 Testing the Enhancement

### Quick Test

1. Register a webhook for `sms:received` event
2. Send an SMS to your device
3. Inspect the webhook payload—you should see `sender` and `recipient` fields

### Expected Payload Structure

```json
{
  "deviceId": "device-id",
  "event": "sms:received",
  "id": "webhook-event-id",
  "payload": {
    "messageId": "abc123",
    "sender": "+9998887777",
    "recipient": "+1112223333",
    "phoneNumber": "+9998887777",
    "simNumber": 1,
    "receivedAt": "2026-02-17T12:00:00.000+07:00"
  },
  "webhookId": "webhook-id"
}
```

---

## ❓ Frequently Asked Questions

### Q: Will this break my existing webhook integration?

**A:** No! The `phoneNumber` field remains with the same value as before. Your existing code will work without any changes.

### Q: Should I update my code to use the new fields?

**A:** We recommend it! The `sender` and `recipient` fields are much clearer, especially for multi-SIM scenarios. The migration depends on event type:
- For **inbound** events (`sms:received`, `sms:data-received`, `mms:received`): replace `phoneNumber` with `sender`.
- For **outbound** events (`sms:sent`, `sms:delivered`, `sms:failed`): replace `phoneNumber` with `recipient`.

### Q: When will `phoneNumber` be removed?

**A:** We'll keep `phoneNumber` for at least 12 months to give everyone time to migrate. We'll announce a deprecation timeline well in advance.

### Q: What if `recipient` is null?

**A:** This can happen if the app lacks `READ_PHONE_STATE` permission or the carrier doesn't provide the device number. Your code should handle null gracefully. The webhook will still fire with all other fields populated.

### Q: Does this change affect the API for sending messages?

**A:** No. This enhancement only affects webhook payloads. The message sending API remains unchanged.

### Q: How do I know which field to use in my code?

**A:**
- Use `sender` for the originating phone number (who sent the message)
- Use `recipient` for the receiving phone number (which device received it or who was the recipient)
- Avoid `phoneNumber` in new code (it's deprecated)

---

## 🎉 Benefits at a Glance

| ✅   | Benefit                         | Impact                                          |
| --- | ------------------------------- | ----------------------------------------------- |
| 1   | **Clear Semantics**             | No more guessing what `phoneNumber` means       |
| 2   | **Multi-SIM Clarity**           | Explicit recipient per SIM slot                 |
| 3   | **Zero Breaking Changes**       | Existing integrations keep working              |
| 4   | **Future-Proof**                | New fields will be supported indefinitely       |
| 5   | **Better Developer Experience** | Self-documenting code with explicit field names |
| 6   | **Consistent Logic**            | Same semantics across all event types           |

---

## 🔗 Related Resources

- **Webhook Documentation**: [Full Webhook Guide](../../features/webhooks.md)
- **API Reference**: [REST API Documentation](../../integration/api.md)

---

## 💬 Feedback & Support

We'd love to hear your thoughts on this enhancement!

- **GitHub Discussions**: [Share your use case and feedback](https://github.com/capcom6/android-sms-gateway/discussions)
- **Support Email**: [support@sms-gate.app](mailto:support@sms-gate.app)
- **Documentation Issues**: [Report](https://github.com/android-sms-gateway/docs-web/issues) any inconsistencies or unclear examples

---

## 🙏 Thank You

This enhancement was driven by user feedback from the community. Your real-world experiences with multi-SIM devices and complex integrations helped shape this solution.

We're committed to making SMSGate the most developer-friendly SMS gateway platform. Stay tuned for more improvements!

**Happy coding!** 🚀
