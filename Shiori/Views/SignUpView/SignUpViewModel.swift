//
//  SignUpViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 23/09/25.
//

import Foundation
import SwiftUI

class SignUpViewModel: ObservableObject {
    @AppStorage("signed_in") var isUserSignedIn: Bool = false
    
    private let repository = UserRepository()
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmedPassword: String = ""
    
    @Published var focusName: Bool = false
    @Published var focusEmail: Bool = false
    @Published var focusPassword: Bool = false
    @Published var focusConfirmedPassword: Bool = false
    @Published var errorMessage: String = ""

    @Published var navigateToHome: Bool = false
    
    func createUser() {
        resetFocusState()
        
        if name == "" {
            focusName = true
            errorMessage = "Preencha o campo: Nome"
            return
        }
        if (email == "" || !email.isValidEmail()) {
            focusEmail = true
            errorMessage = "Preencha o campo: E-mail"
            return
        }
        if (password == "" || !password.isValidPassword()) {
            focusPassword = true
            errorMessage = "Preencha o campo: Senha"
            return
        }
        if confirmedPassword == "" {
            focusConfirmedPassword = true
            errorMessage = "Preencha o campo: Confirme a senha"
            return
        }
        
        if password != confirmedPassword {
            focusPassword = true
            focusConfirmedPassword = true
            errorMessage = "As senhas não coindicem"
            return
        }
        
        repository.createUser(email: email, password: password, name: name) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.isUserSignedIn = true
                    self.navigateToHome = true
                }
            case .failure(let error):
                print("Erro ao criar usuário: \(error.localizedDescription)")
            }
        }
    }
    
    private func resetFocusState() {
        errorMessage = ""
        focusName = false
        focusEmail = false
        focusPassword = false
        focusConfirmedPassword = false
    }
}

extension String {
    func isValidEmail() -> Bool {
        let viewModel = SignUpViewModel()
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValid: Bool = emailPred.evaluate(with: self)
        if !isValid {
            viewModel.errorMessage = "E-mail inválido"
        }
        return isValid
    }
    
    func isValidPassword() -> Bool {
        let viewModel = SignUpViewModel()
        
        if self.count < 8 {
            viewModel.errorMessage = "A senha deve conter pelo menos 8 caracteres"
            return false
        }
        if self.rangeOfCharacter(from: .uppercaseLetters) == nil {
            viewModel.errorMessage = "A senha deve conter pelo menos 1 letra maiúscula"
            return false
        }
        if self.rangeOfCharacter(from: .lowercaseLetters) == nil {
            viewModel.errorMessage = "A senha deve conter pelo menos 1 letra minúscula"
            return false
        }
        if self.rangeOfCharacter(from: .decimalDigits) == nil {
            viewModel.errorMessage = "A senha deve conter pelo menos 1 dígito"
            return false
        }
        if self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil {
            viewModel.errorMessage = "A senha deve conter pelo menos 1 caractere especial"
            return false
        }
        return true
    }
}
