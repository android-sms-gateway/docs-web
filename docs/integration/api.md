# Integration - API 📱

The SMS Gateway for Android™ provides a robust API that allows you to send SMS messages programmatically from your own applications or services. This enables seamless integration with your existing infrastructure.

## API Specification 📄

You can find the OpenAPI specification for our API at the following link: [OpenAPI Specification](https://capcom6.github.io/android-sms-gateway/). This specification includes detailed information about the available endpoints, request/response structure, and more.

!!! note "Local vs Cloud API Access"
    While both API endpoints use the same authentication method and request format, there are critical differences in accessibility:
    
    - **Local Server API**: Only accessible within your local network (same Wi-Fi/Ethernet)
    - **Cloud API**: Accessible from anywhere on the internet
    
    External services like Google Apps Script, AWS Lambda, or other cloud functions **cannot** directly access Local Server API endpoints due to network constraints.
