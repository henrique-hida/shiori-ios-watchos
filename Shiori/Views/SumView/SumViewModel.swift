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
    var sumType: String
    @Published var currentSummary: SumModel?
    
    init(id: String, sumType: String) {
        self.id = id
        self.sumType = sumType
        repository.getSum(id: id, type: sumType) { [weak self] sumModel in
            DispatchQueue.main.async {
                self?.currentSummary = sumModel
            }
        }
    }
}
