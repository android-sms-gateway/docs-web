# Getting Started

## Webhooks

Webhooks can be utilized to get notifications of incoming SMS messages.

Follow these steps to set up webhooks:

1. Set up your own HTTP server with a valid SSL certificate to receive webhooks. For testing purposes, [webhook.site](https://webhook.site) can be useful.
2. Register your webhook with an API request:

    ```sh
    curl -X POST -u <username>:<password> \
      -H "Content-Type: application/json" \
      -d '{ "id": "unique-id", "url": "https://webhook.site/<your-uuid>", "event": "sms:received" }' \
      http://<device_local_ip>:8080/webhooks
    ```

3. Send an SMS to the device.
4. The application will dispatch POST request to the specified URL with a payload such as:

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
      "webhookId": "LreFUt-Z3sSq0JufY9uWB"
    }
    ```

5. To deregister a webhook, execute a `curl` request using the following pattern:

    ```sh
    curl -X DELETE -u <username>:<password> \
      http://<device_local_ip>:8080/webhooks/unique-id
    ```

*Note*: Webhooks are transmitted directly from the device; therefore, the device must have an outgoing internet connection. As the requests originate from the device, incoming messages remain inaccessible to us.

For more information, see [Features: Webhooks](../features/webhooks.md)
