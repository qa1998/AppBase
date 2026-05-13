//
//  TeleprompterScrollController.swift
//  AppBase
//

import UIKit

/// Cuộn mượt tới vị trí đang đọc, căn khoảng giữa viewport (không dùng scrollRangeToVisible).
final class TeleprompterScrollController {

    private weak var textView: UITextView?

    /// Hệ số làm mịn mỗi frame (0...1). Càng nhỏ càng mượt, chậm hơn.
    var smoothing: CGFloat = 0.14

    /// Dịch thêm khi căn giữa (âm = lên trên).
    var verticalCenterBias: CGFloat = 0

    /// Nhân thêm bias theo gesture / cài đặt (1 = mặc định).
    var scrollLeadFactor: CGFloat = 1.0

    private var displayLink: CADisplayLink?
    private var targetOffsetY: CGFloat = 0
    private var isRunning = false

    /// Tốc độ cuộn thủ công (gesture), nhân với delta pan.
    var gestureScrollSpeed: CGFloat = 1.0

    init(textView: UITextView) {
        self.textView = textView
    }

    deinit {
        stopDisplayLink()
    }

    func updateTargetForCharacterRange(_ range: NSRange, inTextView tv: UITextView? = nil) {
        let view = tv ?? textView
        guard let view else { return }
        guard range.length > 0 else { return }

        let glyphRange = view.layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        var rect = view.layoutManager.boundingRect(forGlyphRange: glyphRange, in: view.textContainer)
        rect.origin.x += view.textContainerInset.left
        rect.origin.y += view.textContainerInset.top

        let visibleH = view.bounds.height - view.adjustedContentInset.top - view.adjustedContentInset.bottom
        let midY = rect.midY
        let lead = (scrollLeadFactor - 1) * 80
        let desiredTop = midY - visibleH * 0.5 + verticalCenterBias + lead

        let maxY = max(0, view.contentSize.height + view.adjustedContentInset.bottom - view.bounds.height)
        let minY = -view.adjustedContentInset.top
        targetOffsetY = min(maxY, max(minY, desiredTop))
        startDisplayLinkIfNeeded()
    }

    func nudgeTargetOffset(by deltaY: CGFloat) {
        guard let view = textView else { return }
        targetOffsetY += deltaY * gestureScrollSpeed
        let maxY = max(0, view.contentSize.height + view.adjustedContentInset.bottom - view.bounds.height)
        let minY = -view.adjustedContentInset.top
        targetOffsetY = min(maxY, max(minY, targetOffsetY))
        startDisplayLinkIfNeeded()
    }

    func snapToCurrentOffset() {
        guard let view = textView else { return }
        targetOffsetY = view.contentOffset.y
    }

    private func startDisplayLinkIfNeeded() {
        guard displayLink == nil else { return }
        isRunning = true
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        isRunning = false
    }

    @objc private func tick() {
        guard let view = textView else {
            stopDisplayLink()
            return
        }
        let current = view.contentOffset.y
        let delta = targetOffsetY - current
        if abs(delta) < 0.35 {
            view.setContentOffset(
                CGPoint(
                    x: view.contentOffset.x,
                    y: targetOffsetY
                ),
                animated: false
            )
            stopDisplayLink()
            return
        }
        view.setContentOffset(
            CGPoint(
                x: view.contentOffset.x,
                y: current + delta * smoothing
            ),
            animated: false
        )
    }
}
