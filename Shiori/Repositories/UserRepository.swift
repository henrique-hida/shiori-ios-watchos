//
//  UserRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 19/10/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserRepository: ObservableObject {
    private let db = Firestore.firestore()
    
    func createUser(email: String, password: String, name: String, completion: @escaping (Result<AuthUserModel, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                completion(.failure(error))
                print("Erro ao cadastrar usuário: \(error.localizedDescription)")
                return
            }
            guard let result = authResult else { return }
            let user = AuthUserModel(user: result.user)
            
            let docRef = self.db.collection("users").document(user.uid)
            docRef.setData(["user_name": name]) { error in
                if let error = error {
                    print("Erro ao mesclar dados: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("Dados mesclados com sucesso!")
                    completion(.success(user))
                }
            }
        }
    }
    
    func signInUser(email: String, password: String, completion: @escaping (Result<AuthUserModel, Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                completion(.failure(error))
                print("Erro ao fazer login: \(error.localizedDescription)")
                return
            }
            if let result = authResult {
                let user = AuthUserModel(user: result.user)
                completion(.success(user))
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Erro ao fazer logout: %@", signOutError)
        }
    }
    
    func getUserUID() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        } else {
            print("Nenhum usuário conectado.")
            return nil
        }
    }
}
