//
//  SumView.swift
//  Shiori
//
//  Created by Henrique Hida on 04/08/25.
//

import SwiftUI

struct SumView: View {
    
    @StateObject private var viewModel: SumViewModel
    
    init(id: UUID) {
        _viewModel = StateObject(wrappedValue: SumViewModel(id: id))
    }
    
    var body: some View {
        ZStack {
            // background
            
            // foreground
            VStack {
                ScrollView {
                    MarkdownViewer(markdownString: viewModel.currentSummary?.content ?? "Conteúdo não encontrado")
                }
            }
        }
        .navigationTitle("Data")
    }
}

struct SumView_Previews: PreviewProvider {
    static var previews: some View {
        SumView(id: UUID())
    }
}
