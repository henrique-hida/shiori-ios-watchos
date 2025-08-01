//
//  AIService.swift
//  Shiori
//
//  Created by Henrique Hida on 01/08/25.
//

import Foundation

struct GeminiRequest: Codable {
    let contents: [Content]
    
    struct Content: Codable {
        let parts: [Part]
    }
    
    struct Part: Codable {
        let text: String
    }
}

struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    
    struct Candidate: Codable {
        let content: Content?
    }
    
    struct Content: Codable {
        let parts: [Part]?
    }
    
    struct Part: Codable {
        let text: String
    }
}

class AIService {
    
    enum AIServiceError: Error {
        case failedToCreateURL
        case failedToCreateRequestBody
        case requestFailed(Error)
        case invalidResponse
        case decodingFailed(Error)
        case noSummaryFound
        case dataIsNil
    }
    
    func fetchSummary(for articleUrl: String, completion: @escaping (Result<String, Error>) -> Void) {
        let apiKey = Config.geminiApiKey
        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(AIServiceError.failedToCreateURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-goog-api-key")
        
        let prompt = "Por favor, resuma o artigo encontrado nesta URL em um parágrafo conciso: \(articleUrl)"
        let requestBody = GeminiRequest(contents: [.init(parts: [.init(text: prompt)])])
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(AIServiceError.failedToCreateRequestBody))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(AIServiceError.invalidResponse))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(AIServiceError.dataIsNil))
                    return
                }
                
                do {
                    let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                    
                    if let summary = geminiResponse.candidates?.first?.content?.parts?.first?.text {
                        completion(.success(summary))
                    } else {
                        completion(.failure(AIServiceError.noSummaryFound))
                    }
                } catch {
                    completion(.failure(AIServiceError.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
}
