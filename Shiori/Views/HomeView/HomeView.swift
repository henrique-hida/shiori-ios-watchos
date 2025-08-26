//
//  HomeView.swift
//  Shiori
//
//  Created by Henrique Hida on 30/07/25.
//

import SwiftUI
import Foundation

struct HomeView: View {
    
    @EnvironmentObject var sumRepository: SumRepository
    @StateObject private var viewModel = HomeViewModel()
    
    let mainColor: Color = Color.purple
    
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
                switch viewModel.state {
                case .idle:
                    //background
                    
                    //foreground
                    ScrollView {
                        VStack(spacing: 20) {
                            VStack(spacing: 10) {
                                sumInputLabel
                                if viewModel.sumInputTitle == "Resumir notícia" {
                                    urlTextField
                                } else {
                                    textTextEditor
                                }
                            }
                            VStack(spacing: 10) {
                                newsMainCard
                                newsPastCard
                            }
                            streaks
                        }
                        .padding(20)
                    }
                    
                case .loading:
                    LoadingView()
                    
                case .success(let summaryText):
                    let sumId = viewModel.createSum(content: summaryText, originalUrl: viewModel.articleUrlToSum)
                    SumView(id: sumId)
                    
                case .error(let errorDescription):
                    Text("Error: \(errorDescription)")
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
    
    var sumInputLabel: some View {
        HStack {
            Text(viewModel.sumInputTitle)
                .font(.title)
                .fontWeight(.semibold)
            Menu {
                Button("Resumir notícia") {
                    viewModel.sumInputTitle = "Resumir notícia"
                }
                .tag("Resumir notícia")
                Button("Resumir texto") {
                    viewModel.sumInputTitle = "Resumir texto"
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
            TextField("Cole aqui sua url", text: $viewModel.articleUrlToSum)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accentColor(mainColor)
            Button(action: {
                viewModel.summarizeUrl(for: viewModel.articleUrlToSum)
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
        TextEditor(text: $viewModel.textToSum)
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
                Text(viewModel.dateFormatter.string(from: viewModel.today))
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
                            Text(viewModel.dateFormatter.string(from: viewModel.getPreviousDays(numberOfDaysAgo: i) ?? viewModel.today))
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
                ForEach(viewModel.currentWeekStreak.indices) { i in
                    if viewModel.currentWeekStreak[i] {
                        VStack {
                            Image(systemName: "flame.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(mainColor)
                            Text(viewModel.weekDays[i])
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
                            Text(viewModel.weekDays[i])
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
