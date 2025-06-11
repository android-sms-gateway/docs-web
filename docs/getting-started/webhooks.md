# Getting Started 🚀

## Webhooks 🌐

Webhooks provide real-time notifications about SMS events. Follow these steps to set up webhooks for incoming SMS messages as an example:

### Prerequisites 🔧

1. **HTTPS Endpoint**:
    - Webhook URLs must use HTTPS except for `http://127.0.0.1` (localhost)
    - For private IP addresses (like `192.168.x.x`), use our [Certificate Authority](../services/ca.md) to generate trusted certificates
    - Testing services like [webhook.site](https://webhook.site) provide HTTPS endpoints

2. **Network Access**:
    - Device must have internet access to reach external endpoints
    - For local networks, ensure device and server are on same subnet

### Setup Steps 🛠️

1. Register your webhook:
   ```sh title="Register Webhook"
   curl -X POST -u <username>:<password> \
     -H "Content-Type: application/json" \
     -d '{
       "id": "unique-id",
       "url": "https://your-server.com/webhook",
       "event": "sms:received"
     }' \
     http://<device_ip>:8080/webhooks
   ```

2. Send an SMS to the device

3. Your server will receive a POST request with this payload:
   ```json title="Webhook Payload"
   {
     "deviceId": "ffffffffceb0b1db0000018e937c815b",
     "event": "sms:received",
     "id": "Ey6ECgOkVVFjz3CL48B8C",
     "payload": {
       "textMessage": { "text": "Android is always a sweet treat!"},
       "phoneNumber": "6505551212",
       "receivedAt": "2024-06-22T15:46:11.000+07:00"
     },
     "webhookId": "LreFUt-Z3sSq0JufY9uWB"
   }
   ```

4. To remove a webhook:
   ```sh title="Remove Webhook"
   curl -X DELETE -u <username>:<password> \
     http://<device_ip>:8080/webhooks/unique-id
   ```

### Local Network Tips 🌍

- Use `127.0.0.1` with ADB reverse port forwarding for local testing
- For private IPs:  
    1. [Generate Private Webhook certificate](../services/ca.md)
    2. Install on the server
    3. Use `https` in webhook URL

### Notes 📝

- Webhooks are sent directly from the device
- Device must have network access to your server
- Messages remain inaccessible to third parties

For advanced features, see [Webhooks Guide](../features/webhooks.md)
