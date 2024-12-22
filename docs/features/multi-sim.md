# Multi-SIM Support

The app offers the following features to support devices with multiple SIM cards:

* **Sending API**: Select the specific SIM card for sending SMS messages in your API requests.
* **Webhooks**: Receive SIM card information for incoming messages.
* **Rotation**: Utilize a feature to rotate between multiple SIM cards.

## Sending API

To send an SMS using a specific SIM card, provide the SIM card slot number in the `simNumber` field of your request. For example, the following request will send an SMS using the second SIM card:

```sh
curl -X POST \
    -u <username>:<password> \
    -H 'Content-Type: application/json' \
    https://api.sms-gate.app/3rdparty/v1/message \
    -d '{
        "message": "Hello from SIM2, Dr. Turk!",
        "phoneNumbers": ["+19162255887"],
        "simNumber": 2
    }'
```

## Webhooks

When using the [Webhooks](./webhooks.md) feature all events include a `simNumber` field to identify which SIM card was used.

## SIM Card Rotation

<div align="center">
    <img src="/assets/features-sim-rotation.png" alt="SIM rotation option">
</div>

When the `simNumber` is not specified in the request, you can configure which SIM card will be used to send the message on the device. This option is located in the "Settings" tab under the "Messages" section.

Available options:

* **OS Default**: The app will not select any SIM card, delegating this to the default messaging app.
* **Round Robin**: The app will rotate between SIM cards in a round-robin fashion.
* **Random**: The app will select a SIM card at random for each message.

When a non-default option is used, you can receive the selected SIM number through the webhooks' `simNumber` field.

## Troubleshooting

If you encounter issues with multi-SIM functionality:

1. Ensure that your device supports multiple SIM cards and that they are properly installed.
2. Verify that the app has the necessary permissions to access and use all SIM cards.
3. Check the app's logs for any error messages related to SIM card access or usage.
4. Make sure your device's SIM cards are active and have sufficient credit or data allowance.
5. Restart the app and/or device if persistent issues occur.

For further assistance, please contact our [support team](mailto:support@sms-gate.app).
