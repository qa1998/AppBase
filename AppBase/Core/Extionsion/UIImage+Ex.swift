//
//  UIImage+Ex.swift
//  AppBase
//
//  Created by QuangAnh on 22/5/26.
//
import UIKit
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
extension CGSize {
    static func square(size: CGFloat) -> CGSize{
        return CGSize(width: size, height: size)
    }
}
