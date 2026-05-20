import SwiftUI
import SwiftData
import Charts

struct ChartsYearsView: View {

    @Query(sort: \PomodoroSession.timestamp) private var sessions: [PomodoroSession]

    private var years: [Int] {
        let cal = Calendar.current
        let currentYear = cal.component(.year, from: Date())
        guard let first = sessions.first else { return [currentYear] }
        let firstYear = cal.component(.year, from: first.timestamp)
        return Array(firstYear...currentYear)
    }

    var body: some View {
        let chartDataSet = years.map {
            ChartDataModel(label: "\($0)", value: countSessions(year: $0))
        }

        VStack {
            Text("Statistics for the year")
                .font(Font.system(size: 24, design: .default))
                .padding()

            Chart(chartDataSet, id: \.label) { item in
                BarMark(
                    x: .value("Year", item.label),
                    y: .value("Value", item.value)
                )
            }
            .foregroundColor(Color("redColor"))
            .frame(height: 250)
            .padding()

            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    let maxYear = chartDataSet.max { $0.value < $1.value }
                    let minYear = chartDataSet.min { $0.value < $1.value }
                    Divider()
                    HStack {
                        Text("The best year:")
                        Text(maxYear?.label ?? "")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("The worst year:")
                        Text(minYear?.label ?? "")
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

    private func countSessions(year: Int) -> Int {
        let cal = Calendar.current
        return sessions.filter {
            cal.component(.year, from: $0.timestamp) == year
        }.count
    }
}

struct ChartsYearsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsYearsView()
            .modelContainer(for: [PomodoroSession.self, PomodoroTask.self], inMemory: true)
    }
}
