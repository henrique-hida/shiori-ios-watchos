//
//  TTSService.swift
//  Shiori
//
//  Created by Henrique Hida on 01/09/25.
//

import Foundation
import AVFoundation
import Combine

class TTSService: NSObject, AVSpeechSynthesizerDelegate {
    
    private let synthesizer = AVSpeechSynthesizer()
    
    let progressPublisher = PassthroughSubject<Double, Never>()
    let didFinishPublisher = PassthroughSubject<Void, Never>()
    
    private var currentText: String = ""
    private var characterOffset: Int = 0
    private var speechRate: Float = AVSpeechUtteranceDefaultSpeechRate
    
    override init() {
        super.init()
        synthesizer.delegate = self
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("❌ Falha ao configurar a AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    func estimateDuration(for text: String) -> TimeInterval {
        let normalWordsPerMinute = 180.0
        let defaultRate = Double(AVSpeechUtteranceDefaultSpeechRate)
        guard defaultRate > 0 else { return 0 }
        
        let adjustedWordsPerMinute = normalWordsPerMinute * (Double(self.speechRate) / defaultRate)
        
        let words = text.split { !$0.isLetter && !$0.isNumber }.count
        
        if adjustedWordsPerMinute > 0 {
            let minutes = Double(words) / adjustedWordsPerMinute
            return minutes * 60
        }
        return 0
    }
    
    func setSpeechRate(rate: Float) {
        self.speechRate = max(AVSpeechUtteranceMinimumSpeechRate, min(AVSpeechUtteranceMaximumSpeechRate, rate))
    }
    
    func speak(text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        self.currentText = text
        self.characterOffset = 0
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.languageCode ?? "pt-BR")
        utterance.rate = self.speechRate
        utterance.pitchMultiplier = 1.0
    
        synthesizer.speak(utterance)
    }
    
    func seek(to percentage: Double) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let clampedPercentage = max(0.0, min(1.0, percentage))
        
        let totalLength = (currentText as NSString).length
        let charIndex = Int(Double(totalLength) * clampedPercentage)
        
        self.characterOffset = charIndex
        
        let suffixText = (currentText as NSString).substring(from: charIndex)
        
        let utterance = AVSpeechUtterance(string: suffixText)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.languageCode ?? "pt-BR")
        utterance.rate = self.speechRate
        utterance.pitchMultiplier = 1.0
        
        synthesizer.speak(utterance)
    }
    
    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
        }
    }
    
    func resume() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        }
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let totalLength = Double((currentText as NSString).length)
        if totalLength > 0 {
            let absoluteLocation = self.characterOffset + characterRange.location
            let progress = Double(absoluteLocation) / totalLength
            progressPublisher.send(progress)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let totalLength = Double((currentText as NSString).length)
        guard totalLength > 0 else {
            didFinishPublisher.send()
            return
        }
        let spokenLength = (utterance.speechString as NSString).length
        
        let finalProgress = Double(self.characterOffset + spokenLength) / totalLength
        if finalProgress >= 0.99 {
            didFinishPublisher.send()
        }
    }
}
