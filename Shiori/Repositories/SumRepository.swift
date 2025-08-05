//
//  SumRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 01/08/25.
//

import Foundation
import Combine

class SumRepository: ObservableObject {
    @Published var allSummaries: [SumModel] = []
    
    private let apiService = AIService()

    func generateSumText(for url: String, completion: @escaping (Result<String, Error>) -> Void) {
        apiService.fetchSummary(for: url, completion: completion)
    }
    
    func createSum(content: String, originalUrl: String) -> UUID {
        let newSum = SumModel.init(title: "Título", content: content, wasRead: false, originalUrl: originalUrl)
        allSummaries.append(newSum)
        return newSum.id
    }
    
    func getSum(id: UUID) -> SumModel? {
        for summary in allSummaries {
            if summary.id == id {
                return summary
            }
        }
        return nil
    }
    
}
