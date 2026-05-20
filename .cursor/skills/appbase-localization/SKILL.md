---
name: appbase-localization
description: >-
  Adds user-facing text to AppBase via Localizable.strings and SwiftGen (L10n).
  Updates en/vi/ja locales and regenerates Strings+Generated.swift. Use when
  adding labels, buttons, alerts, placeholders, titles, or any UI copy, or when
  the user mentions localization, Localizable, L10n, SwiftGen, translation, or
  đa ngôn ngữ.
---

# AppBase Localization + SwiftGen

**Never hardcode user-facing strings in Swift/UI.** Add keys to `Localizable.strings`, run SwiftGen, use `L10n` in code.

## Project layout

| Path | Role |
|------|------|
| `AppBase/Resources/Localization/en.lproj/Localizable.strings` | **Source for SwiftGen** (keys + fallback values) |
| `AppBase/Resources/Localization/vi.lproj/Localizable.strings` | Vietnamese |
| `AppBase/Resources/Localization/ja.lproj/Localizable.strings` | Japanese |
| `AppBase/Resources/Generated/Strings+Generated.swift` | **Generated** — do not edit by hand |
| `swiftgen.yml` | SwiftGen config (strings → `L10n`) |
| `custom_strings.stencil` | Template + `TranslationService` lookup |
| `AppBase/Core/Localization/TranslationService.swift` | Runtime language bundle |

Runtime language: `LocalizationService.shared.currentLanguage` (`en` / `vi` / `ja`).

## Workflow (required for every new string)

```
1. Add key → en.lproj/Localizable.strings
2. Add same key → vi.lproj + ja.lproj (translate or temporary copy)
3. Run SwiftGen
4. Use L10n.* in Swift (or assign to UI)
```

### Step 1 — Add keys (`en.lproj`)

Use **stable keys**, English or clear default as value (fallback when lookup fails):

```strings
/* Home */
"home.title" = "Home";
"home.empty" = "No items yet";

/* Login */
"login.submit" = "Sign in";
"common.loading" = "Loading...";
```

**Key rules**

- Prefer `screen.element` (dots) → nested enum, e.g. `L10n.Common.loading` for `"common.loading"`
- Or `screen_element` → `L10n.screenElement` (flat camelCase)
- No spaces in keys; avoid typos (`Helllo` → prefer `home.hello`)
- Escaping: `\"` inside values; `%@`, `%d`, `%f` for format strings

### Step 2 — Mirror locales

Add the **same keys** to:

- `vi.lproj/Localizable.strings`
- `ja.lproj/Localizable.strings`

```strings
"home.title" = "Trang chủ";
```

If translation unknown, use English temporarily — never skip keys in vi/ja.

### Step 3 — Run SwiftGen

From repo root (`AppBase` project directory containing `swiftgen.yml`):

```bash
./swiftgen/bin/swiftgen config run
```

Xcode also runs this via build phase **SwiftGen** (`"${PROJECT_DIR}/swiftgen/bin/swiftgen"`). After adding keys, run locally or build so `Strings+Generated.swift` updates.

### Step 4 — Use in code

```swift
title = L10n.Home.title          // key "home.title" → nested enum
label.text = L10n.Common.loading // key "common.loading"
button.setTitle(L10n.loginSubmit, for: .normal)  // key "loginSubmit"

// Format string: "welcome.user" = "Hello, %@";
navigationItem.title = L10n.welcomeUser("Alex")
```

**Do not:**

```swift
title = "Home"                   // ❌ hardcoded
title = NSLocalizedString(...)   // ❌ use L10n instead
```

Edit `Strings+Generated.swift` manually — **forbidden**; always change `.strings` + SwiftGen.

## SwiftGen config (do not change unless asked)

```yaml
# swiftgen.yml — strings parser
inputs: Resources/Localization/en.lproj
output: Resources/Generated/Strings+Generated.swift
template: custom_strings.stencil
lookupFunction: TranslationService.shared.lookupTranslation
```

Only **one** locale folder in `inputs` (en). Other languages are resolved at runtime via `TranslationService`.

## When touching existing UI

1. Grep for hardcoded `"..."` in VC/cells/coordinators.
2. Extract to `Localizable.strings` + `L10n`.
3. Replace literals, run SwiftGen, verify vi/ja files.

## Format strings

```strings
"order.count" = "You have %d items";
"greeting.name" = "Hello, %@";
```

Generated API uses typed parameters — match placeholder count/order.

## Storyboard / XIB

- Prefer setting `text` in code: `label.text = L10n.xxx` in `setupUI` / `viewDidLoad`.
- Or use `Localizable.strings` keys in IB (Object ID + `Localized` bundle) — still add keys to all three `.lproj` files.

## Checklist

See [checklist.md](checklist.md) for PR/review pass.

## Related

- UI layout: skill `appbase-ios` (SnapKit, TIO VCs)
- Empty/loading copy in base classes should use `L10n` (e.g. list loading), not raw `"Loading..."`
