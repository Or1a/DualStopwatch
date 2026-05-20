import Foundation

final class StopwatchModel: ObservableObject {
    struct Lap: Identifiable {
        let id = UUID()
        let number: Int
        let elapsed: TimeInterval
    }

    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var laps: [Lap] = []
    @Published private(set) var isRunning = false

    private var startedAt: Date?
    private var timer: Timer?

    deinit {
        timer?.invalidate()
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func start() {
        guard !isRunning else { return }

        startedAt = Date().addingTimeInterval(-elapsed)
        isRunning = true
        scheduleTimer()
    }

    func pause() {
        guard isRunning else { return }

        updateElapsed()
        timer?.invalidate()
        timer = nil
        startedAt = nil
        isRunning = false
    }

    func recordLap() {
        guard elapsed > 0 else { return }

        updateElapsed()
        let lap = Lap(number: laps.count + 1, elapsed: elapsed)
        laps.insert(lap, at: 0)
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        startedAt = nil
        elapsed = 0
        laps.removeAll()
        isRunning = false
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateElapsed()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func updateElapsed() {
        guard let startedAt else { return }
        elapsed = Date().timeIntervalSince(startedAt)
    }
}

extension TimeInterval {
    var stopwatchText: String {
        let totalCentiseconds = Int((self * 100).rounded(.down))
        let centiseconds = totalCentiseconds % 100
        let totalSeconds = totalCentiseconds / 100
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600

        if hours > 0 {
            return String(format: "%d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds)
        }

        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }
}
