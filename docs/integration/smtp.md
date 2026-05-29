# 📧 SMTP / Email to SMS

The SMSGate Email to SMS Bridge provides an SMTP interface for sending SMS messages. Any system that can send email can send SMS through this bridge, with no REST API integration required.

## 📖 Overview

The bridge acts as an SMTP server that translates incoming emails into SMS messages. The public server at `smtp.sms-gate.app` lets you get started immediately — connect using your SMSGate credentials and send emails to `{phone}@smtp.sms-gate.app`.

!!! tip "Public SMTP Server Available"
    A public SMTP server is available at **`smtp.sms-gate.app:587`** (plain) and **`smtp.sms-gate.app:465`** (TLS). No installation needed — connect directly with your SMSGate credentials. See the [Email to SMS Bridge service page](../services/email-to-sms.md) for self-hosting options.

<div class="grid cards" markdown>

- **📧 When to Use SMTP**
    Use SMTP when your system already sends email (monitoring tools, booking platforms, CRMs) and you want to add SMS delivery without API code changes.

- **🌐 When to Use REST API**
    Use the [REST API](./api.md) for direct control, advanced features (MMS, data SMS, scheduling), or when building new integrations from scratch.

</div>

## 🔌 Connection Details

| Parameter    | Value                       |
| ------------ | --------------------------- |
| Protocol     | SMTP (AUTH PLAIN)           |
| Host         | `smtp.sms-gate.app`         |
| Plain port   | 587                         |
| TLS port     | 465 (SMTPS, Let's Encrypt)  |
| Email format | `{phone}@smtp.sms-gate.app` |

## 📨 Email Format

Send an email where the recipient address encodes the phone number:

| Part        | Format                      | Description                                            |
| ----------- | --------------------------- | ------------------------------------------------------ |
| **To**      | `{phone}@smtp.sms-gate.app` | Phone number in international format as the local part |
| **Subject** | (ignored)                   | Not used in the SMS                                    |
| **Body**    | Plain text                  | The SMS message content                                |
| **Auth**    | AUTH PLAIN                  | SMSGate username / password                            |

## 🔑 Authentication

Authentication uses SMTP AUTH PLAIN with your SMSGate credentials:

| Step                      | Description                                                  |
| ------------------------- | ------------------------------------------------------------ |
| **1. SMTP AUTH**          | Client sends `AUTH PLAIN` with SMSGate username and password |
| **2. Credential storage** | Credentials held in the SMTP session                         |
| **3. API call**           | Credentials used to authenticate each SMSGate API request    |
| **4. Auth failure**       | On 401/403, bridge returns SMTP code 535 to the client       |

!!! important "TLS Recommended for Production"
    Use port **465** (SMTPS) to protect credentials in transit. The public server at `smtp.sms-gate.app:465` uses Let's Encrypt certificates automatically.

## 📤 Client Examples

=== "curl"

    ```bash title="Send SMS via curl (TLS)"
    curl --url 'smtps://smtp.sms-gate.app:465' \
      --ssl-reqd \
      --mail-from 'alerts@example.com' \
      --mail-rcpt '+1234567890@smtp.sms-gate.app' \
      --user 'username:password' \
      --upload-file - <<EOF
    Subject: Test
    Your verification code is 1234
    EOF
    ```

    For plain SMTP on port 587:

    ```bash title="Send SMS via curl (plain)"
    curl --url 'smtp://smtp.sms-gate.app:587' \
      --mail-from 'alerts@example.com' \
      --mail-rcpt '+1234567890@smtp.sms-gate.app' \
      --user 'username:password' \
      --upload-file - <<EOF
    Subject: Test
    Your appointment is confirmed for tomorrow at 10:00 AM.
    EOF
    ```

=== "Python"

    ```python title="Send SMS via Python"
    import smtplib

    msg = """\
    Subject: Notification

    Your package has been shipped!"""

    with smtplib.SMTP("smtp.sms-gate.app", 587) as server:
        server.starttls()
        server.login("username", "password")
        server.sendmail(
            "alerts@example.com",
            "+1234567890@smtp.sms-gate.app",
            msg,
        )
    ```

=== "Node.js"

    ```javascript title="Send SMS via Node.js"
    const nodemailer = require("nodemailer");

    const transporter = nodemailer.createTransport({
      host: "smtp.sms-gate.app",
      port: 587,
      secure: false,
      auth: { user: "username", pass: "password" },
    });

    await transporter.sendMail({
      from: '"Alerts" <alerts@example.com>',
      to: "+1234567890@smtp.sms-gate.app",
      subject: "", // ignored
      text: "Your verification code is 1234",
    });
    ```

    For TLS on port 465:

    ```javascript title="Send SMS via Node.js (TLS)"
    const transporter = nodemailer.createTransport({
      host: "smtp.sms-gate.app",
      port: 465,
      secure: true,
      auth: { user: "username", pass: "password" },
    });
    ```

=== "PHP"

    !!! warning "System Configuration Required"
        The basic `mail()` function requires configuring your system's MTA (e.g., Postfix) to relay through the SMTP server. For direct SMTP authentication, use PHPMailer below.


    ```php title="Send SMS via PHP"
    $to = "+1234567890@smtp.sms-gate.app";
    $subject = ""; // ignored
    $message = "Your verification code is 1234";
    $headers = "From: alerts@example.com\r\n";

    mail($to, $subject, $message, $headers);
    ```

    For SMTP authentication with PHP, use [PHPMailer](https://github.com/PHPMailer/PHPMailer):

    ```php title="Send SMS via PHPMailer"
    use PHPMailer\PHPMailer\PHPMailer;

    $mail = new PHPMailer();
    $mail->isSMTP();
    $mail->Host = "smtp.sms-gate.app";
    $mail->Port = 587;
    $mail->SMTPAuth = true;
    $mail->Username = "username";
    $mail->Password = "password";
    $mail->SMTPSecure = "tls";
    $mail->setFrom("alerts@example.com");
    $mail->addAddress("+1234567890@smtp.sms-gate.app");
    $mail->Body = "Your verification code is 1234";
    $mail->send();
    ```

### Infrastructure Examples

#### Grafana Alerts

Configure Grafana to send SMS via the SMTP bridge:

```ini title="grafana.ini"
[smtp]
enabled = true
host = smtp.sms-gate.app:587
user = username
password = password
from_address = grafana@sms-gate.app
```

Use `+1234567890@smtp.sms-gate.app` as the recipient in Grafana alert notification channels.

#### Nagios / Icinga

```bash title="Nagios command definition"
define command {
    command_name    notify-host-by-sms
    command_line    /usr/bin/mail \
      -s "Host Alert: $HOSTNAME$" \
      -r "nagios@sms-gate.app" \
      +1234567890@smtp.sms-gate.app \
      <<< "$HOSTOUTPUT$"
}
```

#### Postfix Relay

Route all email from your applications through the SMS bridge:

```bash title="Postfix relay configuration"
# /etc/postfix/main.cf
relayhost = smtp.sms-gate.app:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = static:username:password
smtp_sasl_security_options = noanonymous
smtp_tls_security_level = encrypt
```

## ❌ SMTP Error Response Codes

| Condition                      | SMTP Code | Message                            |
| ------------------------------ | --------- | ---------------------------------- |
| Success                        | 250       | Message accepted                   |
| Invalid email format           | 550       | Invalid recipient format           |
| Domain mismatch                | 550       | Invalid recipient domain           |
| Invalid phone number           | 550       | Invalid phone number format        |
| Empty message body             | 550       | Message body is empty              |
| SMSGate auth failure (401/403) | 535       | Authentication failed              |
| SMSGate client error (4xx)     | 450       | Temporary failure, try again later |
| SMSGate server error (5xx)     | 550       | Message delivery failed            |
| SMSGate timeout                | 451       | Timeout                            |

!!! note "No Retry Policy"
    The bridge returns errors immediately to the SMTP client. The sending email system is responsible for retries.

## 📚 See Also

- [Email to SMS Bridge Documentation](../services/email-to-sms.md)
- [REST API Reference](./api.md)
- [Authentication Guide](./authentication.md)
- [Email to SMS GitHub Repository](https://github.com/android-sms-gateway/email-to-sms)
