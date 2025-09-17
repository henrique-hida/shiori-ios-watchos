//
//  HomeViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 30/07/25.
//

import Foundation
import Combine

enum SumState {
    case idle
    case loading
    case success(String, String)
    case error(String)
}

class HomeViewModel: ObservableObject {
    private let repository = SumRepository()
    
    @Published var sumInputTitle: String = "Resumir notícia"
    @Published var sumStyle: SummaryStyle = .informal
    @Published var sumReadTime: Int = 5
    
    let today = Date()
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMM", options: 0, locale: Locale.current)
        return formatter
    }
    
    @Published var currentWeekStreak: [Bool] = [true, false, true, true, false, false, false]
    let weekDays: [String] = ["S", "T", "Q", "Q", "S", "S", "D"]
    
    
    @Published var state: SumState = .idle
    @Published var documentID: String?
    @Published var sumType: String?
    
    func summarizeContent(type: SummaryType, toSum: String?, sumStyle: SummaryStyle, readTime: Int) {
        self.state = .loading
        var url: String? = nil
        var text: String? = nil
        
        if type == .url {
            guard let toSum = toSum, !toSum.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, URL(string: toSum) != nil else {
                self.state = .error("Por favor, insira uma URL válida.")
                return
            }
            url = toSum
        }
        if type == .text {
            text = toSum
        }
        
        repository.generateSumText(url: url, text: text, sumStyle: sumStyle, readTime: readTime) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let summaryText):
                let sumTitle: String = self.extractTitle(from: summaryText) ?? "Título"
                
                switch type {
                case .url:
                    self.createSum(content: summaryText, title: sumTitle, type: .url, originalUrl: url, sumStyle: sumStyle, readTime: readTime) { (documentID, error) in
                        if let error = error {
                            self.state = .error("Erro: \(error)")
                        } else if let docID = documentID {
                            self.state = .success(docID, "url")
                        }
                    }
                case .text:
                    self.createSum(content: summaryText, title: sumTitle, type: .text, originalText: text, sumStyle: sumStyle, readTime: readTime) { (documentID, error) in
                        if let error = error {
                            self.state = .error("Erro: \(error)")
                        } else if let docID = documentID {
                            self.state = .success(docID, "text")
                        }
                    }
                case .news:
                    break
                }

            case .failure(let error):
                self.state = .error("Não foi possível gerar o resumo. Tente novamente. (\(error.localizedDescription))")
            }
        }
    }
    
    func createSum(content: String, title: String, type: SummaryType, originalUrl: String? = nil, originalText: String? = nil, sumStyle: SummaryStyle, readTime: Int, completion: @escaping (_ documentID: String?, _ error: Error?) -> Void) {
        repository.createSum(content: content, title: title, type: type, originalUrl: originalUrl, originalText: originalText, sumStyle: sumStyle, readTime: readTime) { documentID, error in
            completion(documentID, error)
        }
    }
    
    private func extractTitle(from markdown: String) -> String? {
        guard let titleLine = markdown.components(separatedBy: .newlines).first(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("#") }) else {
            return nil
        }
        let cleanTitle = titleLine.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespaces)
        return cleanTitle.isEmpty ? nil : cleanTitle
    }
    
    func resetState() {
        self.state = .idle
        self.documentID = nil
        self.sumType = nil
    }
    
    func getPreviousDays(numberOfDaysAgo: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: -numberOfDaysAgo, to: Date())
    }
}
