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
    case success(String)
    case error(String)
}

class HomeViewModel: ObservableObject {
    private let repository = SumRepository()
    
    @Published var sumInputTitle: String = "Resumir notícia"
    @Published var articleUrlToSum: String = ""
    @Published var textToSum: String = ""
    
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
    
    func summarizeUrl(for url: String) {
        let trimmedUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUrl.isEmpty, URL(string: trimmedUrl) != nil else {
            self.state = .error("Por favor, insira uma URL válida.")
            return
        }
        self.state = .loading
        repository.generateSumText(for: trimmedUrl) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let summaryText):
                self.state = .success(summaryText)
                
            case .failure(let error):
                self.state = .error("Não foi possível gerar o resumo. Tente novamente. (\(error.localizedDescription))")
            }
        }
    }
    
    func resetState() {
        self.state = .idle
    }
    
    func getPreviousDays(numberOfDaysAgo: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: -numberOfDaysAgo, to: Date())
    }
    
    func createSum(content: String, originalUrl: String) -> UUID {
        let newSumId = repository.createSum(content: content, originalUrl: originalUrl)
        return newSumId
    }
    
}
