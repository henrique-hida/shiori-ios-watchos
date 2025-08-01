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
    @Published var state: SumState = .idle
    private let repository = SumRepository()
    
    func summarizeButtonTapped(for url: String) {
        let trimmedUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUrl.isEmpty, URL(string: trimmedUrl) != nil else {
            self.state = .error("Por favor, insira uma URL válida.")
            return
        }
        self.state = .loading
        repository.getSum(for: trimmedUrl) { [weak self] result in
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
}
