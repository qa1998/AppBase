//
//  HighlightManager.swift
//

import UIKit

final class HighlightManager {

    private weak var textView: UITextView?
    private var currentRange: NSRange?
    private var readEndUTF16 = 0
    private var fontSize: CGFloat = 34
    private let paragraphStyle = NSMutableParagraphStyle()
    private var sharedFont: UIFont {
        UIFont.systemFont(
            ofSize: fontSize,
            weight: .regular
        )
    }

    init(textView: UITextView) {
        self.textView = textView
        paragraphStyle.lineSpacing = 22
        paragraphStyle.paragraphSpacing = 28
        paragraphStyle.alignment = .left
    }

    func reset(
        fullText: String,
        fontSize: CGFloat = 34
    ) {

        guard let tv = textView else {
            return
        }

        self.fontSize = fontSize
        currentRange = nil
        readEndUTF16 = 0

        tv.attributedText =
            NSAttributedString(
                string: fullText,
                attributes: futureAttributes
            )

        tv.backgroundColor =
            ThemeManager.shared.colors.teleprompterBackground
        tv.isScrollEnabled = true
        tv.isEditable = false
        tv.isSelectable = false
        tv.showsVerticalScrollIndicator = false
        tv.textContainerInset = UIEdgeInsets(
            top: 140,
            left: 28,
            bottom: 220,
            right: 28
        )
        tv.textContainer.lineFragmentPadding = 0
        tv.layoutIfNeeded()
        tv.setContentOffset(
            .zero,
            animated: false
        )
    }

    func updateCurrentRange(_ range: NSRange) {

        guard let tv = textView else {
            return
        }

        let length =
            tv.textStorage.length

        guard length > 0 else {
            return
        }

        let clipped =
            range.clamped(
                toLength: length
            )

        guard clipped.length > 0,
              currentRange != clipped
        else {
            return
        }

        let storage =
            tv.textStorage

        storage.beginEditing()

        if let currentRange {

            storage.setAttributes(
                readAttributes,
                range: currentRange.clamped(
                    toLength: length
                )
            )
        }

        if clipped.location > readEndUTF16 {

            storage.setAttributes(
                readAttributes,
                range:
                    NSRange(
                        location: readEndUTF16,
                        length: clipped.location - readEndUTF16
                    ).clamped(
                        toLength: length
                    )
            )
        }

        storage.setAttributes(
            currentAttributes,
            range: clipped
        )

        storage.endEditing()

        currentRange = clipped
        readEndUTF16 =
            max(
                readEndUTF16,
                clipped.location
            )
    }

    func applyStaticProgress(upTo utf16Offset: Int) {

        guard let tv = textView else {
            return
        }

        let length =
            tv.textStorage.length

        guard length > 0 else {
            return
        }

        let offset =
            max(
                0,
                min(
                    utf16Offset,
                    length
                )
            )

        let storage =
            tv.textStorage

        storage.beginEditing()

        storage.setAttributes(
            futureAttributes,
            range:
                NSRange(
                    location: 0,
                    length: length
                )
        )

        if offset > 0 {

            storage.setAttributes(
                readAttributes,
                range:
                    NSRange(
                        location: 0,
                        length: offset
                    )
            )
        }

        storage.endEditing()

        readEndUTF16 = offset
        currentRange = nil
    }

    func refreshAttributesKeepingRanges(fontSize: CGFloat) {

        self.fontSize = fontSize

        guard let tv = textView else {
            return
        }

        let length =
            tv.textStorage.length

        guard length > 0 else {
            return
        }

        let readEnd =
            max(
                0,
                min(
                    readEndUTF16,
                    length
                )
            )

        let storage =
            tv.textStorage

        storage.beginEditing()

        storage.setAttributes(
            futureAttributes,
            range:
                NSRange(
                    location: 0,
                    length: length
                )
        )

        if readEnd > 0 {

            storage.setAttributes(
                readAttributes,
                range:
                    NSRange(
                        location: 0,
                        length: readEnd
                    )
            )
        }

        if let currentRange {

            storage.setAttributes(
                currentAttributes,
                range: currentRange.clamped(
                    toLength: length
                )
            )
        }

        storage.endEditing()
    }

    private var futureAttributes: [NSAttributedString.Key: Any] {
        let colors =
            ThemeManager.shared.colors

        return [
            .foregroundColor:
                colors.teleprompterTextFuture,
            .font:
                sharedFont,
            .paragraphStyle:
                paragraphStyle
        ]
    }

    private var readAttributes: [NSAttributedString.Key: Any] {
        let colors =
            ThemeManager.shared.colors

        return [
            .foregroundColor:
                colors.teleprompterTextRead,
            .font:
                sharedFont,
            .paragraphStyle:
                paragraphStyle
        ]
    }

    private var currentAttributes: [NSAttributedString.Key: Any] {
        let colors =
            ThemeManager.shared.colors

        return [
            .foregroundColor:
                colors.teleprompterTextCurrent,
            .font:
                sharedFont,
            .paragraphStyle:
                paragraphStyle
        ]
    }
}

private extension NSRange {

    func clamped(toLength length: Int) -> NSRange {

        let location =
            max(
                0,
                min(
                    self.location,
                    length
                )
            )

        let upper =
            max(
                location,
                min(
                    self.location + self.length,
                    length
                )
            )

        return NSRange(
            location: location,
            length: upper - location
        )
    }
}
