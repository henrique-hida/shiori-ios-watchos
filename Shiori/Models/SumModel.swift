//
//  SumModel.swift
//  Shiori
//
//  Created by Henrique Hida on 04/08/25.
//

import Foundation
import FirebaseFirestoreSwift

enum SummaryType: String, Codable {
    case news
    case url
    case text
}

struct SumModel: Identifiable, Codable {
    
    @DocumentID var id: String?
    
    // Itens para todos os tipos
    var title: String
    var content: String
    var type: SummaryType
    var createdAt: Date = Date()
    
    // Somente para resumo por url
    var originalUrl: String?
    
    // Somente para resumo por texto
    var originalText: String?
    
    // Somente para notícia diária
    var wasRead: Bool?
    
}
