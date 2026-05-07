# 📱 Multi-SIM Support

This guide covers the multi-SIM capabilities for devices with multiple SIM cards, enabling precise control over which SIM is used for sending and receiving SMS messages.

* **Sending API**: Select the specific SIM card for sending SMS messages in your API requests.
* **Webhooks**: Receive SIM card information for incoming messages.
* **Rotation**: Utilize a feature to rotate between multiple SIM cards.
* **Device Information**: View detailed SIM card information (carrier, phone number, ICCID) via the device API.

## 📱 Device SIM Information
As part of device information from the `GET /devices` endpoint, the app provides the following SIM card information:

| Field         | Type    | Description                                          |
| ------------- | ------- | ---------------------------------------------------- |
| `slotIndex`   | integer | The SIM card slot number (0-based)                   |
| `simNumber`   | integer | The SIM card number (1-based)                        |
| `carrierName` | string  | The mobile carrier name (may be null)                |
| `phoneNumber` | string  | The phone number (may be null)                       |
| `iccid`       | string  | The Integrated Circuit Card Identifier (may be null) |

!!! note "Fields Availability"
    The `phoneNumber`, `carrierName`, and `iccid` fields may be `null` if the device does not have the `READ_PHONE_STATE` permission granted or the carrier does not provide the information. The app gracefully handles this by reporting `null`.

!!! note "Privacy Considerations"
    The `phoneNumber`, `carrierName`, and `iccid` fields are redacted, keeping only the last four characters, if Cloud/Private server is used.

## 🚀 Sending API

To send an SMS using a specific SIM card, provide the SIM number in the `simNumber` field of your request. For example, the following request sends an SMS using SIM 2:

```bash title="Send SMS using specific SIM card"
curl -X POST \
    -u <username>:<password> \
    -H 'Content-Type: application/json' \
    https://api.sms-gate.app/3rdparty/v1/message \
    -d '{
        "textMessage": { "text": "Hello from SIM2, Dr. Turk!"},
        "phoneNumbers": ["+19162255887"],
        "simNumber": 2
    }'
```

## 📩 Webhooks

When using the [Webhooks](./webhooks.md) feature, all events include a `simNumber` field to identify which SIM card was used.

## 🔄 SIM Card Rotation

<center>
    <img src="/assets/features-sim-rotation.png" alt="SIM rotation option" width="480">
</center>

When the `simNumber` is not specified in the request, you can configure which SIM card will be used to send the message on the device. This option is located in the **Settings** tab under the **Messages** section.

Available options:

- **OS Default**: The app will not select any SIM card, delegating this to the default messaging app.
- **Round Robin**: The app will rotate between SIM cards in a round-robin fashion.
- **Random**: The app will select a SIM card at random for each message.

When a non-default option is used, you can receive the selected SIM number through the webhooks' `simNumber` field.

## 🔧 Troubleshooting

If you encounter issues with multi-SIM functionality:

1. Ensure that your device supports multiple SIM cards and that they are properly installed.
2. Verify that the app has the necessary permissions to access and use all SIM cards.
3. Check the app's logs for any error messages related to SIM card access or usage.
4. Make sure your device's SIM cards are active and have sufficient credit or data allowance.
5. Restart the app and/or device if persistent issues occur.

For further assistance, please contact our [support team](mailto:support@sms-gate.app).

## 📚 See Also

- [Device API](../integration/api.md)
- [Webhooks](./webhooks.md)
- [Sending Messages](./sending-messages.md)
