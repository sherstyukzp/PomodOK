import SwiftUI
import SwiftData
import Charts

struct ChartsYearsView: View {

    @Query(sort: \PomodoroSession.timestamp) private var sessions: [PomodoroSession]
    @State private var metric: ChartMetric = .sessions

    private var years: [Int] {
        let cal = Calendar.current
        let currentYear = cal.component(.year, from: Date())
        guard let first = sessions.first else { return [currentYear] }
        let firstYear = cal.component(.year, from: first.timestamp)
        return Array(firstYear...currentYear)
    }

    var body: some View {
        let chartData = years.map {
            ChartDataModel(label: "\($0)", value: value(year: $0))
        }
        let total = chartData.reduce(0) { $0 + $1.value }

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Metric", selection: $metric) {
                    ForEach(ChartMetric.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Chart(chartData, id: \.label) { item in
                    BarMark(
                        x: .value("Year", item.label),
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

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(metric == .minutes ? formatMinutes(total) : "\(total)")
                            .font(.title2.bold())
                            .foregroundStyle(Color("redColor"))
                        Text("All time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let best = chartData.max(by: { $0.value < $1.value }), best.value > 0 {
                        Divider().frame(height: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(best.label)
                                .font(.title2.bold())
                                .foregroundStyle(.blue)
                            Text("Best year")
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

    private func value(year: Int) -> Int {
        let cal = Calendar.current
        let filtered = sessions.filter { cal.component(.year, from: $0.timestamp) == year }
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
}

struct ChartsYearsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsYearsView()
            .modelContainer(for: [PomodoroSession.self, PomodoroTask.self], inMemory: true)
    }
}
