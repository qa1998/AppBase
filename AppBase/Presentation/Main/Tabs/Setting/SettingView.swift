//
//  SettingView.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import SwiftUI

struct SettingView: View {

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localization = LocalizationService.shared

    @State private var showThemePicker = false
    @State private var showLanguagePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.s24) {

                settingsSection(
                    title: L10n.Settings.Section.preferences,
                    items: [
                        .init(
                            icon: "moon.fill",
                            iconColor: .indigo,
                            title: L10n.Settings.theme,
                            value: themeManager.mode.localizedTitle,
                            onTap: { showThemePicker = true }
                        ),
                        .init(
                            icon: "globe",
                            iconColor: .blue,
                            title: L10n.Settings.language,
                            value: localization.currentLanguage.localizedTitle,
                            onTap: { showLanguagePicker = true }
                        ),
                        .init(
                            icon: "bell.fill",
                            iconColor: .green,
                            title: L10n.Settings.notifications
                        ),
                        .init(
                            icon: "square.grid.2x2.fill",
                            iconColor: .orange,
                            title: L10n.Settings.appearance
                        )
                    ]
                )

                settingsSection(
                    title: L10n.Settings.Section.general,
                    items: [
                        .init(
                            icon: "shield.fill",
                            iconColor: .gray,
                            title: L10n.Settings.privacy
                        ),
                        .init(
                            icon: "lock.fill",
                            iconColor: .blue,
                            title: L10n.Settings.security
                        ),
                        .init(
                            icon: "icloud.fill",
                            iconColor: .green,
                            title: L10n.Settings.backup
                        ),
                        .init(
                            icon: "internaldrive.fill",
                            iconColor: .purple,
                            title: L10n.Settings.storage
                        )
                    ]
                )

                settingsSection(
                    title: L10n.Settings.Section.about,
                    items: [
                        .init(
                            icon: "info.circle.fill",
                            iconColor: .gray,
                            title: L10n.Settings.appVersion,
                            value: L10n.Settings.AppVersion.value
                        ),
                        .init(
                            icon: "heart.fill",
                            iconColor: .pink,
                            title: L10n.Settings.rateUs
                        ),
                        .init(
                            icon: "questionmark.circle.fill",
                            iconColor: .yellow,
                            title: L10n.Settings.help
                        ),
                        .init(
                            icon: "doc.text.fill",
                            iconColor: .gray,
                            title: L10n.Settings.terms
                        )
                    ]
                )
            }
            .padding(.horizontal, Spacing.s20)
            .padding(.top, Spacing.s16)
            .padding(.bottom, Spacing.s40)
        }
        .tioScreenBackground()
        .confirmationDialog(
            L10n.Settings.theme,
            isPresented: $showThemePicker,
            titleVisibility: .visible
        ) {
            ForEach(ThemeMode.allCases, id: \.self) { mode in
                Button(mode.localizedTitle) {
                    themeManager.mode = mode
                }
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerSheet(
                selected: localization.currentLanguage,
                onSelect: { language in
                    localization.setLanguage(language)
                    showLanguagePicker = false
                }
            )
        }
        .tioLocalizationAware()
    }
}

// MARK: - Language picker

private struct LanguagePickerSheet: View {

    let selected: Language
    let onSelect: (Language) -> Void

    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
            List(Language.allCases, id: \.self) { language in
                Button {
                    onSelect(language)
                } label: {
                    HStack {
                        Text(language.localizedTitle)
                            .foregroundStyle(Color(uiColor: themeManager.palette.textPrimary))
                        Spacer()
                        if language == selected {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(uiColor: themeManager.palette.primary))
                        }
                    }
                }
            }
            .navigationTitle(L10n.Settings.language)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
    }
}

extension SettingView {
    func settingsSection(
        title: String,
        items: [SettingItem]
    ) -> some View {

        VStack(alignment: .leading, spacing: Spacing.s12) {

            Text(title)
                .font(Font.swiftUIFont(.text13, style: .bold))
                .foregroundStyle(Color(uiColor: themeManager.palette.textSecondary))
                .padding(.horizontal, Spacing.s4)

            VStack(spacing: 0) {

                ForEach(Array(items.enumerated()), id: \.offset) { idx, item in

                    SettingsRow(item: item, palette: themeManager.palette)

                    if idx != items.count - 1 {
                        Divider()
                            .padding(.leading, Spacing.s32)
                    }
                }
            }
            .background(Color(uiColor: themeManager.palette.backgroundPrimary))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Radius.s20,
                    style: .continuous
                )
            )
        }
    }
}

struct SettingsRow: View {

    let item: SettingItem
    let palette: ThemeColors

    var body: some View {
        Group {
            if let onTap = item.onTap {
                Button(action: onTap) {
                    rowContent
                }
                .buttonStyle(.plain)
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: Spacing.s16) {

            ZStack {
                RoundedRectangle(cornerRadius: Radius.s12)
                    .fill(item.iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: item.icon)
                    .font(Font.swiftUIFont(.custom(16), style: .bold))
                    .foregroundStyle(item.iconColor)
            }

            Text(item.title)
                .font(Font.swiftUIFont(.text17))
                .foregroundStyle(Color(uiColor: palette.textPrimary))

            Spacer()

            if let value = item.value {
                Text(value)
                    .foregroundStyle(Color(uiColor: palette.textSecondary))
            }

            Image(systemName: "chevron.right")
                .font(Font.swiftUIFont(.text13, style: .bold))
                .foregroundStyle(Color(uiColor: palette.textSecondary).opacity(0.6))
        }
        .padding(.horizontal, Spacing.s16)
        .frame(height: 60)
        .contentShape(Rectangle())
    }
}

// MARK: - Model

struct SettingItem {

    let icon: String
    let iconColor: Color
    let title: String
    var value: String? = nil
    var onTap: (() -> Void)? = nil
}
