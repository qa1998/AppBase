# AppBase AdsKit — Checklist

Dùng với [SKILL.md](SKILL.md) khi thêm ads vào màn mới hoặc review PR.

## Project setup

- [ ] Target link package **AdsKit** (SPM)
- [ ] `GADApplicationIdentifier` trong `Info.plist`
- [ ] `AppDelegate.setupAdsKit()` gọi trong `didFinishLaunching`
- [ ] Production: thay test ad unit IDs trong `AdsConfig`

## Load / show

- [ ] `load*` gọi trước `show*` (hoặc preload có chủ đích)
- [ ] Kiểm tra `is*Ready()` nếu show ngay sau load async
- [ ] `show*(from: viewController)` — VC truyền `self` (hoặc host VC rõ ràng)
- [ ] Không show hai full-screen ads chồng nhau (`adAlreadyShowing`)
- [ ] Completion xử lý trên main thread khi cập nhật UI

## Banner

- [ ] `destroy(adType: .banner)` khi rời màn / `viewWillDisappear` nếu cần
- [ ] Layout content không bị che (inset bottom)

## Rewarded

- [ ] `onReward` cấp phần thưởng đúng business rule
- [ ] Không cấp thưởng nếu `completion` fail

## UX / localization

- [ ] Chuỗi UI qua `L10n` (skill `appbase-localization`)
- [ ] Lỗi hiển thị cho user (`presentError` / alert), không chỉ `print`

## Privacy

- [ ] ATT qua `AdsManager.requestTrackingAuthorizationIfNeeded`
- [ ] `NSUserTrackingUsageDescription` trong `Info.plist` nếu chưa có

## Premium / settings

- [ ] `setAdsEnabled(false)` khi user tắt ads / mua gói
