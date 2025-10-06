//
//  LoadView.swift
//  Shiori
//
//  Created by Henrique Hida on 04/08/25.
//

import SwiftUI

struct LoadingView: View {
    
    @State var message: String = "Aguarde um instante..."
    
    var body: some View {
        ZStack {
            // background
            Color("BgColor")
                .ignoresSafeArea()
            
            // foreground
            VStack {
                Spacer()
                
                VStack(spacing: 10) {
                    Image("ImgPurple")
                        .resizable()
                        .frame(width: 280, height: 75)
                    HStack(spacing: 10) {
                        Text(message)
                        ProgressView()
                            .onAppear {
                                changeText()
                            }
                    }
                }
                .foregroundColor(Color("SubtitleColor"))
                
                Spacer()
                Spacer()
            }
        }
    }
    
    private func changeText() {
        let messages: [String] = ["Seu texto está sendo resumido...", "Quase lá...", "Finalizando..."]
        var delay = 3.0
        
        if messages.isEmpty {
            self.message = "Gerando resumo..."
        } else {
            for newMessage in messages {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.message = newMessage
                }
                delay += 3.0
            }
        }
    }
    
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
