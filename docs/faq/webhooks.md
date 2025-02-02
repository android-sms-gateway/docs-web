# FAQ - Webhooks

## The `sms:received` webhook is not triggering

If you're experiencing issues with the `sms:received` webhook not triggering, consider the following potential reasons and solutions:

1. **Messages are received as RCS instead of SMS:**
    RCS (Rich Communication Services) messages may not trigger the SMS webhook. To resolve this:
    1. Install Google's Messages app
    2. Set it as the default SMS app
    3. Go to Messages settings > RCS chats and turn it off

2. **Third-party messaging app is blocking SMS events:**
    Some third-party messaging apps may interfere with SMS event broadcasting. To fix this:
    - Use the device's default messaging app, or
    - Set Google's Messages app as the default SMS application

3. **App permissions:**
    - Verify that the app has the necessary permissions to read and process SMS messages

## Can I use webhooks with an HTTP server without encryption?

No, webhooks cannot be used with an HTTP server without encryption due to Android OS restrictions and app policy. However, you can issue certificates for private IP addresses using the [project's CA](../services/ca.md#private-webhook-certificate).

## How to use webhooks with self-signed certificate?

Support for user-provided self-signed certificates will be removed in version 2.x of the app. It is strongly recommended to use the [project's CA](../services/ca.md#private-webhook-certificate) for generating certificates instead.

## How to use webhooks without internet access?

By default, webhooks require internet access and will wait until it's available to improve deliverability. However, if you're using the app in an isolated environment without internet access, you can disable this requirement. Here's how:

1. Open the app and navigate to the "Settings" tab.
2. Find the "Webhooks" section.
3. Locate the "Require Internet connection" option.
4. Switch off this option to allow webhooks to function without internet access.

Please note that disabling this feature may impact the reliability of webhook delivery if one or more webhook receivers are located outside the device's network.
