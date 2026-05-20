import SwiftUI
import SwiftData

struct AllEntriesView: View {

    @Query(sort: \PomodoroSession.timestamp, order: .reverse) private var sessions: [PomodoroSession]
    @Environment(\.modelContext) private var modelContext

    @State private var range: TimeRange = .allTime

    private enum TimeRange: String, CaseIterable, Identifiable {
        case sevenDays = "7d"
        case thirtyDays = "30d"
        case allTime = "All"

        var id: String { rawValue }
    }

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    private var filteredSessions: [PomodoroSession] {
        let calendar = Calendar.current
        let now = Date()

        switch range {
        case .sevenDays:
            guard let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return sessions }
            return sessions.filter { $0.timestamp >= start }
        case .thirtyDays:
            guard let start = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: now)) else { return sessions }
            return sessions.filter { $0.timestamp >= start }
        case .allTime:
            return sessions
        }
    }

    private var groupedSessions: [(date: String, dateValue: Date, sessions: [PomodoroSession])] {
        var groups: [(date: String, dateValue: Date, sessions: [PomodoroSession])] = []
        var seen: Set<String> = []

        for session in filteredSessions {
            let key = dateFormatter.string(from: session.timestamp)
            if !seen.contains(key) {
                seen.insert(key)
                groups.append((date: key, dateValue: session.timestamp, sessions: []))
            }
            if let idx = groups.firstIndex(where: { $0.date == key }) {
                groups[idx].sessions.append(session)
            }
        }
        return groups
    }

    private var totalMinutes: Int {
        filteredSessions.reduce(0) { $0 + $1.durationMinutes }
    }

    private var averageMinutesPerDay: Int {
        guard !groupedSessions.isEmpty else { return 0 }
        return totalMinutes / groupedSessions.count
    }

    private var bestDaySummary: String {
        guard let best = groupedSessions.max(by: {
            $0.sessions.reduce(0) { $0 + $1.durationMinutes } < $1.sessions.reduce(0) { $0 + $1.durationMinutes }
        }) else {
            return "No data"
        }
        let minutes = best.sessions.reduce(0) { $0 + $1.durationMinutes }
        return "\(best.date) · \(formatMinutes(minutes))"
    }

    var body: some View {
        if sessions.isEmpty {
            ContentUnavailableView(
                "No sessions yet",
                systemImage: "timer",
                description: Text("Complete a Pomodoro session to see your history here.")
            )
        } else {
            List {
                Section {
                    Picker("Range", selection: $range) {
                        ForEach(TimeRange.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)

                    summaryStrip
                }

                ForEach(groupedSessions, id: \.date) { group in
                    Section {
                        ForEach(group.sessions) { session in
                            sessionRow(session)
                        }
                        .onDelete { offsets in deleteSession(in: group.sessions, at: offsets) }
                    } header: {
                        HStack {
                            Text(group.date)
                            Spacer()
                            let groupMinutes = group.sessions.reduce(0) { $0 + $1.durationMinutes }
                            Text("\(group.sessions.count) sessions · \(formatMinutes(groupMinutes))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private var summaryStrip: some View {
        HStack(spacing: 10) {
            summaryBadge(title: "Sessions", value: "\(filteredSessions.count)", tint: Color("redColor"))
            summaryBadge(title: "Focus", value: formatMinutes(totalMinutes), tint: .orange)
            summaryBadge(title: "Avg/day", value: formatMinutes(averageMinutesPerDay), tint: .blue)
        }
        .padding(.vertical, 4)
        .overlay(alignment: .bottomLeading) {
            if !groupedSessions.isEmpty {
                Text("Best day: \(bestDaySummary)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .offset(y: 20)
            }
        }
        .padding(.bottom, groupedSessions.isEmpty ? 0 : 18)
    }

    private func summaryBadge(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    private func sessionRow(_ session: PomodoroSession) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color("redColor").opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: "timer")
                    .foregroundStyle(Color("redColor"))
                    .font(.system(size: 15, weight: .medium))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(session.timestamp, style: .time)
                    .font(.subheadline.weight(.medium))
                if let taskTitle = session.task?.title {
                    Text(taskTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text("\(session.durationMinutes) min")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }

    private func deleteSession(in sessionList: [PomodoroSession], at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(sessionList[offset])
        }
        try? modelContext.save()
    }

    private func formatMinutes(_ total: Int) -> String {
        guard total > 0 else { return "0m" }
        let h = total / 60
        let m = total % 60
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }
}

struct AllEntriesView_Previews: PreviewProvider {
    static var previews: some View {
        AllEntriesView()
            .modelContainer(for: [PomodoroSession.self, PomodoroTask.self], inMemory: true)
    }
}
