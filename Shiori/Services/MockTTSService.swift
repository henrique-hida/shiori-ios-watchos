//
//  MockTTSService.swift
//  Shiori
//
//  Created by Henrique Hida on 01/09/25.
//

import Foundation
import Combine

class MockTTSService: TTSServiceProtocol {
    
    var progressPublisher = PassthroughSubject<PlaybackProgress, Never>()
    var didFinishPublisher = PassthroughSubject<Void, Never>()
    
    func speak(text: String, rate: Double, seekToProgress: Double?) {
        print("MockTTS: Chamado speak(text: \(text))")
    }
    
    func pause() {}
    func resume() {}
    func stop() {}
    func seek(to percentage: Double) {}
}
