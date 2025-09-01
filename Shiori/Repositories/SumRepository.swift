//
//  SumRepository.swift
//  Shiori
//
//  Created by Henrique Hida on 01/08/25.
//

import Foundation
import Combine
import FirebaseFirestore

class SumRepository: ObservableObject {
    
    private let apiService = AIService()
    private let db = Firestore.firestore()
    
    let user: String = "João"
    

    func generateSumText(url: String?, text: String?, completion: @escaping (Result<String, Error>) -> Void) {
        apiService.fetchSummary(for: url, for: text, completion: completion)
    }
    
    func createSum(content: String, title: String, type: SummaryType, originalUrl: String? = nil, originalText: String? = nil, completion: @escaping (_ documentID: String?, _ error: Error?) -> Void) {
        let newSum = SumModel.init(title: title, content: content, type: type, originalUrl: originalUrl, originalText: originalText)
        let docRef = db.collection("users").document(user).collection(newSum.type.rawValue).document()
        do {
            try docRef.setData(from: newSum) { error in
                if let error = error {
                    print("Erro ao salvar o resumo no Firestore: \(error.localizedDescription)")
                    completion(nil, error)
                } else {
                    print("Resumo salvo com sucesso! ID: \(docRef.documentID)")
                    completion(docRef.documentID, nil)
                }
            }
        } catch {
            print("Erro ao codificar o objeto SumModel: \(error.localizedDescription)")
            completion(nil, error)
        }
    }
    
    func getSum(id: String, type: String, completion: @escaping (SumModel?) -> Void) {
        let docRef = db.collection("users").document(user).collection(type).document(id)
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Erro ao buscar documento: \(error)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil)
                return
            }
            
            do {
                let data = try document.data(as: SumModel.self)
                completion(data)
            } catch {
                print("Erro na decodificação: \(error)")
                completion(nil)
            }
        }
    }
    
}
