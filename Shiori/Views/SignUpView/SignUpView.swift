//
//  SignUpView.swift
//  Shiori
//
//  Created by Henrique Hida on 23/09/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel = SignUpViewModel()
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmedPasswordVisible: Bool = false
    
    var body: some View {
        ZStack {
            // background
            Color("BgColor")
                .ignoresSafeArea()
            
            //foreground
            VStack {
                Spacer()
                
                Text("Crie sua conta")
                    .foregroundColor(Color("PrimaryColor"))
                    .fontWeight(.semibold)
                    .font(.system(size: 50))
                
                Spacer()
                
                VStack(spacing: 50) {
                    VStack(spacing: 20) {
                        if viewModel.errorMessage != "" {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.red)
                                .frame(width: .infinity, height: 50)
                                .overlay(
                                    Text(viewModel.errorMessage)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                )
                        }
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 20)
                            
                            TextField("Nome completo", text: $viewModel.name)
                                .accentColor(Color("PrimaryColor"))
                            
                        }
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(viewModel.focusName ? Color.red : Color("PrimaryColor"))
                                .frame(width: .infinity, height: 1),
                            alignment: .bottom
                        )
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 20)
                            
                            TextField("E-mail", text: $viewModel.email)
                                .accentColor(Color("PrimaryColor"))
                            
                        }
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(viewModel.focusEmail ? Color.red : Color("PrimaryColor"))
                                .frame(width: .infinity, height: 1),
                            alignment: .bottom
                        )
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 20)
                            
                            Group {
                                if isPasswordVisible {
                                    TextField("Senha", text: $viewModel.password)
                                } else {
                                    SecureField("Senha", text: $viewModel.password)
                                }
                            }
                            .accentColor(Color("PrimaryColor"))
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(viewModel.focusPassword ? Color.red : Color("PrimaryColor"))
                                .frame(width: .infinity, height: 1),
                            alignment: .bottom
                        )
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 20)
                            
                            Group {
                                if isConfirmedPasswordVisible {
                                    TextField("Confirme a senha", text: $viewModel.confirmedPassword)
                                } else {
                                    SecureField("Confirme a senha", text: $viewModel.confirmedPassword)
                                }
                            }
                            .accentColor(Color("PrimaryColor"))
                            
                            Button(action: {
                                isConfirmedPasswordVisible.toggle()
                            }) {
                                Image(systemName: isConfirmedPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(viewModel.focusConfirmedPassword ? Color.red : Color("PrimaryColor"))
                                .frame(width: .infinity, height: 1),
                            alignment: .bottom
                        )
                    }
                    Button(action: {
                        viewModel.createUser()
                    }, label: {
                        Capsule()
                            .frame(width: .infinity, height: 50)
                            .foregroundColor(Color("PrimaryColor"))
                            .overlay(
                                Text("Cadastrar-se")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            )
                        
                    })
                }
                
                Spacer()
            }
            .padding()
        }
        .onChange(of: viewModel.navigateToHome) { newValue in
            if newValue {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
