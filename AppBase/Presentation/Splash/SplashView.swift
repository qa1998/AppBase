//
//  SplashView.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import SwiftUI

struct SplashView: View {

    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: Spacing.s32) {

                Image(systemName: "doc.text")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .foregroundStyle(Color(uiColor: themeManager.palette.textPrimary))

                VStack(spacing: Spacing.s20) {

                    Text(L10n.App.name)
                        .font(Font.swiftUIFont(.custom(38), style: .bold))
                        .foregroundStyle(Color(uiColor: themeManager.palette.textPrimary))
                    VStack(spacing: Spacing.s12) {

                        Text(L10n.App.Tagline.prompting)

                        Text(L10n.App.Tagline.focus)
                    }
                    .font(Font.swiftUIFont(.text22))
                    .foregroundStyle(Color(uiColor: themeManager.palette.textSecondary))
                    .multilineTextAlignment(.center)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: themeManager.palette.backgroundSecondary))
        .ignoresSafeArea()
    }
}
