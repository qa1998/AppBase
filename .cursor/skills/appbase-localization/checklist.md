# Localization checklist

- [ ] User-facing text not hardcoded in Swift
- [ ] Key added to `en.lproj/Localizable.strings`
- [ ] Same key in `vi.lproj` and `ja.lproj`
- [ ] Key naming: `screen.element` or clear camelCase (no typos)
- [ ] SwiftGen run (`./swiftgen/bin/swiftgen config run` or Xcode build)
- [ ] `Strings+Generated.swift` updated — not hand-edited
- [ ] Code uses `L10n.*` (or `L10n.nested.*`)
- [ ] Format placeholders (`%@`, `%d`) match generated function args
- [ ] Alert/message/button/placeholder/navigation title covered
- [ ] No duplicate keys; comments in `.strings` for context if needed
