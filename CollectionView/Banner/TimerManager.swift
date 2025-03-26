
import Foundation

class TimerManager {
    
    private var timer: Timer?
    private var scrollInterval: TimeInterval = 4
    
    var onEventTeskTimer: () -> Void
    init(timer: Timer? = nil, scrollInterval: TimeInterval = 4, onEventTeskTimer: @escaping () -> Void) {
        self.timer = timer
        self.scrollInterval = scrollInterval
        self.onEventTeskTimer = onEventTeskTimer
    }
    
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: scrollInterval, repeats: true) { [weak self] _ in
            self?.onEventTeskTimer()
        }
    }
    
    func isTimerRunning() -> Bool {
        return timer != nil
    }
}
