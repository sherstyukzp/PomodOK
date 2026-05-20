import SwiftUI
import SwiftData

struct AllEntriesView: View {

    @Query(sort: \PomodoroSession.timestamp, order: .reverse) private var sessions: [PomodoroSession]
    @Environment(\.modelContext) private var modelContext

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }()

    // Groups sessions by calendar date, preserving reverse-chronological order.
    private var groupedSessions: [(date: String, sessions: [PomodoroSession])] {
        var groups: [(date: String, sessions: [PomodoroSession])] = []
        var seen: Set<String> = []
        for session in sessions {
            let key = dateFormatter.string(from: session.timestamp)
            if !seen.contains(key) {
                seen.insert(key)
                groups.append((date: key, sessions: []))
            }
            if let idx = groups.firstIndex(where: { $0.date == key }) {
                groups[idx].sessions.append(session)
            }
        }
        return groups
    }

    var body: some View {
        List {
            ForEach(groupedSessions, id: \.date) { group in
                Section(header: Text(group.date)) {
                    ForEach(group.sessions) { session in
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(Color("redColor"))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.timestamp, style: .time)
                                if let taskTitle = session.task?.title {
                                    Text(taskTitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text("\(session.durationMinutes) min")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { offsets in deleteSession(in: group.sessions, at: offsets) }
                }
            }
        }
    }

    private func deleteSession(in sessionList: [PomodoroSession], at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(sessionList[offset])
        }
        try? modelContext.save()
    }
}

struct AllEntriesView_Previews: PreviewProvider {
    static var previews: some View {
        AllEntriesView()
            .modelContainer(for: [PomodoroSession.self, PomodoroTask.self], inMemory: true)
    }
}
