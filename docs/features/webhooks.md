# Webhooks

Webhooks offer a powerful mechanism to receive real-time notifications of events like incoming SMS messages. This integration guide will walk you through setting up webhooks to receive such notifications directly from your device.

## Supported Events

Currently, the following event is supported:

- `sms:received` - Triggered when an SMS is received by the device. The payload for this event includes:
    * `message`: The content of the SMS message.
    * `phoneNumber`: The phone number that sent the SMS.
    * `simNumber`: The SIM card number that received the SMS. May be `null` on some Android devices.
    * `receivedAt`: The timestamp when the message was received.
- `sms:sent` - Triggered when an SMS is sent by the device. The payload for this event includes:
    * `messageId`: The ID of the SMS message.
    * `phoneNumber`: The recipient's phone number.
    * `simNumber`: The SIM card number that sent the SMS. May be `null` if default SIM is used.
    * `sentAt`: The timestamp when the message was sent.
- `sms:delivered` - Triggered when an SMS is delivered to the recipient. The payload for this event includes:
    * `messageId`: The ID of the SMS message.
    * `phoneNumber`: The recipient's phone number.
    * `simNumber`: The SIM card number that sent the SMS. May be `null` if default SIM is used.
    * `deliveredAt`: The timestamp when the message was delivered.
- `sms:failed` - Triggered when an SMS fails to be sent to the recipient. The payload for this event includes:
    * `messageId`: The ID of the SMS message.
    * `phoneNumber`: The recipient's phone number.
    * `simNumber`: The SIM card number that sent the SMS. May be `null` if default SIM is used.
    * `failedAt`: The timestamp when the message failed.
    * `reason`: The reason for the failure.
- `system:ping` - Triggered when the device pings the server. Has no payload.

Please note that as the application evolves, additional events may be supported in the future.

## Prerequisites

Before you begin, ensure the following:

- You have [SMS Gateway for Android™](https://github.com/capcom6/android-sms-gateway/releases/latest) installed on your device in any mode: Local, Cloud or Private.
- You have a server with a valid SSL certificate to securely receive HTTPS requests, which should be accessible from the internet. Self-signed certificates can be used as described in the [FAQ](../faq/webhooks.md#how-to-use-webhooks-with-self-signed-certificate). Alternatively, you can use services like [ngrok](https://ngrok.com) to bypass the need for a valid SSL certificate.
- Your device has access to your server. If you operate entirely within your local network without Internet access, please see [FAQ](../faq/webhooks.md#how-to-use-webhooks-without-internet-access)

## Step-by-Step Integration

### Step 1: Set Up Your Server

For your webhooks to work, you need an HTTP server capable of handling HTTPS POST requests. This server will be the endpoint for the incoming webhook data.

- For Production: Ensure your server has a valid SSL certificate.
- For Testing: Use services like [webhook.site](https://webhook.site) to create a temporary URL that can capture webhook data.

### Step 2: Register Your Webhook Endpoint

To start receiving webhook notifications, you must register your webhook endpoint with the device. Utilize the `curl` command to send a POST request to the appropriate address, depending on whether you're in Local, Cloud, or Private mode.

```sh
curl -X POST -u <username>:<password> \
  -H "Content-Type: application/json" \
  -d '{ "id": "<unique-id>", "url": "https://webhook.site/<your-uuid>", "event": "sms:received" }' \
  https://api.sms-gate.app/3rdparty/v1/webhooks
```

Replace `<username>`, `<password>`, `<unique-id>`, and `<your-uuid>` with your actual credentials and information.

In Cloud or Private modes, please allow some time for the webhooks list to synchronize with your device.

### Step 3: Verify Your Webhook

You can verify that it has been successfully registered by executing the following `curl` command:

```sh
curl -X GET -u <username>:<password> \
  https://api.sms-gate.app/3rdparty/v1/webhooks
```

Please note that webhooks registered in Local mode are separate from those registered in Cloud/Private mode. Therefore, when you make this request to the device's local server, you will only see the webhooks registered in Local mode, and similarly, a request to the Cloud/Private server will only show the webhooks registered there.

### Step 4: Testing the Webhook

Send an SMS to the phone number associated with the device to test the webhook.

### Step 5: Receiving the Webhook Payload

Upon receiving an SMS, your device will make a POST request to the registered webhook URL with a payload structured as follows:

```json
{
  "deviceId": "ffffffffceb0b1db0000018e937c815b",
  "event": "sms:received",
  "id": "Ey6ECgOkVVFjz3CL48B8C",
  "payload": {
    "message": "Android is always a sweet treat!",
    "phoneNumber": "6505551212",
    "receivedAt": "2024-06-22T15:46:11.000+07:00"
  },
  "webhookId": "<unique-id>"
}
```

Your server should process this request and respond with an HTTP status code in the `2xx` range to indicate successful receipt in 30 seconds. If your server responds with any other status code, or if the device encounters network issues, the SMS Gateway app will attempt to resend the webhook.

The app implements an exponential backoff retry strategy: it waits 10 seconds before the first retry, then 20 seconds, 40 seconds, and so on, doubling the interval each time. By default, the app will retry 14 times (approximately 2 days) before giving up. You can specify a custom retry count in the "Webhooks" section of the "Settings" tab.

### Step 6: Deregistering a Webhook

If you no longer wish to receive webhook notifications, deregister your webhook with the following curl command:

```sh
curl -X DELETE -u <username>:<password> \
  'https://api.sms-gate.app/3rdparty/v1/webhooks/%3Cunique-id%3E'
```

## Security Considerations

- Use HTTPS for your webhook endpoint to ensure secure data transmission.
- Protect your webhook endpoint against unauthorized access. For example, you can specify authorization key as query-parameter when registering the webhook.
- Regularly rotate your authentication credentials.
  
## Troubleshooting

- Ensure the device can reach your server and that there are no firewalls blocking outgoing requests.
- Validate that the webhook URL is correct and the server is running.
- Check the server logs for any errors during the webhook POST request handling.
- Try to use default messaging app, not third-party app, because third-party app can block some SMS related events.

## Conclusion

By following these steps, you've successfully integrated webhooks into your system to receive real-time notifications for incoming SMS messages. This setup enables you to respond to messages promptly and automate workflows based on SMS content.

Remember to adhere to best practices for security and perform thorough testing to ensure reliable webhook delivery.

## References

- [FAQ](../faq/webhooks.md)
- [API Documentation](https://capcom6.github.io/android-sms-gateway/#/Webhooks)

## Examples

- [Telegram Forwarder Function](https://github.com/android-sms-gateway/example-telegram-forwarder-fn) - A Cloud Function to seamlessly forward SMS messages to a Telegram chat using webhooks.
