//
//  SumViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 04/08/25.
//

import Foundation

class SumViewModel: ObservableObject {
    private let repository = SumRepository()
    
    var id: String
    @Published var currentSummary: SumModel?
    
    init(id: String, type: SummaryType) {
        self.id = id
        repository.getSum(id: id, type: type.rawValue) { [weak self] sumModel in
            DispatchQueue.main.async {
                self?.currentSummary = sumModel
            }
        }
    }
}
