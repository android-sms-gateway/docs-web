# Ping 🏓

The Ping feature enables real-time monitoring of device connectivity and health, while also allowing you to adjust the default message pull frequency in both Cloud and Private server modes.

```mermaid
sequenceDiagram
    participant Device
    participant Server
    participant Webhook
    
    par Pulling Messages
      Device->>Server: GET /messages (scheduled pull)
      Server-->>Device: New messages (if any)
    and Webhooks Sending
      Device->>Webhook: POST system:ping
      Webhook-->>Device: 200 OK
    end
```

## Use Cases 🔍

<div class="grid cards" markdown>

- :material-cloud-sync: **Scheduled Pulls**
    - Override the default 15-minute interval
    - Ensure timely message delivery
    - Configure frequency as needed

- :material-heart-pulse: **Health Monitoring**
    - Regular `system:ping` webhooks
    - Track device connectivity status

</div>

!!! warning "Battery Considerations"
    Enabling the Ping feature may increase battery usage. It's crucial to balance the need for frequent status updates with the impact on device battery life, especially for devices expected to operate for extended periods without charging.

## Configuration ⚙️

1. Navigate to :gear: **Settings** → **Ping**
2. Set the interval in seconds

<figure markdown>
  ![Ping Settings](../assets/features-ping-settings.png){ width="400" align=center }
  <figcaption>Ping configuration interface</figcaption>
</figure>

## See Also 📚

- [Cloud Server](../getting-started/public-cloud-server.md)
- [Private Server](../getting-started/private-server.md)
- [Webhooks](../features/webhooks.md)
- [Health Checks](../features/health.md)
