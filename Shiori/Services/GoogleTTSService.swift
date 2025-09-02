//
//  GoogleTTSService.swift
//  Shiori
//
//  Created by Henrique Hida on 01/09/25.
//

import Foundation
import AVFoundation
import Combine

struct GoogleTTSRequest: Codable {
    let input: SynthesisInput
    let voice: VoiceSelectionParams
    let audioConfig: AudioConfig
}
struct SynthesisInput: Codable { let text: String }
struct VoiceSelectionParams: Codable { let languageCode: String; let name: String }
struct AudioConfig: Codable {
    let audioEncoding: String
    let speakingRate: Double
}
struct GoogleTTSResponse: Codable { let audioContent: String }


class GoogleRESTService: NSObject, AVAudioPlayerDelegate, TTSServiceProtocol {
    
    private var audioPlayer: AVAudioPlayer?
    private let apiKey: String
    private let apiURL = URL(string: "https://texttospeech.googleapis.com/v1/text:synthesize")!
    
    let didFinishPublisher = PassthroughSubject<Void, Never>()
    let progressPublisher = PassthroughSubject<PlaybackProgress, Never>()
    
    private var progressTimer: Timer?
    private var currentRate: Double = 1.0

    override init() {
        self.apiKey = Config.googleTTSApiKey
        super.init()
    }

    func speak(text: String, rate: Double, seekToProgress: Double? = nil) {
        stop()
        
        let requestBody = GoogleTTSRequest(
            input: SynthesisInput(text: text),
            voice: VoiceSelectionParams(languageCode: "pt-BR", name: "pt-BR-Wavenet-B"),
            audioConfig: AudioConfig(audioEncoding: "MP3", speakingRate: rate)
        )
        
        guard var components = URLComponents(url: apiURL, resolvingAgainstBaseURL: true) else {
            print("❌ Erro: Não foi possível criar os componentes da URL.")
            return
        }
        components.queryItems = [URLQueryItem(name: "key", value: self.apiKey)]
        guard let finalURL = components.url else {
            print("❌ Erro: URL final com a chave de API é inválida.")
            return
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("❌ Erro ao codificar o corpo da requisição: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Erro na chamada de rede: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let responseBody = String(data: data ?? Data(), encoding: .utf8) ?? "Resposta inválida"
                print("❌ Erro na resposta da API: \(responseBody)")
                return
            }
            
            guard let data = data else {
                print("❌ Não foram recebidos dados.")
                return
            }
            
            do {
                let ttsResponse = try JSONDecoder().decode(GoogleTTSResponse.self, from: data)
                guard let audioData = Data(base64Encoded: ttsResponse.audioContent) else {
                    print("❌ Falha ao decodificar o áudio Base64.")
                    return
                }
                
                DispatchQueue.main.async {
                    self.playAudio(data: audioData, seekToProgress: seekToProgress)
                }
                
            } catch {
                print("❌ Erro ao decodificar a resposta JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    private func playAudio(data: Data, seekToProgress: Double?) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            self.audioPlayer = try AVAudioPlayer(data: data)
            self.audioPlayer?.delegate = self
            
            if let progress = seekToProgress, let player = self.audioPlayer, player.duration > 0 {
                player.currentTime = player.duration * progress
            }
            
            self.audioPlayer?.play()
            self.startProgressTimer()
        } catch {
            print("❌ Erro ao tocar o áudio: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        progressTimer?.invalidate()
    }
    
    func resume() {
        audioPlayer?.play()
        startProgressTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        progressTimer?.invalidate()
    }
    
    func seek(to percentage: Double) {
        guard let player = audioPlayer, player.duration > 0 else { return }
        player.currentTime = player.duration * percentage
    }
    
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer, player.duration > 0 else { return }
            
            let progress = player.currentTime / player.duration
            let remainingTime = player.duration - player.currentTime
            
            let minutes = Int(remainingTime) / 60
            let seconds = Int(remainingTime) % 60
            let timeString = String(format: "-%02d:%02d", minutes, seconds)
            
            self.progressPublisher.send(PlaybackProgress(progress: progress, timeDisplay: timeString))
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        didFinishPublisher.send()
        progressTimer?.invalidate()
    }
}
