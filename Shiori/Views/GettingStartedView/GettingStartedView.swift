//
//  GettingStartedView.swift
//  Shiori
//
//  Created by Henrique Hida on 23/09/25.
//

import SwiftUI

struct GettingStartedView: View {
    
    @State var showSignInView: Bool = false
    @State var showSignUpView: Bool = false
    
    var body: some View {
        ZStack {
            // background
            
            //foreground
            VStack {
                VStack(alignment: .leading) {
                    Text("Bem-vindo!")
                        .foregroundColor(.purple)
                        .fontWeight(.semibold)
                        .font(.system(size: 50))
                    
                    Text("Entre ou cadastre-se")
                        .foregroundColor(.purple)
                        .font(.title3)
                    
                    Spacer()
                    Spacer()
                    
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            showSignInView = true
                        }, label: {
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(Color.purple, lineWidth: 2.0)
                                .frame(width: 300, height: 50)
                                .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)))
                                .overlay(
                                    Text("Entrar")
                                        .foregroundColor(.purple)
                                        .fontWeight(.semibold)
                                )
                        })
                        
                        Button(action: {
                            showSignUpView = true
                        }, label: {
                            Capsule()
                                .frame(width: 300, height: 50)
                                .foregroundColor(.purple)
                                .overlay(
                                    Text("Cadastrar-se")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                )
                        })
                    }
                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    Text("Ou cadastre-se com")
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 20) {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.purple)
                        
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.purple)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)
        }
        .sheet(isPresented: $showSignInView, content: {
            SignInView()
        })
        .sheet(isPresented: $showSignUpView, content: {
            SignUpView()
        })
    }
}

struct GettingStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GettingStartedView()
    }
}
