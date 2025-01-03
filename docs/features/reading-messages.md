# Reading Messages

The app not only allows receiving incoming messages in real-time via webhooks but also enables reading previously received messages using the same webhook.

## How it works

To read messages, please follow these steps:

1. Register the `sms:received` webhook as described in the [Webhooks](../features/webhooks.md) guide if you haven't done so already.
2. Determine the Device ID of the device you want to read messages from by calling the `GET /devices` endpoint:
    ```
    curl -u <username>:<password> https://api.sms-gate.app/3rdparty/v1/devices
    ```
3. Send a request with `deviceId` and period to the `POST /messages/inbox/export` endpoint:
    ```
    curl -u <username>:<password> \
      -H "Content-Type: application/json" \
      -d '{ "deviceId": "<device-id>", "since": "2024-01-01T00:00:00Z", "until": "2024-12-31T23:59:59Z" }' \
      https://api.sms-gate.app/3rdparty/v1/messages/inbox/export
    ```
4. After receiving the request, the device will send `sms:received` webhooks for each message in the inbox for the specified period.

## Notes

* The webhook will be sent for each message independently, so the order of messages is not guaranteed.
* It is recommended to split long periods into shorter ones to avoid excessive load on your webhook receiver.
* The export webhooks retry policy is the same as described in the [Webhooks](../features/webhooks.md) guide.
* The ID for incoming messages is generated based on the content of the message and is not guaranteed to be unique.
