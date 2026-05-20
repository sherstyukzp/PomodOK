import SwiftUI
import SwiftData
import Charts

struct ChartsMonthsView: View {

    @Query(sort: \PomodoroSession.timestamp) private var sessions: [PomodoroSession]
    @State private var metric: ChartMetric = .sessions

    private let monthLabels = ["Jan","Feb","Mar","Apr","May","Jun",
                               "Jul","Aug","Sep","Oct","Nov","Dec"]

    var body: some View {
        let currentYear = Calendar.current.component(.year, from: Date())
        let chartData = monthLabels.enumerated().map { idx, label in
            ChartDataModel(label: label, value: value(month: idx + 1, year: currentYear))
        }
        let total = chartData.reduce(0) { $0 + $1.value }

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Metric toggle
                Picker("Metric", selection: $metric) {
                    ForEach(ChartMetric.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Text("Year \(currentYear)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                // Chart
                Chart(chartData, id: \.label) { item in
                    BarMark(
                        x: .value("Month", item.label),
                        y: .value(metric.rawValue, item.value)
                    )
                    .foregroundStyle(Color("redColor").gradient)
                    .cornerRadius(6)
                }
                .frame(height: 220)
                .padding(.horizontal)

                // Summary row
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(metric == .minutes ? formatMinutes(total) : "\(total)")
                            .font(.title2.bold())
                            .foregroundStyle(Color("redColor"))
                        Text("Year total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider().frame(height: 36)

                    if let best = chartData.max(by: { $0.value < $1.value }), best.value > 0 {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(nameMonthFull(month: best.label))
                                .font(.title2.bold())
                                .foregroundStyle(.blue)
                            Text("Best month")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let worst = chartData.filter({ $0.value > 0 }).min(by: { $0.value < $1.value }) {
                        Divider().frame(height: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(nameMonthFull(month: worst.label))
                                .font(.title2.bold())
                                .foregroundStyle(.orange)
                            Text("Least active")
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

    private func value(month: Int, year: Int) -> Int {
        let cal = Calendar.current
        let filtered = sessions.filter {
            cal.component(.year, from: $0.timestamp) == year &&
            cal.component(.month, from: $0.timestamp) == month
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

    private func nameMonthFull(month: String) -> String {
        switch month {
        case "Jan": return "January";  case "Feb": return "February"
        case "Mar": return "March";    case "Apr": return "April"
        case "May": return "May";      case "Jun": return "June"
        case "Jul": return "July";     case "Aug": return "August"
        case "Sep": return "September";case "Oct": return "October"
        case "Nov": return "November"; case "Dec": return "December"
        default: return ""
        }
    }
}

struct ChartsMonthsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsMonthsView()
            .modelContainer(for: [PomodoroSession.self, PomodoroTask.self], inMemory: true)
    }
}
