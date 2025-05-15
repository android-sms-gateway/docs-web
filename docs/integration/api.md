# API

The SMS Gateway for Android™ provides an API that allows you to send SMS messages programmatically from your own applications or services. 

You can find the OpenAPI specification for our API at the following link: [OpenAPI Specification](https://capcom6.github.io/android-sms-gateway/). This specification includes detailed information about the available endpoints, request/response structure, and more.

## Clients

We offer client libraries in various programming languages to assist with integration:

- **[Go](https://github.com/android-sms-gateway/client-go)**: install the package via go get: `go get github.com/android-sms-gateway/client-go`;
- **[JavaScript / TypeScript](https://github.com/android-sms-gateway/client-ts)**: install the package via npm: `npm install android-sms-gateway` or bun: `bun add android-sms-gateway`;
- **[PHP](https://github.com/android-sms-gateway/client-php)**: install the package via composer: `composer require capcom6/android-sms-gateway`;
- **[Python](https://github.com/android-sms-gateway/client-py)**: install the package via pip: `pip install android-sms-gateway`.

## CRM Integration

Many CRM systems require GET requests with URL parameters. Since SMSGate requires POST requests with JSON payloads, you'll need middleware to convert between these formats.

### Example Flask Middleware

```python
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)
target_url = "http://your-smsgate-ip:port/message"
auth = ("username", "password")

@app.route('/send-sms')
def send_sms():
    response = requests.post(
        target_url,
        auth=auth,
        json={
            "phoneNumbers": [request.args.get('to')],
            "message": request.args.get('message')
        }
    )
    return jsonify(response.json()), response.status_code
```
