//
//  OnBoardView.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import SwiftUI

struct OnBoardView: View {

    @ObservedObject private var themeManager = ThemeManager.shared
    let callbackAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            Spacer()
                .frame(height: 120)

            Image(systemName: "doc.text")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(Color(uiColor: themeManager.palette.textPrimary))

            Spacer()
                .frame(height: 40)

            Text(L10n.App.name)
                .font(Font.swiftUIFont(.text34, style: .bold))
                .foregroundStyle(Color(uiColor: themeManager.palette.textPrimary))

            Spacer()
                .frame(height: 24)

            VStack(spacing: Spacing.s12) {
                Text(L10n.App.Tagline.prompting)

                Text(L10n.App.Tagline.focus)
            }
            .font(Font.swiftUIFont(.custom(20)))
            .foregroundStyle(Color(uiColor: themeManager.palette.textSecondary))
            .multilineTextAlignment(.center)

            Spacer()

            Button(action: callbackAction) {
                Text(L10n.Onboard.start)
                    .font(Font.swiftUIFont(.text22, style: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(uiColor: themeManager.palette.textPrimary))
                    .cornerRadius(Radius.s20)
            }
            .padding(.horizontal, Spacing.s28)
            .padding(.bottom, Spacing.s40)
        }
        .background(Color(uiColor: themeManager.palette.backgroundSecondary))
        .ignoresSafeArea()
    }
}
