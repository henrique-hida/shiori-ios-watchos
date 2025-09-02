//
//  TTSService.swift
//  Shiori
//
//  Created by Henrique Hida on 01/09/25.
//

import Foundation
import AVFoundation
import Combine

class TTSService: NSObject, AVSpeechSynthesizerDelegate, TTSServiceProtocol {
    
    private let synthesizer = AVSpeechSynthesizer()
    
    let progressPublisher = PassthroughSubject<PlaybackProgress, Never>()
    let didFinishPublisher = PassthroughSubject<Void, Never>()
    
    private var currentText: String = ""
    private var characterOffset: Int = 0
    private var speechRate: Float = AVSpeechUtteranceDefaultSpeechRate
    private var lastKnownRate: Double = 1.0
    private var estimatedTotalDuration: TimeInterval = 0
    
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
    
    func speak(text: String, rate: Double, seekToProgress: Double? = nil) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        self.lastKnownRate = rate
        self.currentText = text
        
        let textToSpeak: String
        
        if let progress = seekToProgress, progress > 0.0 && progress < 1.0 {
            let totalLength = (currentText as NSString).length
            let charIndex = Int(Double(totalLength) * progress)
            self.characterOffset = charIndex
            textToSpeak = (currentText as NSString).substring(from: charIndex)
        } else {
            self.characterOffset = 0
            textToSpeak = text
        }
        
        self.estimatedTotalDuration = estimateDuration(for: text, rate: rate)
        
        let utterance = AVSpeechUtterance(string: textToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.languageCode ?? "pt-BR")
        let nativeRate = Float(rate * 0.5)
        utterance.rate = max(AVSpeechUtteranceMinimumSpeechRate, min(AVSpeechUtteranceMaximumSpeechRate, nativeRate))
    
        synthesizer.speak(utterance)
    }
    
    func seek(to percentage: Double) {
        speak(text: self.currentText, rate: self.lastKnownRate, seekToProgress: percentage)
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
            
            let remainingTime = self.estimatedTotalDuration * (1.0 - progress)
            let timeDisplay = formatTime(remainingTime)
            
            let playbackUpdate = PlaybackProgress(progress: progress, timeDisplay: timeDisplay)
            progressPublisher.send(playbackUpdate)
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
            progressPublisher.send(PlaybackProgress(progress: 1.0, timeDisplay: "-00:00"))
            didFinishPublisher.send()
        }
    }
    
    private func estimateDuration(for text: String, rate: Double) -> TimeInterval {
        let normalWordsPerMinute = 180.0
        let adjustedWordsPerMinute = normalWordsPerMinute * rate
        let words = text.split { !$0.isLetter && !$0.isNumber }.count
        
        if adjustedWordsPerMinute > 0 {
            let minutes = Double(words) / adjustedWordsPerMinute
            return minutes * 60
        }
        return 0
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN, !time.isInfinite, time >= 0 else {
            return "-00:00"
        }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "-%02d:%02d", minutes, seconds)
    }
}
