//
//  LineupShareQRCode.swift
//  AppBase
//

import CoreImage.CIFilterBuiltins
import UIKit

enum LineupShareQRCode {
    static func image(for lineup: FootballLineup, scale: CGFloat = 8) -> UIImage? {
        let payload = "appbase://lineup/\(lineup.id)"
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(Data(payload.utf8), forKey: "inputMessage")
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        return UIImage(ciImage: scaled)
    }
}
