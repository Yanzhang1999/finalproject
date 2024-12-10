import SwiftUI

struct StudyView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    @State private var selectedDuration = 25
    @State private var isStudying = false
    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer?
    
    let availableDurations = [25, 30, 45, 60]
    
    var body: some View {
        VStack(spacing: 30) {
            // 时间选择器
            if !isStudying {
                Picker("Study TIme", selection: $selectedDuration) {
                    ForEach(availableDurations, id: \.self) { duration in
                        Text("\(duration)Minutes").tag(duration)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: isStudying ? remainingTime / Double(selectedDuration * 60) : 1)
                    .stroke(Color.blue, lineWidth: 15)
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: remainingTime)
                
                VStack {
                    Text(timeString(from: remainingTime))
                        .font(.system(size: 60, weight: .bold))
                    Text(isStudying ? "focuing..." : "Ready to Start")
                        .font(.title3)
                }
            }
            
            // 控制按钮
            Button(action: toggleStudySession) {
                Text(isStudying ? "End Study" : "Begin to focus")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(isStudying ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Focus Study")
    }
    
    private func toggleStudySession() {
        if isStudying {
            stopTimer()
        } else {
            startTimer()
        }
        isStudying.toggle()
    }
    
    private func startTimer() {
        remainingTime = Double(selectedDuration * 60)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                stopTimer()
                isStudying = false
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
