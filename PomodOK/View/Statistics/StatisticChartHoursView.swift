import SwiftUI
import SwiftData

struct StatisticChartHoursView: View {

    @Query(sort: \PomodoroSession.timestamp) private var sessions: [PomodoroSession]

    let hours = Array(6...22).map { String(format: "%02d", $0) }

    var body: some View {
        Text("Statistics for the hours")
            .font(Font.system(size: 24, design: .default))
            .padding()
        VStack {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(hours, id: \.self) { hour in
                    BarHoursView(percent: CGFloat(countSessions(hour: hour)), hourChart: hour)
                        .frame(alignment: .bottom)
                }
            }
            Text("Total: \(sessions.count)")
        }
        Spacer()
    }

    private func countSessions(hour: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return sessions.filter { formatter.string(from: $0.timestamp) == hour }.count
    }
}
