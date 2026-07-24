# W OS — Swift Native (v2.1.0)

Bản chuyển đổi đầy đủ của toàn bộ dự án `w-os` (React Native + Expo) sang
**Swift / SwiftUI native cho iOS**. Toàn bộ 25 file mã nguồn gốc (screens,
components, data, services, theme) đã được đọc và viết lại 1:1 theo đúng
logic gốc, cộng thêm các tính năng mới được yêu cầu.

## Những gì đã được chuyển đổi (mapping 1:1)

| File React Native gốc                          | File Swift tương ứng                                   |
|--------------------------------------------------|----------------------------------------------------------|
| `App.js` (WOSContext)                            | `ViewModels/SystemState.swift` + `Views/ContentView.swift` |
| `src/components/BootScreen.js`                   | `Views/BootView.swift`                                   |
| `src/components/StatusBarWOS.js`                 | `Views/StatusBarWOS.swift`                                |
| `src/components/Window.js`                       | `Views/WindowView.swift`                                  |
| `src/data/realApps.js`                           | `Data/RealAppsData.swift` + `Models/RealApp.swift`         |
| `src/data/systemApps.js`                         | `Data/SystemAppsData.swift` + `Models/SystemApp.swift`     |
| `src/services/api.js`                            | `Services/CloudSyncService.swift`                          |
| `src/services/linking.js`                        | `Services/LinkingService.swift`                            |
| `src/theme/Icon.js`                              | `Models/IconRef.swift` (SF Symbols thay cho @expo/vector-icons) |
| `src/screens/SetupScreen.js`                     | `Views/SetupView.swift` (mở rộng thêm bước chọn Boot Drive) |
| `src/screens/LockScreen.js`                      | `Views/LockView.swift`                                     |
| `src/screens/DesktopScreen.js`                   | `Views/DesktopView.swift`                                  |
| `src/screens/ControlCenter.js`                   | `Views/ControlCenterView.swift`                             |
| `src/screens/NotificationCenter.js`              | `Views/NotificationCenterView.swift`                        |
| `src/screens/SearchScreen.js`                    | `Views/SearchView.swift`                                    |
| `src/screens/MultitaskScreen.js`                 | `Views/MultitaskView.swift`                                 |
| `src/screens/SettingsScreen.js`                  | `Apps/SettingsAppView.swift` (mở rộng thêm phần Boot Drive) |
| `src/screens/BrowserScreen.js`                   | `Apps/BrowserAppView.swift` (dùng `WKWebView` native)       |
| `src/screens/AppStoreScreen.js`                  | `Apps/AppStoreAppView.swift`                                |
| `src/screens/TerminalScreen.js`                  | `Apps/TerminalAppView.swift`                                |
| `src/screens/FileManagerScreen.js`               | `Apps/FileManagerAppView.swift`                             |
| `src/screens/CalculatorScreen.js`                | `Apps/CalculatorAppView.swift`                              |
| `src/screens/NotesScreen.js`                     | `Apps/NotesAppView.swift`                                   |
| `src/screens/WeatherScreen.js`                   | `Apps/WeatherAppView.swift`                                 |
| `src/screens/MusicScreen.js`                     | `Apps/MusicAppView.swift`                                   |
| `src/screens/CalendarScreen.js`                  | `Apps/CalendarAppView.swift`                                |
| *(mới)*                                          | `Apps/UpdateAppView.swift` — app "Cập nhật" hệ thống         |
| *(mới)*                                          | `Services/BootDriveService.swift` + `Theme/Wallpaper.swift` |

## Tính năng mới được thêm

1. **Hình nền (Wallpaper) thật** — 5 hình nền gradient được tạo riêng
   (`default`, `blue`, `purple`, `red`, `green`) đóng gói trong
   `Assets.xcassets`, thay cho các màu nền phẳng của bản gốc. Chọn ở bước 4
   trong Setup hoặc trong Cài đặt > Giao diện.
2. **App "Cập nhật"** — biểu tượng riêng trên Desktop + trong Cài đặt, kiểm
   tra phiên bản hệ thống.
