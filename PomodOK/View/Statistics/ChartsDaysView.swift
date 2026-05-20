import SwiftUI
import SwiftData
import Charts

struct ChartsDaysView: View {

    @Query(sort: \PomodoroSession.timestamp) private var sessions: [PomodoroSession]
    @Environment(\.calendar) var calendar

    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var metric: ChartMetric = .sessions

    private let weekdays: [(label: String, weekday: Int)] = [
        ("Mo", 2), ("Tu", 3), ("We", 4), ("Th", 5), ("Fr", 6), ("Sa", 7), ("Su", 1)
    ]

    var body: some View {
        let chartData = weekdays.map { day in
            ChartDataModel(label: day.label, value: value(weekday: day.weekday))
        }
        let total = chartData.reduce(0) { $0 + $1.value }

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Metric toggle
                Picker("Metric", selection: $metric) {
                    ForEach(ChartMetric.allCases, id: \.self) { Text($0.localizedName).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Date range
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color("redColor"))
                    Text(startDate.formatted(date: .abbreviated, time: .omitted))
                    Text("→")
                    Text(endDate.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

                // Chart
                Chart(chartData, id: \.label) { item in
                    BarMark(
                        x: .value("Day", item.label),
                        y: .value(metric.rawValue, item.value)
                    )
                    .foregroundStyle(Color("redColor").gradient)
                    .cornerRadius(6)
                    .annotation(position: .top) {
                        if item.value > 0 {
                            Text(metric == .minutes ? formatMinutes(item.value) : "\(item.value)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 220)
                .padding(.horizontal)

                // Summary row
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(metric == .minutes ? formatMinutes(total) : "\(total)")
                            .font(.title2.bold())
                            .foregroundStyle(Color("redColor"))
                        Text("Total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider().frame(height: 36)

                    if let best = chartData.max(by: { $0.value < $1.value }), best.value > 0 {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(nameDayFull(day: best.label))
                                .font(.title2.bold())
                                .foregroundStyle(.blue)
                            Text("Best day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            .padding(.vertical)
        }
    }

    private func value(weekday: Int) -> Int {
        let filtered = sessions.filter { session in
            session.timestamp >= startDate &&
            session.timestamp <= endDate &&
            calendar.component(.weekday, from: session.timestamp) == weekday
        }
        return metric == .sessions
            ? filtered.count
            : filtered.reduce(0) { $0 + $1.durationMinutes }
    }

    private func formatMinutes(_ total: Int) -> String {
        guard total > 0 else { return "0m" }
        let h = total / 60, m = total % 60
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }

    private func nameDayFull(day: String) -> String {
        switch day {
        case "Mo": return "Monday"
        case "Tu": return "Tuesday"
        case "We": return "Wednesday"
        case "Th": return "Thursday"
        case "Fr": return "Friday"
        case "Sa": return "Saturday"
        case "Su": return "Sunday"
        default: return ""
        }
    }
}

struct ChartsDaysView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsDaysView(startDate: .constant(Date()), endDate: .constant(Date()))
            .modelContainer(for: [PomodoroSession.self, PomodoroTask.self], inMemory: true)
    }
}
