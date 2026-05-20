//
//  SettingView.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import SwiftUI

struct SettingView: View {
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
                            value: L10n.Settings.Theme.system
                        ),
                        .init(
                            icon: "globe",
                            iconColor: .blue,
                            title: L10n.Settings.language,
                            value: LocalizationService.shared.currentLanguage.localizedTitle
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
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
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
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {

                ForEach(Array(items.enumerated()), id: \.offset) { idx, item in

                    SettingsRow(item: item)

                    if idx != items.count - 1 {
                        Divider()
                            .padding(.leading, Spacing.s32)
                    }
                }
            }
            .background(.white)
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

    var body: some View {
        HStack(spacing: 16) {

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

            Spacer()

            if let value = item.value {
                Text(value)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(Font.swiftUIFont(.text13, style: .bold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
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
}
