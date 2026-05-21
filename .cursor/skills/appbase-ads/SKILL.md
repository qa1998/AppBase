---
name: appbase-ads
description: >-
  Integrates AdsKit (AdMob) in AppBase via AdsManager.shared. Use when adding or
  debugging banner, interstitial, rewarded, or app open ads, AdMob ad unit IDs,
  ATT/IDFA, load/show flow, or mentions AdsKit, AdsManager, AdMob, quảng cáo.
  App init in AppDelegate.setupAdsKit(). Reference demo: Scripts tab
  (ScriptsViewModel / ScriptsViewController). UI copy → skill appbase-localization.
  Presentation patterns → skill appbase-ios.
---

# AppBase AdsKit

## Overview

| Piece | Location |
|-------|----------|
| **SDK** | Local package `AdsKit/AdsKit` (SPM + Google Mobile Ads) |
| **Public API** | `AdsManager.shared` only — app **không** gọi `GAD*` trực tiếp |
| **Init** | `AppDelegate.setupAdsKit()` trong `didFinishLaunching` |
| **AdMob app ID** | `Info.plist` → `GADApplicationIdentifier` |
| **Demo / QA** | Tab **Scripts** (tab 2) — load/show từng `AdType` |

```
App launch → AppDelegate.setupAdsKit()
  → AdsConfig(ad unit IDs)
  → AdMobProvider(priority: 1)
  → AdsManager.shared.initialize(...)
  → requestTrackingAuthorizationIfNeeded (ATT)

Feature screen → load*() → (optional) is*Ready() → show*(from: UIViewController)
```

## Ad types (`AdType`)

| Type | Load | Show | Ghi chú |
|------|------|------|---------|
| `.banner` | `loadBanner` | `showBanner(from:)` | Gắn dưới `safeArea`; ẩn: `destroy(.banner)` |
| `.interstitial` | `loadInterstitial` | `showInterstitial(from:)` | Full-screen; load trước show |
| `.rewarded` | `loadRewarded` | `showRewarded(from:onReward:completion:)` | `onReward(amount, type)` khi user nhận thưởng |
| `.appOpen` | `loadAppOpen` | `showAppOpen(from:)` | Thường show khi vào foreground |

**Luôn:** `load` → đợi success → `show`. Show khi chưa load → `AdsError.adNotReady`.

## Init (AppDelegate)

```swift
import AdsKit

func setupAdsKit() {
    let adsConfig = AdsConfig(
        banner: "ca-app-pub-…",       // production: thay test ID
        interstitial: "ca-app-pub-…",
        rewarded: "ca-app-pub-…",
        appOpen: "ca-app-pub-…"
    )
    let adMobProvider = AdMobProvider(priority: 1)
    AdsManager.shared.initialize(config: adsConfig, providers: [adMobProvider]) { success, error in
        if success {
            AdsManager.shared.requestTrackingAuthorizationIfNeeded { _ in }
        }
    }
}
```

