//
//  Constants.swift
//  MeasureSDK
//
//  Created by Adwin Ross on 06/09/24.
//

import Foundation
import os.log

typealias Number = Int64
typealias UnsignedNumber = UInt64
typealias FloatNumber32 = Float32
typealias FloatNumber64 = Float64

let logTag = "com.measure.sh"
let cacheDirectoryName = "com.measure.sh"
let backgroundQueueLabel = "com.measure.background"
let periodicEventExporterLabel = "com.measure.periodicEventExporter"
let userInitiatedQueueLabel = "com.measure.userInitiated"
let eventsEndpoint = "events"
let multipartBoundry = "--boundary-7MA4YWxkTrZu0gW"
let authorization = "Authorization"
let bearer = "Bearer"
let msrRequestId = "msr-req-id"
let formFieldEvent = "event"
let formFieldSpan = "span"
let suiteName = "com.measure.sh"
let userIdKey = "user_id"
let eTagKey = "config_etag"
let installationIdKey = "installation_id"
let recentEventTrackedTimestamp = "latest_event_tracked_timestamp"
let recentSessionIdKey = "recent_session_id"
let recentSessionEventTimeKey = "recent_session_event_time"
let recentSessionCreatedAtKey = "recent_session_created_at"
let recentSessionCrashedKey = "recent_session_crashed_key"
let recentSessionVersionCodeKey = "recent_session_version_code"
let recentLaunchAppVersion = "recent_launch_app_version"
let recentLaunchTimeSinceLastBoot = "recent_launch_time_since_last_boot"
let configFetchTimestampKey = "msr_config_fetch_ts"
let configCacheControlKey = "msr_config_cache_control"
let orphanCleanupKey = "msr_orphan_cleanup_key"
let networkInterceptorHandledKey = "NetworkInterceptorHandled"
let screenshotName = "screenshot.webp"
let galleryImageName = "galleryImage.webp"
let layoutSnapshotName = "layoutSnapshot.svg"
let layoutSnapshotDirectoryName = "layoutSnapshot"
let fallbackApiUrl = "http://fallback"
let recentAppVersion = "recentAppVersion"
let recentAppBuildNumber = "recentAppBuildNumber"
let screenshotContentTypeWebp = "image/webp"
let screenshotContentTypePng = "image/png"
let layoutSnapshotContentType = "image/svg+xml"
let layoutSnapshotJsonContentType = "application/json"
let layoutSnapshotJsonContentEncoding = "gzip"
let swiftErrorFramesToStrip = 3
let objcErrorFramesToStrip = 4

struct AttributeConstants {
    static let deviceManufacturer = "Apple"
    static let unknown = "unknown"
}

/// Emits every monitor (event or span) collected by the SDK to the platform's unified log so
/// developers can see them in real time, without needing a backend server.
///
/// The data itself is still persisted in the local CoreData store. This printer only gives
/// developers an immediate, human readable view of what is being stored. Output goes through
/// `os_log` under subsystem `sh.measure.monitor` / category `MeasureMonitor`, and each line is
/// still prefixed with `[MeasureMonitor]`. This mirrors the Android AAR, which logs to Logcat
/// under the `MeasureMonitor` tag — so on both platforms the monitors show up in the native log
/// stream (Android: `adb logcat -s MeasureMonitor`; iOS: Console.app / `log stream` filtered by
/// `subsystem:sh.measure.monitor`, or `xcrun simctl spawn <UDID> log stream`).
///
/// Interpolated values are logged `%{public}@` (not redacted) because this printer is DEBUG-only
/// local mode — `startSdk()` is gated behind `#if DEBUG`, so release builds neither start the SDK
/// nor reach this code, and no monitor data (incl. HTTP bodies) is written to the device log in a
/// shipped build.
enum MonitorPrinter {
    static let tag = "MeasureMonitor"

    /// Unified-log handle. Category `MeasureMonitor` keeps it filterable the same way as Logcat.
    private static let log = OSLog(subsystem: "sh.measure.monitor", category: tag)

    /// Emits a single event as it is stored in the database.
    static func event(type: String, sessionId: String, timestamp: String, userTriggered: Bool, data: String?) {
        var message = "[\(tag)] EVENT  \(type)"
        if userTriggered {
            message += "  (user-triggered)"
        }
        message += "\n   session : \(sessionId)"
        message += "\n   time    : \(timestamp)"
        if let data = data, !data.isEmpty {
            message += "\n   data    : \(data)"
        }
        emit(message)
    }

    /// Emits a single span (trace) as it is stored in the database.
    static func span(name: String, durationMs: Int64, status: String, sessionId: String) {
        emit("[\(tag)] SPAN   \(name)  \(durationMs)ms  [\(status)]\n   session : \(sessionId)")
    }

    /// Emits an arbitrary informational line, used for summaries like how many monitors are
    /// currently retained in the database.
    static func line(_ message: String) {
        emit("[\(tag)] \(message)")
    }

    /// Single sink: unified log at `.default` level (public, so the dev actually sees the values
    /// in local mode). `.default` — not `.info`/`.debug` — so the lines show up in Console.app and
    /// `log stream` without needing an extra `--level` flag, matching the Android AAR which logs at
    /// Logcat's default-visible `INFO` priority.
    private static func emit(_ message: String) {
        os_log("%{public}@", log: log, type: .default, message)
    }
}

struct CrashDataKeys {
    static let threadName = "thread_name"
    static let deviceName = "device_name"
    static let deviceModel = "device_model"
    static let deviceManufacturer = "device_manufacturer"
    static let deviceType = "device_type"
    static let deviceIsFoldable = "device_is_foldable"
    static let deviceIsPhysical = "device_is_physical"
    static let deviceDensityDpi = "device_density_dpi"
    static let deviceWidthPx = "device_width_px"
    static let deviceHeightPx = "device_height_px"
    static let deviceDensity = "device_density"
    static let deviceTotalMemory = "device_total_memory"
    static let deviceLocale = "device_locale"
    static let osName = "os_name"
    static let osVersion = "os_version"
    static let networkType = "network_type"
    static let networkGeneration = "network_generation"
    static let networkProvider = "network_provider"
    static let installationId = "installation_id"
    static let userId = "user_id"
    static let deviceCpuArch = "device_cpu_arch"
    static let appVersion = "app_version"
    static let appBuild = "app_build"
    static let measureSdkVersion = "measure_sdk_version"
    static let appUniqueId = "app_unique_id"
    static let sessionId = "session_id"
    static let isForeground = "is_foreground"
}
