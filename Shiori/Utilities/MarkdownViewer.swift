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
        md.h1.fontName = ""
        md.h1.fontSize = 24
        md.bold.color = .purple
        md.italic.color = .darkGray

        let attr = NSMutableAttributedString(attributedString: md.attributedString())
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        attr.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attr.length))

        uiView.attributedText = attr

        uiView.preferredMaxLayoutWidth = uiView.bounds.width
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
