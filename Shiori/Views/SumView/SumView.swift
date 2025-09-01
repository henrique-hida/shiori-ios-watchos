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

    let mainColor: Color = Color.purple
    @State var playAudio: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false){
                    VStack(alignment: .leading) {
                        MarkdownLabelView(markdownString: viewModel.removeMarkdownBlockMarkers(from: viewModel.currentSummary?.content ?? ""))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                ZStack {
                    Color(#colorLiteral(red: 0.8993570181, green: 0.8993570181, blue: 0.8993570181, alpha: 1))
                        .ignoresSafeArea()
                        .frame(height: 100)
                    
                    HStack {
                        Circle()
                            .foregroundColor(mainColor)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: playAudio ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                            )
                            .onTapGesture {
                                playAudio.toggle()
                            }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 25.0)
                            .frame(width: 290, height: 10)
                            .foregroundColor(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25.0)
                                    .frame(width: 50*2.8, height: 10)
                                    .foregroundColor(mainColor)
                                    .overlay(
                                        Circle()
                                            .foregroundColor(mainColor)
                                            .frame(width: 20, height: 20)
                                            .offset(x: 15)
                                        , alignment: .trailing
                                    ), alignment: .leading
                            )
                    }
                    .padding(.horizontal)
                } .background(Color.red)
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Resumo", displayMode: .inline)
        .navigationBarItems(
            leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                })
                .accentColor(.primary),
            trailing:
                HStack(alignment: .center, spacing: nil) {
                    Image(systemName: "line.horizontal.3")
                }
        )
    }
}

struct SumView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SumView(id: "w24t5f8jnWvNPL5auDO2", type: "url")
        }
    }
}

