//
//  MardownReader.swift
//  Shiori
//
//  Created by Henrique Hida on 05/08/25.
//

import SwiftUI
import UIKit
import SwiftyMarkdown

final class WrappingLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        if preferredMaxLayoutWidth != bounds.width {
            preferredMaxLayoutWidth = bounds.width
            setNeedsLayout()
        }
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: UIView.noIntrinsicMetric, height: s.height)
    }
}

struct MarkdownLabelView: UIViewRepresentable {
    let markdownString: String

    func makeUIView(context: Context) -> WrappingLabel {
        let label = WrappingLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    func updateUIView(_ uiView: WrappingLabel, context: Context) {
        let processed = insertSoftBreaks(in: markdownString, every: 20, threshold: 80)
        let md = SwiftyMarkdown(string: processed)
        
        md.h1.fontName = "H1_PLACEHOLDER"
        md.h1.fontSize = 24

        md.bold.fontName = "BOLD_PLACEHOLDER"
        md.bold.fontSize = 17

        md.italic.color = .darkGray

        let attr = NSMutableAttributedString(attributedString: md.attributedString())
        let fullRange = NSRange(location: 0, length: attr.length)
        attr.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
            guard let currentFont = value as? UIFont else { return }

            var replacementFont: UIFont?
            if currentFont.fontName.contains("H1_PLACEHOLDER") {
                replacementFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            } else if currentFont.fontName.contains("BOLD_PLACEHOLDER") {
                replacementFont = UIFont.systemFont(ofSize: 17, weight: .bold)
            }

            if let correctFont = replacementFont {
                attr.removeAttribute(.font, range: range)
                attr.addAttribute(.font, value: correctFont, range: range)
            }
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        attr.addAttribute(.paragraphStyle, value: paragraph, range: fullRange)

        uiView.attributedText = attr

        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
    }

    private func insertSoftBreaks(in text: String, every n: Int, threshold: Int) -> String {
        return text
            .split(separator: " ", omittingEmptySubsequences: false)
            .map { word -> String in
                let s = String(word)
                guard s.count > threshold else { return s }
                var out = ""
                var i = 0
                for ch in s {
                    if i != 0 && i % n == 0 { out.append("\u{200B}") }
                    out.append(ch)
                    i += 1
                }
                return out
            }
            .joined(separator: " ")
    }
}
