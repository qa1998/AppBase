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
                
                // MARK: - Icon
                
                Image(systemName: "doc.text")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.black)
                
                // MARK: - Content
                
                VStack(spacing: 20) {
                    
                    Text("MC Teleprompter")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.black)
                    VStack(spacing: 12) {
                        
                        Text("Nhắc chữ dễ dàng.")
                        
                        Text("Tập trung vào nội dung của bạn.")
                    }
                    .font(.system(size: 22, weight: .regular))
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
