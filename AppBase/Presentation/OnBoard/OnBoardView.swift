//
//  OnBoardView.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import SwiftUI

struct OnBoardView: View {
    let callbackAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
                .frame(height: 120)
            
            Image(systemName: "doc.text")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(.black)
            
            Spacer()
                .frame(height: 40)
            
            Text("MC Teleprompter")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
                .frame(height: 24)
            
            VStack(spacing: 10) {
                Text("Nhắc chữ dễ dàng.")
                
                Text("Tập trung vào nội dung của bạn.")
            }
            .font(.system(size: 20))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            
            Spacer()
            
            Button {
                callbackAction()
            } label: {
                Text("Bắt đầu")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color.black)
                    .cornerRadius(20)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}
