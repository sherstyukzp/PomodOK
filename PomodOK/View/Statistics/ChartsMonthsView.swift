import SwiftUI
import SwiftData
import Charts

struct ChartsMonthsView: View {

    @Query(sort: \PomodoroSession.timestamp) private var sessions: [PomodoroSession]

    var body: some View {
        let currentYear = Calendar.current.component(.year, from: Date())
        let chartDataSet = [
            ChartDataModel(label: "Jan", value: countSessions(month: 1,  year: currentYear)),
            ChartDataModel(label: "Feb", value: countSessions(month: 2,  year: currentYear)),
            ChartDataModel(label: "Mar", value: countSessions(month: 3,  year: currentYear)),
            ChartDataModel(label: "Apr", value: countSessions(month: 4,  year: currentYear)),
            ChartDataModel(label: "May", value: countSessions(month: 5,  year: currentYear)),
            ChartDataModel(label: "Jun", value: countSessions(month: 6,  year: currentYear)),
            ChartDataModel(label: "Jul", value: countSessions(month: 7,  year: currentYear)),
            ChartDataModel(label: "Aug", value: countSessions(month: 8,  year: currentYear)),
            ChartDataModel(label: "Sep", value: countSessions(month: 9,  year: currentYear)),
            ChartDataModel(label: "Oct", value: countSessions(month: 10, year: currentYear)),
            ChartDataModel(label: "Nov", value: countSessions(month: 11, year: currentYear)),
            ChartDataModel(label: "Dec", value: countSessions(month: 12, year: currentYear)),
        ]

        VStack {
            Text("Statistics for the month")
                .font(Font.system(size: 24, design: .default))
                .padding()

            Chart(chartDataSet, id: \.label) { item in
                BarMark(
                    x: .value("Month", item.label),
                    y: .value("Value", item.value)
                )
            }
            .foregroundColor(Color("redColor"))
            .frame(height: 250)
            .padding()

            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    let maxMonth = chartDataSet.max { $0.value < $1.value }
                    let minMonth = chartDataSet.min { $0.value < $1.value }
                    Divider()
                    HStack {
                        Text("The best month:")
                        Text(nameMonthFull(month: maxMonth?.label ?? ""))
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("The worst month:")
                        Text(nameMonthFull(month: minMonth?.label ?? ""))
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

    private func countSessions(month: Int, year: Int) -> Int {
        let cal = Calendar.current
        return sessions.filter {
            cal.component(.year, from: $0.timestamp) == year &&
            cal.component(.month, from: $0.timestamp) == month
        }.count
    }

    private func nameMonthFull(month: String) -> String {
        switch month {
        case "Jan": return "January"
        case "Feb": return "February"
        case "Mar": return "March"
        case "Apr": return "April"
        case "May": return "May"
        case "Jun": return "June"
        case "Jul": return "July"
        case "Aug": return "August"
        case "Sep": return "September"
        case "Oct": return "October"
        case "Nov": return "November"
        case "Dec": return "December"
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
