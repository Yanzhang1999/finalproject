import Foundation
import Combine

class StudyTimerService {
    static let shared = StudyTimerService()
    
    private var timer: Timer?
    private var startTime: Date?
    
    let timerPublisher = PassthroughSubject<TimeInterval, Never>()
    let timerCompletedPublisher = PassthroughSubject<Void, Never>()
    
    func startTimer(duration: TimeInterval) {
        stopTimer()
        
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer(duration: duration)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        startTime = nil
    }
    
    private func updateTimer(duration: TimeInterval) {
        guard let startTime = startTime else { return }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        let remainingTime = duration - elapsedTime
        
        if remainingTime <= 0 {
            stopTimer()
            timerCompletedPublisher.send()
        } else {
            timerPublisher.send(remainingTime)
        }
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
