# monitor-ios

Phần iOS SDK (Measure) tách ra từ repo [monitor](https://github.com/tuanha95-mobile/monitor).

- `ios/` — mã nguồn SDK, demo app, tests, Xcode workspace
- `Package.swift` — Swift Package Manager
- `measure-sh.podspec` — CocoaPods
- `dist/Measure.xcframework` — bản build sẵn

## 3. iOS

### 3.1. Yêu cầu
- Xcode 27.x → **min iOS đã nâng lên 15.0** (bản gốc 13.0, Xcode 27 không build được <15).
- `libwebp` là git submodule — clone kèm submodule:
  ```bash
  git submodule update --init --recursive
  ```

### 3.2. Nhúng SDK
Mở `ios/Measure.xcworkspace` và thêm target `Measure` vào app, **hoặc** dùng CocoaPods:

```ruby
# Podfile
platform :ios, '15.0'
pod 'measure-sh', :path => '../path/to/monitor'   # trỏ tới bản fork
```

### 3.3. Khởi tạo (AppDelegate / App init)

Local mode **không cần credential**. Dùng overload init không tham số:

```swift
import MeasureSDK   // hoặc: import Measure

Measure.initialize(config: BaseMeasureConfig(
    enableLogging: true,
    enableFullCollectionMode: true
))
Measure.start()
```

> (Tuỳ chọn) Vẫn có thể dùng `Measure.initialize(with: ClientInfo(apiKey:apiUrl:), config:)` nếu sau này muốn cấu hình server.

### 3.4. Xem monitor realtime
In ra Xcode console với prefix **`[MeasureMonitor]`**:

```
[MeasureMonitor] EVENT  gesture_click
   session : 0f9c...e21
   time    : 2026-10-30T08:12:33.120Z
   data    : ...
[MeasureMonitor] SPAN   screen_load  142ms  [ok]
   session : 0f9c...e21
[MeasureMonitor] Local mode: not uploading. Retained in DB -> 37 events, 4 spans.
```

### 3.5. Đọc lại monitor đã lưu từ DB

```swift
let dump = Measure.getStoredMonitors(limit: 100)  // trả về String + in ra console
print(dump)
```

---

