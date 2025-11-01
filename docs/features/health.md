# Healthcheck 💔

The SMSGate provides healthcheck endpoints for monitoring the health of the app. The health information includes:

* **releaseId**: A unique identifier for the app release.
* **version**: The app version.
* **status**: The overall app status.
    * **pass**: The app is running normally.
    * **warn**: The app is running with some issues.
    * **fail**: The app is not running normally.
* **checks**: A list of health checks performed by the app, depends on the server mode.
    * **description**: A description of the health check.
    * **observedUnit**: The unit of the observed value.
    * **observedValue**: The value observed by the health check.
    * **status**: The status of the health check.

!!! note "📈 Status Calculation"
    The overall health status is calculated as follows:

    - **Default Status**: `pass`
    - **Status Levels**:
        - `pass` (0) - All checks passing
        - `warn` (1) - At least one warning
        - `fail` (2) - At least one failure
    - **Overall Status**: Determined by highest severity level across all checks

## Server Health ☁️

=== "📱 Local Server Mode"

    In Local mode, the healthcheck endpoint provides information about the device and the application.

    Example response:

    ```json
    {
      "checks": {
        "messages:failed": {
          "description": "Failed messages for last hour",
          "observedUnit": "messages",
          "observedValue": 0,
          "status": "pass"
        },
        "connection:status": {
          "description": "Internet connection status",
          "observedUnit": "boolean",
          "observedValue": 1,
          "status": "pass"
        },
        "connection:transport": {
          "description": "Network transport type",
          "observedUnit": "flags",
          "observedValue": 4,
          "status": "pass"
        },
        "connection:cellular": {
          "description": "Cellular network type",
          "observedUnit": "index",
          "observedValue": 0,
          "status": "pass"
        },
        "battery:level": {
          "description": "Battery level in percent",
          "observedUnit": "percent",
          "observedValue": 94,
          "status": "pass"
        },
        "battery:charging": {
          "description": "Is the phone charging?",
          "observedUnit": "flags",
          "observedValue": 4,
          "status": "pass"
        }
      },
      "releaseId": 1,
      "status": "pass",
      "version": "1.0.0"
    }
    ```

    Available health checks:

    - **messages:failed**: The number of failed messages for the last hour. `warn` when there is at least one failed message and `fail` when all messages during the last hour have failed.
    - **connection:status**: The status of the internet connection. `fail` when the Internet connection is not available.
    - **connection:transport**: The transport type of the network connection. When the device is connected to multiple networks, only a single value is provided:
        * 0: None
        * 1: Unknown
        * 2: Cellular
        * 4: WiFi
        * 8: Ethernet
    - **connection:cellular**: The cellular network type. Available only if `connection:transport` has flag `2: Cellular`, otherwise `0: None`.
        * 0: None
        * 1: Unknown
        * 2: Mobile2G
        * 3: Mobile3G
        * 4: Mobile4G
        * 5: Mobile5G
    - **battery:level**: The battery level in percent. `warn` when less than 25% and `fail` when less than 10%.
    - **battery:charging**: The status of charging as bit flags. For example, if the device is charging via USB, the value will be `1 + 4 = 5`.
        * 0: Not charging
        * 1: Charging
        * 2: AC charger connected
        * 4: USB charger connected

=== "⚙️ Cloud and Private Server Modes"

    The SMSGate server provides Kubernetes-compatible health check endpoints for monitoring service health. The system implements three dedicated endpoints following Kubernetes best practices, along with a legacy endpoint for backward compatibility with existing clients.

    For **Kubernetes deployments**, use the following endpoints:

    - **🔄 Liveness Probe**: `GET /health/live`
        - **Purpose**: Determine if the application is running correctly
        - **Response Format**:
          ```json
          {
            "status": "pass",
            "version": "1.33.0",
            "releaseId": "1234",
            "checks": {
              "system:goroutines": {
                "description": "Number of goroutines",
                "observedUnit": "goroutines",
                "observedValue": 15,
                "status": "pass"
              },
              "system:memory": {
                "description": "Memory usage",
                "observedUnit": "MiB",
                "observedValue": 45,
                "status": "pass"
              }
            }
          }
          ```
    - **🚦 Readiness Probe**: `GET /health/ready`
        - **Purpose**: Determine if the application is ready to accept traffic
        - **Response Format**:
          ```json
          {
            "status": "pass",
            "version": "1.33.0",
            "releaseId": "1234",
            "checks": {
              "db:ping": {
                "description": "Database ping",
                "observedUnit": "failed pings",
                "observedValue": 0,
                "status": "pass"
              }
            }
          }
          ```
    - **🚀 Startup Probe**: `GET /health/startup`
        - **Purpose**: Determine if the application has completed its startup sequence
        - **Response Format**: Same as readiness probe

    !!! important "Migration Note"
        Additionally, a legacy endpoint (`GET /health`) is maintained for backward compatibility with existing clients. This endpoint uses the same logic as the readiness probe.

    !!! tip
        Use the `system:ping` webhook to monitor device health, as the server probes only monitor the application server itself.

## Device Health 📱

The `system:ping` webhook provides device health information across all deployment modes.

In Cloud/Private server deployments, the webhook provides device-level health information while the server probes monitor the application server itself. This separation ensures administrators can monitor both the application infrastructure and the connected devices.

Example payload:

```json
{
  "deviceId": "ffffffffceb0b1db00000192672f2204",
  "event": "system:ping",
  "id": "mjDoocQLCsOIDra_GthuI",
  "payload": {
    "health": {
      "checks": {
        "messages:failed": {
          "description": "Failed messages for last hour",
          "observedUnit": "messages",
          "observedValue": 0,
          "status": "pass"
        },
        "connection:status": {
          "description": "Internet connection status",
          "observedUnit": "boolean",
          "observedValue": 1,
          "status": "pass"
        },
        "connection:transport": {
          "description": "Network transport type",
          "observedUnit": "flags",
          "observedValue": 4,
          "status": "pass"
        },
        "connection:cellular": {
          "description": "Cellular network type",
          "observedUnit": "index",
          "observedValue": 0,
          "status": "pass"
        },
        "battery:level": {
          "description": "Battery level in percent",
          "observedUnit": "percent",
          "observedValue": 94,
          "status": "pass"
        },
        "battery:charging": {
          "description": "Is the phone charging?",
          "observedUnit": "flags",
          "observedValue": 4,
          "status": "pass"
        }
      },
      "releaseId": 1,
      "status": "pass",
      "version": "1.0.0"
    }
  },
  "webhookId": "LreFUt-Z3sSq0JufY9uWB"
}
```

The webhook allows you to monitor the health of your devices in real-time, providing valuable information about message delivery, connectivity, and battery status.

## See Also 📚

* [Webhooks Guide](./webhooks.md)
