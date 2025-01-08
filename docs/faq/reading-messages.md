# FAQ - Reading Messages

The main article about reading messages is located [here](../features/reading-messages.md).

## Can I get incoming messages?

Yes, you can get incoming messages asynchronously via the `sms:received` webhook in two ways:

1. Any new incoming message will trigger the `sms:received` webhook by default.
2. For retrieving previously received messages, the `POST /messages/inbox/export` request can be used.

## Can I use a `GET` request to read messages?

No, synchronous reading of messages is not supported due to privacy policy. 

One of the goals of the app is to maintain the same API for any mode. To implement this kind of endpoint in Cloud mode, the application would need to upload all messages from the device to the server. However, storing all of the messages of all users on the server is not secure with the current app design. We're working on additional security measures that will allow this type of access to the messages with a sufficient privacy level, but there is no timeline for this feature.
