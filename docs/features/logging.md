# Logging

The app logs operations directly to the device, providing valuable information for debugging and bug reporting. Although not all app modules currently write logs, this feature is essential for identifying and resolving issues.

## Log Entry Description

Each log entry contains the following information:

*   **ID**: A unique identifier for the log entry.
*   **Priority**: The priority level of the log entry, which can be one of the following:
    *   "ERROR"
    *   "WARN"
    *   "INFO"
    *   "DEBUG"
*   **Module**: The module or component of the system that generated the log entry.
*   **Message**: A message describing the log event.
*   **Context**: Additional information about the log entry in the form of key-value pairs.
*   **Timestamp**: The timestamp when the log entry was created.

## Accessing Logs

There are two ways to access logs:

1.  **UI**: You can view the last 50 log entries directly from the app UI. To do this, open the Settings tab and select the "View" item in the "Logs" section.
2.  **Local Mode API**: In Local mode, the app exposes the [/logs endpoint](https://capcom6.github.io/android-sms-gateway/#/System/get-logs), which returns a list of log entries with a filter by period.

Logs aren't accessible in Cloud/Private mode for privacy reasons.

## Log Settings

Log settings are located on the Settings tab of the app in the "Logs" section. The only available option is "Delete after, days," which sets the log entries' lifetime. You can set the number of days after which log entries will be deleted. It is strongly recommended to enable this option to avoid device memory exhaustion.

## Privacy

Logs are stored in the device's memory and are not sent to the Cloud/Private server because they can contain sensitive data. However, they can be accessed in Local server mode through direct access to the device API: <https://capcom6.github.io/android-sms-gateway/#/System/get-logs>