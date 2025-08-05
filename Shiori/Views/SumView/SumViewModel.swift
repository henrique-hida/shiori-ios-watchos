//
//  SumViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 04/08/25.
//

import Foundation

class SumViewModel: ObservableObject {
    private let repository = SumRepository()
    
    var id: UUID
    @Published var currentSummary: SumModel?
    
    init(id: UUID) {
        self.id = id
        self.currentSummary = repository.getSum(id: id)
    }
}