3. **Lựa chọn Boot Drive sau khi đặt mật khẩu** (bước 5–6 trong Setup, và
   cũng có trong Cài đặt > Hệ điều hành):
   - **"Tự boot drive riêng (Tự Build)"** — nhập URL repo (GitHub/GitLab) để
     đọc mã nguồn, hoặc bấm "tải file lên" để chọn file từ máy
     (`.fileImporter`), rồi hệ thống "build" boot drive từ đó
     (`BootDriveService.buildFromRepo` / `buildFromUploadedFile`).
   - **"Chạy drive do Admin build"** — dùng bản boot image có sẵn do admin
     build (`BootDriveService.useAdminDrive`).
   - Trạng thái hiện tại luôn xem được trong Terminal (`bootinfo`) và trong
     Cài đặt.

## Cấu trúc dự án

```
wOS/
├── project.yml          <- cấu hình XcodeGen, sinh ra wOS.xcodeproj
├── codemagic.yaml        <- CI/CD pipeline cho Codemagic
├── Support/Info.plist    <- Info.plist (khai báo URL schemes cho Linking)
└── Sources/wOS/
    ├── wOSApp.swift
    ├── Models/            (IconRef, SystemApp, RealApp)
    ├── Data/              (SystemAppsData, RealAppsData)
    ├── Services/          (LinkingService, CloudSyncService, BootDriveService)
    ├── Theme/             (Colors, Wallpaper)
    ├── ViewModels/        (SystemState)
    ├── Views/             (Boot/Setup/Lock/Desktop/Window/StatusBar/ControlCenter/...)
    ├── Apps/              (Settings/Browser/AppStore/Terminal/Files/Calculator/Notes/Weather/Music/Calendar/Update)
    └── Resources/Assets.xcassets/  (5 wallpaper image sets)
```

## Build & chạy trên Codemagic

Dự án **không** commit sẵn file `.xcodeproj` — Codemagic sẽ tự sinh ra bằng
[XcodeGen](https://github.com/yonaskolb/XcodeGen) từ `project.yml` mỗi lần
build, nên không bao giờ bị lỗi UUID / conflict project file khi nhiều người
cùng sửa.

1. Đẩy toàn bộ thư mục này (`wOS/`) lên một Git repo (GitHub/GitLab/Bitbucket).
2. Trên Codemagic: **Add application** → chọn repo đó → Codemagic tự động
   đọc `codemagic.yaml`.
3. Chọn workflow:
   - `ios-simulator-build`: build ngay, **không cần** chữ ký (code signing),
     dùng để kiểm tra biên dịch nhanh trên Simulator. Chạy ổn định ngay lần
     đầu.
   - `ios-device-release`: build ra file `.ipa` thật để cài lên thiết bị/TestFlight —
     cần cấu hình **Code signing identity** (App Store Connect API key) trong
     Codemagic UI trước, đặt vào group `ios_signing` được tham chiếu trong
     `codemagic.yaml`.
4. Bấm **Start new build**.

## Build cục bộ (máy Mac có Xcode)

```bash
brew install xcodegen
cd wOS
xcodegen generate
open wOS.xcodeproj
```

## Ghi chú kỹ thuật

- Yêu cầu iOS 16.0+ (SwiftUI `TextEditor.scrollContentBackground`, `Slider`,
  `fileImporter`, `confirmationDialog`...).
- `LinkingService` mở app thật qua URL scheme / https — không giả lập, giống
  hành vi gốc của `linking.js`. Các scheme cần dùng đã khai báo trong
  `LSApplicationQueriesSchemes` (`Support/Info.plist`) để `canOpenURL` hoạt
  động đúng trên iOS.
- `CloudSyncService` fail-soft giống `api.js`: nếu chưa cấu hình server (Cài
  đặt > Dữ liệu đám mây) thì toàn bộ tính năng (Ghi chú, Thư viện App) tự
  dùng dữ liệu offline có sẵn, không bao giờ crash app.
