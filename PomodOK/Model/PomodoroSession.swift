import SwiftData
import Foundation

@Model
final class PomodoroSession {
    var timestamp: Date
    var durationMinutes: Int
    var task: PomodoroTask?

    init(timestamp: Date = Date(), durationMinutes: Int, task: PomodoroTask? = nil) {
        self.timestamp = timestamp
        self.durationMinutes = durationMinutes
        self.task = task
    }
}
