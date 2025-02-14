# Multi-Device Support

The app supports multiple devices connected to the same account with Cloud or Private server mode. This feature allows the distribution of messages sent via the server across all connected devices.

## Adding a Device to the Account

To add a new device to your account, follow these steps:

1. Open the app on the new device.
2. Activate the "Cloud server" switch.
3. Tap the "Offline" button; the First Start dialog will appear.
4. Change the tab to "Sign In".
5. Enter the username and password from your existing account.
6. Tap "Continue".
7. Wait for your username to appear in the "Cloud Server" section of the Home tab.

## Messages API

When an account has multiple devices, the device to send the message will be selected randomly.

## Device Management API

The server API allows to list devices connected to the account and delete any of them.

To list all devices on the account, use the [`GET /devices`](https://api.sms-gate.app/#/User/get_3rdparty_v1_devices) endpoint.

To remove a device from the account, use the [`DELETE /devices/{deviceId}`](https://api.sms-gate.app/#/User/delete_3rdparty_v1_devices__id_) endpoint. Please note that all messages, including pending ones, will be deleted when removing a device.
