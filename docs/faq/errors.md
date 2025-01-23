# FAQ - Errors

## `RESULT_ERROR_GENERIC_FAILURE` Error

The `RESULT_ERROR_GENERIC_FAILURE` error can occur for various reasons. One of the most common causes is insufficient balance on the SIM card. Check your carrier's balance and add funds if needed.

## `RESULT_ERROR_LIMIT_EXCEEDED` Error

The `RESULT_ERROR_LIMIT_EXCEEDED` error occurs when you have reached the sending limit imposed by your mobile carrier or the Android operating system. This safeguard is designed to prevent spamming and typically triggers if you attempt to send an excessive number of messages in a short span of time. To resolve this, you can adjust the SMS sending limit on some devices by following the instructions in this guide: [How to change the SMS sending limit on Android](https://www.xda-developers.com/change-sms-limit-android/). Additionally, consider spacing out your message sending or contact your carrier to inquire about their message sending limits. For more strategies on managing sending limits, please refer to [How can I avoid mobile operator restrictions?](./general.md#how-can-i-avoid-mobile-operator-restrictions).

## `RESULT_RIL_MODEM_ERR` Error

The `RESULT_RIL_MODEM_ERR` error usually indicates a problem with the device's modem or the communication between the application and the modem. This error can stem from a variety of causes, such as issues with the SIM card, network connectivity problems, or firmware-related errors.

To troubleshoot this error, first try sending a message using the device's default messaging app and check the signal strength. Also, ensure that the SIM card is not blocked by your carrier.

## `RESULT_NO_DEFAULT_SMS_APP` Error

The `RESULT_NO_DEFAULT_SMS_APP` error occurs when no default SMS app is set on the device or when the default SIM for sending SMS messages hasn't been configured. This error prevents the app from sending SMS messages.

To resolve this issue, there are two options:

1. Set the default SMS app and SIM number in your device's settings
2. Provide the SIM number explicitly in the `simNumber` field of the request

## `Can't send message: No SIMs found` Error

This error occurs when the app cannot detect any SIM cards on the device. There are several possible causes for this issue:

1. **SIM card issues:**
    - The SIM card is not properly inserted.
    - The SIM card has poor contact with the slot.
    - The SIM card is damaged or faulty.

2. **Permission problems:**
    - The app doesn't have the necessary permissions to access the SIM cards list.
    - For Xiaomi users: You may need to disable MIUI optimization to prevent the app from requesting permissions repeatedly.

To resolve this error:

1. Check that your SIM card is properly inserted and undamaged.
2. Ensure the app has all required permissions in your device settings.
3. For Xiaomi users: Disable MIUI optimization in Developer Options.
4. Restart your device to refresh system processes.
5. If the problem persists, try using the SIM card in another device to rule out hardware issues.
