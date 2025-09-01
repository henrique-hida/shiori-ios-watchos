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
    
    func summarizeContent(type: SummaryType, url: String? = nil, text: String? = nil) {
        self.state = .loading
        
        if type == .url {
            guard let url = url, !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, URL(string: url) != nil else {
                self.state = .error("Por favor, insira uma URL válida.")
                return
            }
        }
        repository.generateSumText(url: url, text: text) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let summaryText):
                switch type {
                case .url:
                    self.createSum(content: summaryText, type: .url, originalUrl: url) { (documentID, error) in
                        if let error = error {
                            self.state = .error("Erro: \(error)")
                        } else if let docID = documentID {
                            self.state = .success(docID, "url")
                        }
                    }
                case .text:
                    self.createSum(content: summaryText, type: .text, originalText: text) { (documentID, error) in
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
    
    func createSum(content: String, type: SummaryType, originalUrl: String? = nil, originalText: String? = nil, completion: @escaping (_ documentID: String?, _ error: Error?) -> Void) {
        repository.createSum(content: content, type: type, originalUrl: originalUrl, originalText: originalText) { documentID, error in
            completion(documentID, error)
        }
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