- Test IDs: [Google AdMob test ads](https://developers.google.com/admob/ios/test-ads) (đang dùng trong repo).
- Production: đổi **tất cả** unit ID + `GADApplicationIdentifier` trong `Info.plist`.

## MVVM trong AppBase

- **ViewModel:** `load*` / logic; có thể `presentError` qua `TIOViewModel.trackError` khi fail.
- **ViewController:** `show*(from: self)` — **bắt buộc** truyền `UIViewController` presenting.
- **Không** `push`/`present` ad từ Coordinator trừ khi coordinator giữ VC reference rõ ràng.

### Pattern (tham chiếu `ScriptsViewModel`)

```swift
import AdsKit

func loadInterstitial() {
    AdsManager.shared.loadInterstitial { [weak self] success, error in
        // MainActor / DispatchQueue.main nếu cập nhật UI
        guard success else {
            self?.presentError(message: error?.localizedDescription ?? L10n.Common.Error.message)
            return
        }
    }
}

func showInterstitial(from viewController: UIViewController) {
    AdsManager.shared.showInterstitial(from: viewController) { success, error in
        // handle dismiss / reload content
    }
}

func showRewarded(from viewController: UIViewController) {
    AdsManager.shared.showRewarded(from: viewController) { amount, type in
        // grant reward
    } completion: { success, error in
        // ad closed
    }
}

func hideBanner() {
    AdsManager.shared.destroy(adType: .banner)
}
```

### Banner layout

`AdMobProvider` pin banner **bottom** + `centerX` trên `viewController.view`. Chừa inset cho nội dung (SnapKit `bottom` constraint trên content phía trên banner).

## Readiness & errors

```swift
AdsManager.shared.isBannerReady()
AdsManager.shared.isInterstitialReady()
// … rewarded, appOpen
```

| `AdsError` | Ý nghĩa | Xử lý gợi ý |
|------------|---------|--------------|
| `notInitialized` | Chưa `initialize` / gọi quá sớm | Gọi sau `setupAdsKit` completion |
| `adNotReady` | Chưa load xong | `load*` trước, hoặc preload sớm |
| `adAlreadyShowing` | Đang show ad khác | Đợi dismiss; không show chồng |
| `adsDisabled` | `setAdsEnabled(false)` | Settings / IAP remove ads |
| `invalidAdUnitId` | Thiếu ID trong `AdsConfig` | Thêm key cho `AdType` |

## ATT / privacy

- Chỉ dùng `AdsManager.shared.requestTrackingAuthorizationIfNeeded` — **không** import `AppTrackingTransparency` trực tiếp trong feature (trừ Settings giải thích privacy).
- `advertisingIdentifier()` → IDFA nếu user cho phép.

## Enable / disable ads

```swift
AdsManager.shared.setAdsEnabled(false)  // destroy all ads
AdsManager.shared.setAdsEnabled(true)
```

Dùng cho gói premium / Cài đặt tắt quảng cáo.

## Localization (Scripts demo)

Keys `scripts.ads.*` → `L10n.Scripts.Ads.*`. Thêm nút/alert mới:

1. `en` / `vi` / `ja` `Localizable.strings`
2. `./swiftgen/bin/swiftgen config run`
3. `L10n` trong VC/VM — skill **`appbase-localization`**

## Preload gợi ý (production)

| Ad | Gợi ý preload |
|----|----------------|
| Interstitial | Sau màn X, trước action “tiếp tục” |
| Rewarded | Trước khi user bấm “xem quảng cáo nhận thưởng” |
| App open | `sceneWillEnterForeground` (không spam — cooldown) |
| Banner | Load khi vào màn có banner; `destroy` khi rời màn |

## Checklist nhanh (màn mới có ads)

```
- [ ] AdsKit đã init (AppDelegate) trước khi load
- [ ] Ad unit ID đúng môi trường (test vs prod)
- [ ] load* trước show*; handle adNotReady
- [ ] show* nhận UIViewController (thường từ VC, không VM giữ VC)
- [ ] Banner: destroy(.banner) khi deinit / rời màn
- [ ] Lỗi user-facing: presentError / L10n (không print-only)
- [ ] Không gọi Google Mobile Ads API trực tiếp trong AppBase feature code
```

Chi tiết review: [checklist.md](checklist.md)

## Files tham chiếu

| File | Vai trò |
|------|---------|
| `AppBase/Application/AppDelegate.swift` | `setupAdsKit()`, test unit IDs |
| `AppBase/SupportingFiles/Info.plist` | `GADApplicationIdentifier` |
| `AppBase/Presentation/Main/Tabs/Scripts/ScriptsViewModel.swift` | Load/show tất cả loại |
| `AppBase/Presentation/Main/Tabs/Scripts/ScriptsViewController.swift` | Nút demo + bind status |
| `AdsKit/AdsKit/Sources/AdsKit/Core/AdsManager.swift` | API đầy đủ |
| `AdsKit/AdsKit/Sources/AdsKit/Config/AdsConfig.swift` | Unit IDs |
| `AdsKit/AdsKit/Sources/AdsKit/Providers/AdMob/AdMobProvider.swift` | Banner layout, present |

## Related skills

- **`appbase-ios`** — TIOViewController, Coordinator, theme, SnapKit
- **`appbase-localization`** — mọi chuỗi UI (nút Load/Show, lỗi)

## Out of scope

- Sửa logic bên trong `AdsKit/` package (trừ user yêu cầu).
- Mediation provider khác ngoài `AdMobProvider` (có thể đăng ký thêm qua `initialize(providers:)` khi SDK hỗ trợ).
