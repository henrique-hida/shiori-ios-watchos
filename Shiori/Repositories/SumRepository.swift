//
//  SumRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 01/08/25.
//

import Foundation

class SumRepository {
    private let apiService = AIService()

    func getSum(for url: String, completion: @escaping (Result<String, Error>) -> Void) {
        apiService.fetchSummary(for: url, completion: completion)
    }
}
