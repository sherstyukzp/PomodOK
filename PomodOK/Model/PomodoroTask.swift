import SwiftUI
import SwiftData

enum TaskPriority: String, CaseIterable, Codable, Identifiable {
    case high
    case medium
    case low

    var id: String { rawValue }

    var title: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }

    var symbol: String {
        switch self {
        case .high: return "exclamationmark.3"
        case .medium: return "exclamationmark.2"
        case .low: return "exclamationmark"
        }
    }

    var tint: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}

enum TaskFilter: String, CaseIterable, Identifiable {
    case all, high, medium, low, completed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        case .completed: return "Completed"
        }
    }
}

@Model
final class PomodoroTask {
    var uuid: UUID
    var title: String
    var plannedPomodoros: Int
    var completedPomodoros: Int
    var priority: TaskPriority
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \PomodoroSession.task)
    var sessions: [PomodoroSession] = []

    var isCompleted: Bool { completedPomodoros >= plannedPomodoros }

    init(uuid: UUID = UUID(), title: String, plannedPomodoros: Int, priority: TaskPriority = .medium) {
        self.uuid = uuid
        self.title = title
        self.plannedPomodoros = plannedPomodoros
        self.completedPomodoros = 0
        self.priority = priority
        self.createdAt = Date()
    }
}
