import SwiftUI
import SwiftData

struct SummaryView: View {

    @Query(sort: \PomodoroSession.timestamp) private var sessions: [PomodoroSession]
    @Query private var tasks: [PomodoroTask]

    private var totalMinutes: Int { sessions.reduce(0) { $0 + $1.durationMinutes } }
    private var completedTasks: [PomodoroTask] { tasks.filter { $0.isCompleted } }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                keyMetricsGrid
                focusInsightsSection
                weekComparisonSection
                if !tasks.isEmpty { taskProgressSection }
            }
            .padding(.vertical)
        }
    }

    // MARK: - Key metrics

    private var keyMetricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(icon: "timer", title: "Pomodoros", value: "\(sessions.count)", color: Color("redColor"))
            StatCard(icon: "clock.fill", title: "Focus Time", value: formatMinutes(totalMinutes), color: .orange)
            StatCard(icon: "checkmark.circle.fill", title: "Tasks Done", value: "\(completedTasks.count)/\(tasks.count)", color: .green)
            StatCard(icon: "flame.fill", title: "Day Streak", value: "\(currentStreak) days", color: .red)
        }
        .padding(.horizontal)
    }

    // MARK: - Focus insights

    private var focusInsightsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Focus Insights")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 8) {
                insightRow(icon: "calendar", title: "Today", value: "\(todaySessionCount) sessions · \(formatMinutes(todayMinutes))", hint: todayVsAverageText)
                insightRow(icon: "timer.square", title: "Average session", value: formatMinutes(averageSessionMinutes), hint: "Based on all completed sessions")
                insightRow(icon: "sparkles", title: "Best weekday", value: bestWeekdayLabel, hint: "Most focused minutes across your history")
                insightRow(icon: "target", title: "Plan completion", value: "\(completionRate)%", hint: "Completed vs planned pomodoros across tasks")
            }
            .padding(.horizontal)
        }
    }

    private func insightRow(icon: String, title: String, value: String, hint: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color("redColor"))
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
            }

            Spacer(minLength: 8)

            Text(hint)
                .font(.caption2)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 150, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Weekly comparison

    private var weekComparisonSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Overview")
                .font(.headline)
                .padding(.horizontal)

            HStack(spacing: 12) {
                periodCard(title: "This Week", sessions: thisWeekSessions, highlighted: true)
                periodCard(title: "Last Week", sessions: lastWeekSessions, highlighted: false)
            }
            .padding(.horizontal)

            if let topHour = mostProductiveHour {
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundStyle(Color("redColor"))
                    Text("Most productive at \(topHour)")
                        .fontWeight(.bold)
                }
                .font(.subheadline)
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
    }

    private func periodCard(title: String, sessions: [PomodoroSession], highlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(sessions.count)")
                .font(.title.bold())
                .foregroundStyle(highlighted ? Color("redColor") : .primary)
            Text(formatMinutes(sessions.reduce(0) { $0 + $1.durationMinutes }))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("sessions")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Task progress

    private var taskProgressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Tasks")
                    .font(.headline)
                Spacer()
                Text("\(completedTasks.count) of \(tasks.count) completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: tasks.isEmpty ? 0 : geo.size.width * CGFloat(completedTasks.count) / CGFloat(tasks.count), height: 8)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(sortedTasks.prefix(6)) { task in
                    taskRow(task)
                }
            }
            .padding(.horizontal)
        }
    }

    private func taskRow(_ task: PomodoroTask) -> some View {
        HStack(spacing: 10) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isCompleted ? .green : .secondary)
                .font(.title3)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.subheadline)
                    .lineLimit(1)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                ProgressView(value: Double(task.completedPomodoros), total: Double(max(task.plannedPomodoros, 1)))
                    .tint(task.isCompleted ? .green : Color("redColor"))
            }

            Spacer()

            Text("\(task.completedPomodoros)/\(task.plannedPomodoros)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Computed

    private var sortedTasks: [PomodoroTask] {
        tasks.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted { return !lhs.isCompleted }
            return lhs.completedPomodoros > rhs.completedPomodoros
        }
    }

    private var thisWeekSessions: [PomodoroSession] {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return sessions.filter { $0.timestamp >= start }
    }

    private var lastWeekSessions: [PomodoroSession] {
        let cal = Calendar.current
        let thisWeekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let lastWeekStart = cal.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart) ?? thisWeekStart
        return sessions.filter { $0.timestamp >= lastWeekStart && $0.timestamp < thisWeekStart }
    }

    private var currentStreak: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let sessionDays = Set(sessions.map { cal.startOfDay(for: $0.timestamp) })
        var streak = 0
        var date = sessionDays.contains(today) ? today : cal.date(byAdding: .day, value: -1, to: today) ?? today

        while sessionDays.contains(date) {
            streak += 1
            date = cal.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return streak
    }

    private var mostProductiveHour: String? {
        guard !sessions.isEmpty else { return nil }
        let cal = Calendar.current
        let grouped = Dictionary(grouping: sessions) { cal.component(.hour, from: $0.timestamp) }
        guard let topHour = grouped.max(by: { $0.value.count < $1.value.count })?.key else { return nil }
        var comps = DateComponents()
        comps.hour = topHour
        guard let date = cal.date(from: comps) else { return nil }
        let f = DateFormatter()
        f.dateFormat = "h a"
        return f.string(from: date)
    }

    private var todaySessionCount: Int {
        let cal = Calendar.current
        return sessions.filter { cal.isDateInToday($0.timestamp) }.count
    }

    private var todayMinutes: Int {
        let cal = Calendar.current
        return sessions.filter { cal.isDateInToday($0.timestamp) }.reduce(0) { $0 + $1.durationMinutes }
    }

    private var sevenDayAverageSessions: Double {
        guard !sessions.isEmpty else { return 0 }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .day, value: -6, to: today) ?? today
        let last7 = sessions.filter { $0.timestamp >= start && $0.timestamp <= Date() }
        return Double(last7.count) / 7.0
    }

    private var todayVsAverageText: String {
        let diff = Double(todaySessionCount) - sevenDayAverageSessions
        if abs(diff) < 0.25 {
            return "On your 7-day average"
        }
        if diff > 0 {
            return String(format: "%.1f above 7-day avg", diff)
        }
        return String(format: "%.1f below 7-day avg", abs(diff))
    }

    private var averageSessionMinutes: Int {
        guard !sessions.isEmpty else { return 0 }
        return totalMinutes / sessions.count
    }

    private var bestWeekdayLabel: String {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: sessions) { cal.component(.weekday, from: $0.timestamp) }
            .mapValues { $0.reduce(0) { $0 + $1.durationMinutes } }

        guard let top = grouped.max(by: { $0.value < $1.value })?.key else {
            return "No data"
        }
        let symbols = cal.weekdaySymbols
        return symbols.indices.contains(top - 1) ? symbols[top - 1] : "Unknown"
    }

    private var completionRate: Int {
        let planned = tasks.reduce(0) { $0 + max($1.plannedPomodoros, 0) }
        guard planned > 0 else { return 0 }
        let completed = tasks.reduce(0) { $0 + min($1.completedPomodoros, max($1.plannedPomodoros, 0)) }
        return Int((Double(completed) / Double(planned) * 100).rounded())
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

// MARK: - StatCard

private struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
            .modelContainer(for: [PomodoroTask.self, PomodoroSession.self], inMemory: true)
    }
}
