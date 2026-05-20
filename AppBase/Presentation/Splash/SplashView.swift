//
//  SplashView.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import SwiftUI

struct SplashView: View {

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 32) {

                Image(systemName: "doc.text")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.black)

                VStack(spacing: 20) {

                    Text(L10n.App.name)
                        .font(Font.swiftUIFont(.custom(38), style: .bold))
                        .foregroundColor(.black)
                    VStack(spacing: 12) {

                        Text(L10n.App.Tagline.prompting)

                        Text(L10n.App.Tagline.focus)
                    }
                    .font(Font.swiftUIFont(.text22))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea()
    }
}
