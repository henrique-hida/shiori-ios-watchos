//
//  SumViewModel.swift
//  Shiori
//
//  Created by Henrique Hida on 04/08/25.
//

import Foundation
import Combine

class SumViewModel: ObservableObject {
    private let repository = SumRepository()
    
    var id: String
    var sumType: String
    @Published var currentSummary: SumModel?
    
    private var tts: TTSServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var audioPlaying: Bool = false
    @Published var audioProgress: Double = 0.0
    @Published var currentSpeed: Double = 1.0
    
    private var isDraggingSlider: Bool = false
    
    @Published var timeDisplay: String = "00:00"
    
    init(id: String, sumType: String, tts: TTSServiceProtocol) {
        self.id = id
        self.sumType = sumType
        self.tts = tts
        
        self.tts.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] playbackProgress in
                guard let self = self else { return }
                if !self.isDraggingSlider {
                    self.audioProgress = playbackProgress.progress
                    self.timeDisplay = playbackProgress.timeDisplay
                }
            }
            .store(in: &cancellables)
        
        self.tts.didFinishPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.audioPlaying = false
                self?.audioProgress = 0.0
            }
            .store(in: &cancellables)
        
        repository.getSum(id: id, type: sumType) { [weak self] sumModel in
            DispatchQueue.main.async {
                self?.currentSummary = sumModel
            }
        }
    }
    
    func pressAudioButton() {
        if audioPlaying {
            tts.pause()
        } else {
            if audioProgress > 0.01 && audioProgress < 0.99 {
                tts.resume()
            } else {
                let rawContent = removeMarkdownBlockMarkers(from: currentSummary?.content ?? "")
                let textToSpeak = stripMarkdown(from: rawContent)
                guard !textToSpeak.isEmpty else { return }
                tts.speak(text: textToSpeak, rate: self.currentSpeed, seekToProgress: nil)
            }
        }
        audioPlaying.toggle()
    }
    
    func sliderChanged(to progress: Double, isEditing: Bool) {
        self.isDraggingSlider = isEditing
        self.audioProgress = progress
        
        if !isEditing {
            tts.seek(to: progress)
            if !audioPlaying {
                audioPlaying = true
            }
        }
    }
    
    func changeSpeed(to newSpeed: Double) {
        self.currentSpeed = newSpeed
        
        if audioProgress > 0.01 {
            let rawContent = removeMarkdownBlockMarkers(from: currentSummary?.content ?? "")
            let textToSpeak = stripMarkdown(from: rawContent)
            guard !textToSpeak.isEmpty else { return }
            
            tts.speak(text: textToSpeak, rate: self.currentSpeed, seekToProgress: self.audioProgress)
            
            if !audioPlaying {
                audioPlaying = true
            }
        }
    }
    
    func onDisappear() {
        tts.stop()
        audioPlaying = false
        audioProgress = 0.0
        currentSpeed = 0.5
        isDraggingSlider = false
        timeDisplay = "00:00"
    }
    
    func removeMarkdownBlockMarkers(from text: String) -> String {
        var cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedText.hasPrefix("```markdown") {
            cleanedText = String(cleanedText.dropFirst("```markdown".count))
        }
        
        if cleanedText.hasSuffix("```") {
            cleanedText = String(cleanedText.dropLast("```".count))
        }
        
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func stripMarkdown(from text: String) -> String {
        var plainText = text
        
        plainText = plainText.replacingOccurrences(of: "```markdown", with: "", options: .regularExpression)
        plainText = plainText.replacingOccurrences(of: "```", with: "", options: .regularExpression)
        plainText = plainText.replacingOccurrences(of: "^#+\\s*", with: "", options: .regularExpression)
        plainText = plainText.replacingOccurrences(of: "\\*\\*([^*]+)\\*\\*", with: "$1", options: .regularExpression)
        plainText = plainText.replacingOccurrences(of: "\\*([^*]+)\\*", with: "$1", options: .regularExpression)
        plainText = plainText.replacingOccurrences(of: "^[\\*\\-]+\\s+", with: "", options: .regularExpression)
        
        return plainText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
