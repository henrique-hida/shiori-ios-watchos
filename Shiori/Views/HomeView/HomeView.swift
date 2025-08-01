//
//  HomeView.swift
//  Shiori
//
//  Created by Henrique Hida on 30/07/25.
//

import SwiftUI
import Foundation

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var sumInputTitle: String = "Resumir notícia"
    @State private var sumContent: String = ""
    
    let today = Date()
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMM", options: 0, locale: Locale.current)
        return formatter
    }
    
    let mainColor: Color = Color.purple
    
    @State private var currentWeekStreak: [Bool] = [true, false, true, true, false, false, false]
    private let weekDays: [String] = ["S", "T", "Q", "Q", "S", "S", "D"]
    
    
    init() {
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithTransparentBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                //background
                
                //foreground
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 10) {
                            sumInputLabel
                            if sumInputTitle == "Resumir notícia" {
                                urlTextField
                            } else {
                                textTextEditor
                            }
                        }
                        resultsView
                        VStack(spacing: 10) {
                            newsMainCard
                            newsPastCard
                        }
                        streaks
                    }
                    .padding(20)
                }
            }
            .navigationBarTitle(
                Text("Shiori"), displayMode: .inline)
            .navigationBarItems(
                trailing:
                    HStack(alignment: .center, spacing: nil) {
                        Image(systemName: "gear")
                    }
            )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

//MARK: COMPONENTS
extension HomeView {
    @ViewBuilder
        var resultsView: some View {
            switch viewModel.state {
                
            case .idle:
                EmptyView()
                
            case .loading:
                VStack {
                    ProgressView()
                    Text("Resumindo...")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding()
                
            case .success(let summaryText):
                VStack(alignment: .leading, spacing: 10) {
                    Text("Resumo Gerado")
                        .font(.headline)
                        .foregroundColor(mainColor)
                    Text(summaryText)
                        .font(.body)
                    Button("Fazer novo resumo") {
                        viewModel.resetState()
                        sumContent = ""
                    }
                    .padding(.top, 5)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
            case .error(let errorMessage):
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ocorreu um Erro")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.body)
                    Button("Tentar Novamente") {
                        viewModel.resetState()
                    }
                    .padding(.top, 5)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            }
        }
    
    var sumInputLabel: some View {
        HStack {
            Text(sumInputTitle)
                .font(.title)
                .fontWeight(.semibold)
            Menu {
                Button("Resumir notícia") {
                    sumInputTitle = "Resumir notícia"
                }
                .tag("Resumir notícia")
                Button("Resumir texto") {
                    sumInputTitle = "Resumir texto"
                }
                .tag("Resumir texto")
            } label: {
                Image(systemName: "chevron.down")
                    .font(Font.title2.weight(.semibold))
            }
        }
        .foregroundColor(mainColor)
    }
    
    var urlTextField: some View {
        HStack {
            TextField("Cole aqui sua url", text: $sumContent)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accentColor(mainColor)
            Button(action: {
                viewModel.summarizeButtonTapped(for: sumContent)
            }, label: {
                RoundedRectangle(cornerRadius: 5)
                    .fill(mainColor)
                    .frame(width: 35, height: 35)
                    .overlay(
                        Image(systemName: "pencil")
                            .font(Font.title3.weight(.semibold))
                            .foregroundColor(.white)
                    )
            })
        }
    }
    
    var textTextEditor: some View {
        TextEditor(text: $sumContent)
            .frame(height: 200)
            .colorMultiply(Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)))
            .cornerRadius(5)
            .accentColor(mainColor)
    }
    
    var newsMainCard: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("News")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
                Text(dateFormatter.string(from: today))
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(mainColor)
            }
            Spacer()
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(20)
    }
    
    var newsPastCard: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(0..<6) { i in
                        VStack {
                            Text(dateFormatter.string(from: getPreviousDays(numberOfDaysAgo: i) ?? today))
                        }
                        .padding(8)
                        .padding(.vertical, 5)
                        .frame(width: 90, height: 100, alignment: .bottomLeading)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
            }
            HStack {
                Spacer()
                Button(action: {
                    
                }, label: {
                    HStack {
                        Text("Ver mais")
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(mainColor)
                })
            }
        }
    }
    
    var streaks: some View {
        VStack(spacing: 20) {
            Text("Sequência semanal")
                .fontWeight(.semibold)
            HStack(spacing: (UIScreen.main.bounds.width - 270) / 8) {
                ForEach(currentWeekStreak.indices) { i in
                    if currentWeekStreak[i] {
                        VStack {
                            Image(systemName: "flame.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(mainColor)
                            Text(weekDays[i])
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        VStack {
                            Image(systemName: "flame")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.secondary)
                            Text(weekDays[i])
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(20)
    }
}

//MARK: FUNCTIONS
func getPreviousDays(numberOfDaysAgo: Int) -> Date? {
    return Calendar.current.date(byAdding: .day, value: -numberOfDaysAgo, to: Date())
}
