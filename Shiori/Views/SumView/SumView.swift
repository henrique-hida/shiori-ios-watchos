//
//  SumView.swift
//  Shiori
//
//  Created by Henrique Hida on 04/08/25.
//

import SwiftUI

struct SumView: View {
    
    @StateObject private var viewModel: SumViewModel

    init(id: String, type: String) {
        _viewModel = StateObject(wrappedValue: SumViewModel(id: id, sumType: type))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                MarkdownLabelView(markdownString: viewModel.currentSummary?.content ?? "")
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Data")
    }
}

struct SumView_Previews: PreviewProvider {
    static var previews: some View {
        SumView(id: "uh0iILS1REC6o0VTzKWN", type: "url")
    }
}

