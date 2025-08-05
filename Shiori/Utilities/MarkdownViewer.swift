//
//  MardownReader.swift
//  Shiori
//
//  Created by Henrique Hida on 05/08/25.
//

import SwiftUI
import UIKit
import SwiftyMarkdown

struct MarkdownViewer: UIViewRepresentable {
    let markdownString: String
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        let swiftyMarkdown = SwiftyMarkdown(string: markdownString)
        
        swiftyMarkdown.h1.fontName = "AvenirNextCondensed-Bold"
        swiftyMarkdown.h1.fontSize = 24
        swiftyMarkdown.bold.color = .blue
        swiftyMarkdown.italic.color = .darkGray
        
        let attributedString = swiftyMarkdown.attributedString()
        
        uiView.attributedText = attributedString
    }
}
