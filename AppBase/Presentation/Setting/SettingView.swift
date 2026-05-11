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
            VStack(spacing: 28) {
                
                settingsSection(
                    title: "PREFERENCES",
                    items: [
                        .init(
                            icon: "moon.fill",
                            iconColor: .indigo,
                            title: "Theme",
                            value: "System"
                        ),
                        .init(
                            icon: "globe",
                            iconColor: .blue,
                            title: "Language",
                            value: "English"
                        ),
                        .init(
                            icon: "bell.fill",
                            iconColor: .green,
                            title: "Notifications"
                        ),
                        .init(
                            icon: "square.grid.2x2.fill",
                            iconColor: .orange,
                            title: "Appearance"
                        )
                    ]
                )
                
                settingsSection(
                    title: "GENERAL",
                    items: [
                        .init(
                            icon: "shield.fill",
                            iconColor: .gray,
                            title: "Privacy"
                        ),
                        .init(
                            icon: "lock.fill",
                            iconColor: .blue,
                            title: "Security"
                        ),
                        .init(
                            icon: "icloud.fill",
                            iconColor: .green,
                            title: "Backup & Sync"
                        ),
                        .init(
                            icon: "internaldrive.fill",
                            iconColor: .purple,
                            title: "Storage"
                        )
                    ]
                )
                
                settingsSection(
                    title: "ABOUT",
                    items: [
                        .init(
                            icon: "info.circle.fill",
                            iconColor: .gray,
                            title: "App Version",
                            value: "1.2.3 (123)"
                        ),
                        .init(
                            icon: "heart.fill",
                            iconColor: .pink,
                            title: "Rate Us"
                        ),
                        .init(
                            icon: "questionmark.circle.fill",
                            iconColor: .yellow,
                            title: "Help & Support"
                        ),
                        .init(
                            icon: "doc.text.fill",
                            iconColor: .gray,
                            title: "Terms of Service"
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
            
            VStack(alignment: .leading, spacing: 12) {
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                
                VStack(spacing: 0) {
                    
                    ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                        
                        SettingsRow(item: item)
                        
                        if idx != items.count - 1 {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(.white)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 20,
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(item.iconColor)
            }
            
            Text(item.title)
                .font(.system(size: 17, weight: .medium))
            
            Spacer()
            
            if let value = item.value {
                Text(value)
                    .foregroundStyle(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
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
