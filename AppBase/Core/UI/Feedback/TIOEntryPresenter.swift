//
//  TIOEntryPresenter.swift
//  AppBase
//
//  Toast top — SwiftEntryKit preset `topFloat` (margins + dưới notch).
//

import SwiftEntryKit
import UIKit

enum TIOEntryPresenter {

    private static let displayDuration: TimeInterval = 3

    static func showError(_ error: TIOUserFacingError) {
        let palette = ThemeManager.shared.palette
        var attributes = floatTopAttributes(haptic: .error)
        attributes.entryBackground = .color(color: EKColor(palette.backgroundPrimary))
        attributes.shadow = .active(
            with: .init(
                color: EKColor(.black),
                opacity: 0.18,
                radius: 10,
                offset: .init(width: 0, height: 4)
            )
        )

        let view = makeNotificationView(
            title: error.title ?? L10n.Common.Error.title,
            message: error.message,
            palette: palette,
            accentColor: palette.error
        )
        SwiftEntryKit.display(entry: view, using: attributes)
    }

    static func showSuccess(_ success: TIOSuccessMessage) {
        let palette = ThemeManager.shared.palette
        var attributes = floatTopAttributes(haptic: .success)
        attributes.entryBackground = .color(color: EKColor(palette.backgroundPrimary))
        attributes.shadow = .active(
            with: .init(
                color: EKColor(.black),
                opacity: 0.18,
                radius: 10,
                offset: .init(width: 0, height: 4)
            )
        )

        let view = makeNotificationView(
            title: success.title ?? L10n.Common.Success.title,
            message: success.message,
            palette: palette,
            accentColor: palette.primary
        )
        SwiftEntryKit.display(entry: view, using: attributes)
    }

    // MARK: - Private

    private static func makeNotificationView(
        title: String,
        message: String,
        palette: ThemeColors,
        accentColor: UIColor
    ) -> EKNotificationMessageView {
        let titleContent = EKProperty.LabelContent(
            text: title,
            style: labelStyle(font: Font.bold(size: .text15), color: accentColor)
        )
        let descriptionContent = EKProperty.LabelContent(
            text: message,
            style: labelStyle(font: Font.default(size: .text13), color: palette.textSecondary)
        )
        let simpleMessage = EKSimpleMessage(
            image: nil as EKProperty.ImageContent?,
            title: titleContent,
            description: descriptionContent
        )
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        return EKNotificationMessageView(with: notificationMessage)
    }

    /// Giống demo **Floats** — lề ngang 20pt, cách top ~10pt, không phủ notch.
    private static func floatTopAttributes(haptic: EKAttributes.NotificationHapticFeedback) -> EKAttributes {
        var attributes = EKAttributes.topFloat
        attributes.displayDuration = displayDuration
        attributes.hapticFeedbackType = haptic
        attributes.roundCorners = .all(radius: Radius.s12)
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.3),
                scale: .init(from: 1, to: 0.92, duration: 0.3)
            )
        )
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.screenInteraction = .forward
        attributes.entryInteraction = .absorbTouches

        let edgeWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        attributes.positionConstraints.size = .init(
            width: .offset(value: Spacing.s20),
            height: .intrinsic
        )
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: edgeWidth),
            height: .intrinsic
        )
        attributes.positionConstraints.verticalOffset = Spacing.s12
        // Giữ mặc định topFloat: safeArea trống (không fill vùng tai thỏ).
        return attributes
    }

    private static func labelStyle(font: UIFont, color: UIColor) -> EKProperty.LabelStyle {
        EKProperty.LabelStyle(
            font: font,
            color: EKColor(color),
            displayMode: .inferred
        )
    }
}
