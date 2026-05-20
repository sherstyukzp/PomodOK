import SwiftUI
import SwiftData
import Charts

struct ChartsDaysView: View {

    @Query(sort: \PomodoroSession.timestamp) private var sessions: [PomodoroSession]
    @Environment(\.calendar) var calendar

    @Binding var startDate: Date
    @Binding var endDate: Date

    var body: some View {
        let chartDataSet = [
            ChartDataModel(label: "Mo", value: countSessions(weekday: 2)),
            ChartDataModel(label: "Tu", value: countSessions(weekday: 3)),
            ChartDataModel(label: "We", value: countSessions(weekday: 4)),
            ChartDataModel(label: "Th", value: countSessions(weekday: 5)),
            ChartDataModel(label: "Fr", value: countSessions(weekday: 6)),
            ChartDataModel(label: "Sa", value: countSessions(weekday: 7)),
            ChartDataModel(label: "Su", value: countSessions(weekday: 1)),
        ]

        VStack(alignment: .center) {
            Text("Statistics for the day")
                .font(Font.system(size: 24, design: .default))
                .padding()

            HStack {
                Text("From")
                Text(startDate.formatted(date: .abbreviated, time: .omitted))
                Text("to")
                Text(endDate.formatted(date: .abbreviated, time: .omitted))
            }

            Chart(chartDataSet, id: \.label) { item in
                BarMark(
                    x: .value("Day", item.label),
                    y: .value("Value", item.value)
                )
            }
            .foregroundColor(Color("redColor"))
            .frame(height: 250)
            .padding()

            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    let maxDay = chartDataSet.max { $0.value < $1.value }
                    let minDay = chartDataSet.min { $0.value < $1.value }
                    Divider()
                    HStack {
                        Text("The best day:")
                        Text(nameDayFull(day: maxDay?.label ?? ""))
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("The worst day:")
                        Text(nameDayFull(day: minDay?.label ?? ""))
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
                Spacer()
            }
            .padding()
        }
        Spacer()
    }

    private func countSessions(weekday: Int) -> Int {
        sessions.filter { session in
            session.timestamp >= startDate &&
            session.timestamp <= endDate &&
            calendar.component(.weekday, from: session.timestamp) == weekday
        }.count
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
