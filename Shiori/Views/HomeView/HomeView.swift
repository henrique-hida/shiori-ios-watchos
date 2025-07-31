//
//  HomeView.swift
//  Shiori
//
//  Created by Henrique Hida on 30/07/25.
//

import SwiftUI
import Foundation

struct HomeView: View {
    
    @State private var sumInputTitle: String = "Resumir notícia"
    @State private var sumContent: String = ""
    
    private var currentMonth: Int = Calendar.current.component(.day, from: Date())
    private var currentDay: Int = Calendar.current.component(.month, from: Date())
    private var formattedMonth: String {
        String(format: "%02d", currentMonth)
    }
    private var formattedDay: String {
        String(format: "%02d", currentDay)
    }
    private var currentDayMonth: String {
        "\(formattedDay)/\(formattedMonth)"
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
                    VStack(spacing: 30) {
                        VStack(spacing: 10) {
                            sumInputLabel
                            if sumInputTitle == "Resumir notícia" {
                                urlTextField
                            } else {
                                textTextEditor
                            }
                        }
                        newsMainCard
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
                Text(currentDayMonth)
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
    
    var streaks: some View {
        VStack(spacing: 20) {
            Text("Sequência semanal")
                .fontWeight(.semibold)
            HStack {
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
