//
//  HomeView.swift
//  Shiori
//
//  Created by Henrique Hida on 30/07/25.
//

import SwiftUI
import UIKit
import Foundation

struct HomeView: View {
    
    @AppStorage("signed_in") var isUserSignedIn: Bool = false
    
    @EnvironmentObject var sumRepository: SumRepository
    @StateObject private var viewModel = HomeViewModel()
    
    @State var articleUrlToSum: String = ""
    @State var textToSum: String = ""
    @State var showSumView: Bool = false
    
    @State var showSumPreferences: Bool = false
    @State var sumType: SummaryType?
    @State var toSum: String?
    
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
                    Color("BgColor")
                        .ignoresSafeArea()
                    
                    //foreground
                    if !isUserSignedIn {
                        
                    }
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
                                newsPastCards
                            }
                            streaks
                        }
                        .padding(20)
                    }
                    
                    VStack {
                        Spacer()
                        if showSumPreferences, let sumType = sumType, let toSum = toSum{
                            sumPreferencesSheet(showSumPreferences: $showSumPreferences, viewModel: viewModel, type: sumType, toSum: toSum)
                                .transition(.move(edge: .bottom))
                        }
                    }
                    .ignoresSafeArea()
                    .animation(.spring(), value: showSumPreferences)
                    
                case .loading:
                    LoadingView()
                    
                case .success(let docID, let sumType):
                    LoadingView()
                        .onAppear {
                            viewModel.documentID = docID
                            viewModel.sumType = sumType
                            showSumView = true
                        }
                        
                    
                case .error(let errorDescription):
                    Text("Error: \(errorDescription)")
                }
                if showSumView, let docID = viewModel.documentID, let sumType = viewModel.sumType {
                    NavigationLink(
                        destination: SumView(id: docID, type: sumType),
                        isActive: $showSumView
                    ) {
                        EmptyView()
                    }
                    .onDisappear {
                        viewModel.resetState()
                        showSumPreferences = false
                        showSumView = false
                        textToSum = ""
                        articleUrlToSum = ""
                    }
                }
            }
            .navigationBarTitle(Text("Shiori"), displayMode: .inline)
            .navigationBarItems(
                trailing:
                    HStack(alignment: .center, spacing: nil) {
                        Image(systemName: "line.horizontal.3")
                    }
            )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
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
        .foregroundColor(Color("PrimaryColor"))
    }
    
    var urlTextField: some View {
        HStack {
            TextField("Cole aqui sua url", text: $articleUrlToSum)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.URL)
                .accentColor(Color("PrimaryColor"))
            Button(action: {
                if articleUrlToSum != "" {
                    showSumPreferences = true
                    esconderTeclado()
                    sumType = .url
                    toSum = articleUrlToSum
                }
            }, label: {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color("PrimaryColor"))
                    .frame(width: 35, height: 35)
                    .overlay(
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                    )
            })
        }
    }
    
    var textTextEditor: some View {
        VStack {
            TextEditor(text: $textToSum)
                .frame(height: 200)
                .colorMultiply(Color(#colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)))
                .cornerRadius(5)
                .accentColor(Color("PrimaryColor"))
            
            Button(action: {
                if textToSum != "" {
                    showSumPreferences = true
                    esconderTeclado()
                    sumType = .text
                    toSum = textToSum
                }
            }, label: {
                HStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color("PrimaryColor"))
                        .frame(width: 115, height: 35)
                        .overlay(
                            HStack {
                                Text("Resumir")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                            }
                    )
                }
            })
        }
    }
    
    var newsMainCard: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("News")
                    .font(.subheadline)
                    .foregroundColor(Color("SubtitleColor"))
                Text(viewModel.dateFormatter.string(from: viewModel.today))
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PrimaryTextColor"))
                Spacer()
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("PrimaryColor"))
            }
            Spacer()
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(Color("GroupColor"))
        .cornerRadius(20)
    }
    
    var newsPastCards: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(0..<6) { i in
                        VStack {
                            Text(viewModel.dateFormatter.string(from: viewModel.getPreviousDays(numberOfDaysAgo: i) ?? viewModel.today))
                                .foregroundColor(Color("SubtitleColor"))
                        }
                        .padding(8)
                        .padding(.vertical, 5)
                        .frame(width: 90, height: 100, alignment: .bottomLeading)
                        .background(Color("GroupColor"))
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
                    .foregroundColor(Color("SubtitleColor"))
                })
            }
        }
    }
    
    var streaks: some View {
        VStack(spacing: 20) {
            Text("Sequência semanal")
                .fontWeight(.semibold)
                .foregroundColor(Color("PrimaryTextColor"))
            HStack(spacing: (UIScreen.main.bounds.width - 270) / 8) {
                ForEach(viewModel.currentWeekStreak.indices) { i in
                    if viewModel.currentWeekStreak[i] {
                        VStack {
                            Image(systemName: "flame.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("PrimaryColor"))
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
                                .foregroundColor(Color("SubtitleColor"))
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
        .background(Color("GroupColor"))
        .cornerRadius(20)
    }
    
    func esconderTeclado() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct sumPreferencesSheet: View {
    @Binding var showSumPreferences: Bool
    
    @ObservedObject var viewModel: HomeViewModel
    let type: SummaryType
    let toSum: String
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Button(action: {
                    showSumPreferences = false
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                })
                .accentColor(.primary)
            }
            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Estilo do resumo")
                    Menu {
                        Button("Informal") {
                            viewModel.sumStyle = .informal
                        }
                        .tag("Informal")
                        Button("Formal") {
                            viewModel.sumStyle = .formal
                        }
                        .tag("Formal")
                        Button("Imparcial") {
                            viewModel.sumStyle = .impartial
                        }
                        .tag("Imparcial")
                        Button("Otimista") {
                            viewModel.sumStyle = .optimistic
                        }
                        .tag("Otimista")
                        Button("Fofoca") {
                            viewModel.sumStyle = .gossip
                        }
                        .tag("Fofoca")
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1.0)
                            .overlay(
                                HStack {
                                    Text(viewModel.sumStyle.rawValue.capitalized)
                                        .foregroundColor(Color("PrimaryColor"))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .accentColor(.gray)
                                }
                                .padding(.horizontal)
                                
                            )
                    }
                    .frame(width: 300, height: 45)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Duração de leitura")
                    Menu {
                        Button("1 minuto") {
                            viewModel.sumReadTime = 1
                        }
                        .tag("1 minuto")
                        Button("3 minutos") {
                            viewModel.sumReadTime = 3
                        }
                        .tag("3 minutos")
                        Button("5 minutos") {
                            viewModel.sumReadTime = 5
                        }
                        .tag("5 minutos")
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1.0)
                            .overlay(
                                HStack {
                                    Text("\(viewModel.sumReadTime) min")
                                        .foregroundColor(Color("PrimaryColor"))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .accentColor(.gray)
                                }
                                .padding(.horizontal)
                                
                            )
                    }
                    .frame(width: 300, height: 45)
                }
                .padding(.bottom)
                
                Button(action: {
                    viewModel.summarizeContent(type: type, toSum: toSum, sumStyle: viewModel.sumStyle, readTime: viewModel.sumReadTime)
                }, label: {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 300, height: 45)
                        .foregroundColor(Color("PrimaryColor"))
                        .overlay(
                            Text("Gerar texto")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        )
                }
                )
                
                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .padding()
        .background(Color.white)
        .frame(height: 320, alignment: .bottom)
        .cornerRadius(25)
        .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5041202911)), radius: 10)
    }
}
