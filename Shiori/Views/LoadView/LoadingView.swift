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
            
            // foreground
            VStack {
                Spacer()
                
                VStack(spacing: 10) {
                    Text("Shiori")
                        .font(.system(size: 70))
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    HStack(spacing: 10) {
                        Text(message)
                        ProgressView()
                            .onAppear {
                                changeText()
                            }
                    }
                }
                .foregroundColor(.secondary)
                
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
