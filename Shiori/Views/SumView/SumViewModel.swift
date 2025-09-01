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
    
    private let tts = TTSService()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var audioPlaying: Bool = false
    @Published var audioProgress: Double = 0.0
    @Published var currentSpeed: Float = 0.5
    
    private var isDraggingSlider: Bool = false
    
    @Published var timeDisplay: String = "00:00"
    private var totalDuration: TimeInterval = 0
    
    init(id: String, sumType: String) {
        self.id = id
        self.sumType = sumType
        
        repository.getSum(id: id, type: sumType) { [weak self] sumModel in
            DispatchQueue.main.async {
                self?.currentSummary = sumModel
            }
        }
        
        tts.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                guard let self = self else { return }
                if self.isDraggingSlider == false {
                    self.audioProgress = progress
                    let remainingTime = self.totalDuration * (1.0 - progress)
                    self.timeDisplay = self.formatTime(remainingTime)
                }
            }
            .store(in: &cancellables)
        
        tts.didFinishPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.audioPlaying = false
                self?.audioProgress = 0.0
                if let duration = self?.totalDuration {
                    self?.timeDisplay = self?.formatTime(duration) ?? "00:00"
                }
            }
            .store(in: &cancellables)
    }
    
    func pressAudioButton() {
        if audioPlaying {
            tts.pause()
        } else {
            if audioProgress < 0.01 {
                let textToSpeak = removeMarkdownBlockMarkers(from: currentSummary?.content ?? "Texto não encontrado.")
                recalculateTotalDuration()
                tts.speak(text: textToSpeak)
            } else {
                tts.seek(to: self.audioProgress)
            }
        }
        audioPlaying.toggle()
    }
    
    func sliderChanged(to progress: Double, isEditing: Bool) {
        self.isDraggingSlider = isEditing
        self.audioProgress = progress
        
        let remainingTime = self.totalDuration * (1.0 - progress)
        self.timeDisplay = self.formatTime(remainingTime)
        
        if !isEditing {
            tts.seek(to: progress)
            if !audioPlaying {
                audioPlaying = true
            }
        }
    }
    
    func changeSpeed(to newSpeed: Float) {
        self.currentSpeed = newSpeed
        tts.setSpeechRate(rate: newSpeed)
        
        recalculateTotalDuration()
    
        let remainingTime = self.totalDuration * (1.0 - self.audioProgress)
        self.timeDisplay = self.formatTime(remainingTime)
        
        if audioPlaying {
            tts.seek(to: self.audioProgress)
        }
    }
    
    private func recalculateTotalDuration() {
        let textToSpeak = removeMarkdownBlockMarkers(from: currentSummary?.content ?? "")
        guard !textToSpeak.isEmpty else {
            self.totalDuration = 0
            return
        }
        self.totalDuration = tts.estimateDuration(for: textToSpeak)
        
        if !audioPlaying {
            self.timeDisplay = formatTime(self.totalDuration)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN, !time.isInfinite, time >= 0 else {
            return "00:00"
        }
        
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func onDisappear() {
        tts.stop()
        audioPlaying = false
        audioProgress = 0.0
        currentSpeed = 0.5
        isDraggingSlider = false
        timeDisplay = "00:00"
        totalDuration = 0
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
}
