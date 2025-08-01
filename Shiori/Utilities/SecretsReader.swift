//
//  SecretsReader.swift
//  Shiori
//
//  Created by Henrique Hida on 01/08/25.
//

import Foundation

enum Config {
    static var geminiApiKey: String {
        guard let gemini_key = Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String else {
            fatalError("Gemini APi Key not found in Config.xcconfig")
        }
        return gemini_key
    }
}
