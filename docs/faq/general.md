# FAQ

## Does the app support Android 15?

Yes, the app supports Android 15. However, you may need to manually grant SMS permissions. Please follow the steps outlined in the ["Does not have `android.permission.SEND_SMS`" Error](./errors.md#does-not-have-androidpermissionsend_sms) FAQ entry.

After following these steps, the app should work correctly on Android 15. If you continue to experience issues, please contact our [support team](mailto:support@sms-gate.app) for further assistance.

*Acknowledgments: We'd like to thank our community members, especially @mabushey, for their contributions in identifying and resolving this issue. For more information, see [GitHub Issue #184](https://github.com/capcom6/android-sms-gateway/issues/184).*

## How can I send an SMS using the second SIM card?

Please refer to the [Multi-SIM Support](../features/multi-sim.md#webhooks) feature documentation.

## Does the app require power saving mode to be turned off to function without interruptions?

### Local Mode
- **Power saving settings:**  
  The app provides an option to disable battery optimizations directly from the *Settings* tab under the "System" section. This helps ensure uninterrupted operation.  
  The app also uses a foreground service with a wake lock, which allows it to function reliably even with power-saving mode enabled.  
- **Battery impact:**  
  Using a wake lock and disabling battery optimizations may lead to increased battery consumption.

### Cloud Mode
- **Power saving settings:**  
  Similar to Local Mode, disabling battery optimizations can enhance reliability. However, the app primarily relies on Firebase Cloud Messaging (FCM) push notifications, which functions without requiring power-saving mode to be turned off.  
- **Potential delays:**  
  High message rates could cause occasional delays when the device is in power-saving mode due to FCM's limitations on high-priority notifications.

### Recommendations
- **Testing:**  
  Test the app with and without battery optimizations disabled to evaluate its performance on your device and Android version.  
- **Device manufacturers:**  
  Behavior may vary depending on the device manufacturer and specific Android customizations.  
- **Local + Cloud:**  
  For maximum responsiveness, consider using a local server alongside the cloud connection.  

See also issue [#17](https://github.com/capcom6/android-sms-gateway/issues/17).  

## How do I enable or disable delivery reports for messages?

As of version 1.3.0, you have the option to enable or disable delivery reports for each message. By default, the delivery report feature is turned on. If you prefer not to receive delivery reports, you can disable them by setting the `withDeliveryReport` field to `false` in the JSON body of your message request. Here is an example of how to send a message without requesting a delivery report:

```json
{
  "message": "Your message text here",
  "phoneNumbers": ["79990001234", "79995556677"],
  "withDeliveryReport": false
}
```

## Can I use long or non-standard phone numbers?

Yes, starting from 1.6.1 of the app, our system allows the use of long or non-standard phone numbers, which may be common with M2M (machine-to-machine) SIM cards or other special cases. To bypass the standard phone number validation, simply add the query parameter `skipPhoneValidation=true` to your API request. Please note that with validation disabled, you are responsible for ensuring the correctness of the phone numbers. They should still follow the E.164 format, beginning with a '+' and containing only digits.

## How can I avoid mobile operator restrictions?

The application provides several features to help you avoid mobile operator restrictions:

### Random delay between messages

You can introduce a random delay between messages by specifying a minimum and maximum delay time. The application will then randomly select a delay within this range for each message sent. This helps to reduce the likelihood of messages being flagged as spam by simulating a more human-like sending pattern. This option is available in the "Messages" section of the app's settings and is named "Delay between messages".

It's important to note that this delay is applied only to individual messages, not for recipients in a single message. When you send a message to multiple recipients, the delay is not applied between each recipient of that message.

### Limiting the number of messages sent per period

The app offers a feature to restrict the number of messages sent within a specified period—be it a minute, hour, or day. You can find this option under the "Limits" section in the "Messages" section of the app's settings. When the limit is reached, the app will pause sending messages until the limit period resets. It's important to note that this feature should not be used for time-sensitive messages, such as sending authorization codes, where delays could cause issues.

### SIM rotation

For devices with multiple SIM cards, the application supports SIM rotation to distribute the load across different mobile operators. This feature helps avoid reaching sending limits on a single SIM card and reduces the risk of being flagged for high-volume sending. Please refer to [Multi-SIM Support](../features/multi-sim.md#sim-card-rotation) for more information.

By combining these features—random delays, message limits, and SIM rotation—you can significantly reduce the risk of triggering mobile operator restrictions while maintaining efficient message delivery.

## How to hide messages on device?

It's not possible to completely hide messages on the device without major changes in the app due to Android's limitations. Messages sent will appear in the default messaging app. The best way to keep messages private is to restrict physical access to the phone.

## How can I check the online status of the device?

### Local mode

Attempting to connect to the device's API directly can give you an immediate sense of its online status. Accessing the `/health` endpoint is a straightforward way to do this.

### Cloud mode

The app operates asynchronously, relying on PUSH notifications rather than maintaining a continuous connection to the server. You can use the `GET /device` endpoint to obtain some information about the device's state. The response includes a `lastSeen` field, showing the last time the device connected to the server. Due to the app's idle mode behavior, the device may only connect to the server once every 15 minutes, meaning the `lastSeen` time may not always represent the current status.

### Any mode

Irrespective of the mode, you can register a `system:ping` webhook to monitor the device's online status. This webhook will notify your server about the status of the app at user-defined intervals, set within the app's Settings on the device. This feature offers a proactive approach to track connectivity and ensure the device is functioning as expected across any operational mode.

**Note**: Using the ping feature will increase battery usage. It's important to balance the need for frequent status updates with the impact on device battery life, especially if the device is expected to operate for extended periods without charging.

## Can I send SMS messages with a custom sender name instead of my phone number?

The app uses your SIM card to send messages, so by default, it uses the same sender information as your phone's default messaging app (usually your phone number). Any changes to the sender name would need to be set up through your carrier, not within the app itself.

To attach a sender name, you would need to contact your mobile carrier to inquire about their "Sender ID" or "Alphanumeric Sender ID" services. These services allow you to replace your phone number with a custom name or brand when sending SMS messages.

Keep in mind that the availability and regulations surrounding this feature vary by country and carrier. Some carriers may offer this service for business accounts only, while others might not provide it at all due to local laws or technical limitations.

## How do I change my password?

The password change process depends on your server mode:

* **Local Server**: You can change the port, username, and password in the [Local Server configuration](../getting-started/local-server.md#server-configuration)
* **Cloud Server**: Follow the [Cloud Server password management](../getting-started/public-cloud-server.md#password-management) guide
* **Private Server**: The process is identical to the [Cloud Server mode](../getting-started/public-cloud-server.md#password-management)

## Does the app support RCS messaging?

Currently, our app does not support RCS (Rich Communication Services) messaging. This is because:

1. Google has not released an open API for RCS to third-party developers.
2. Different implementations exist (Google, Samsung, Apple), making it challenging to create a universal solution.
3. There's no standardized way for third-party apps to send or receive RCS messages.

We're monitoring the situation and will consider implementing RCS support if Google provides an official API in the future. For more information on this topic, you can refer to this [Google Support thread](https://support.google.com/messages/thread/247624435/when-will-rcs-api-be-released-to-third-party-developers).
