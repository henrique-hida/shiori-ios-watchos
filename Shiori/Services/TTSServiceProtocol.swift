//
//  TTSServiceProtocol.swift
//  Shiori
//
//  Created by Henrique Hida on 01/09/25.
//

import Foundation
import Combine

struct PlaybackProgress {
    let progress: Double
    let timeDisplay: String
}

protocol TTSServiceProtocol {
    var progressPublisher: PassthroughSubject<PlaybackProgress, Never> { get }
    var didFinishPublisher: PassthroughSubject<Void, Never> { get }
    
    func speak(text: String, rate: Double, seekToProgress: Double?)
    func pause()
    func resume()
    func seek(to percentage: Double)
    func stop()
}
