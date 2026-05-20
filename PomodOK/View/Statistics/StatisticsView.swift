import SwiftUI

struct StatisticView: View {

    @Environment(\.presentationMode) var presentationMode

    @State var selectedDataType = DateType.days

    @State private var startDate = Date.today().previous(.monday)
    @State private var endDate = Date.today().next(.sunday, considerToday: true)

    enum DateType: String, Equatable, CaseIterable {
        case days = "Days"
        case months = "Months"
        case years = "Years"
        case all = "All"

        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Period", selection: $selectedDataType) {
                    ForEach(DateType.allCases, id: \.self) { value in
                        Text(value.localizedName).tag(value)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                switch selectedDataType {
                case .days:   ChartsDaysView(startDate: $startDate, endDate: $endDate)
                case .months: ChartsMonthsView()
                case .years:  ChartsYearsView()
                case .all:    AllEntriesView()
                }
            }
            .navigationBarTitle(Text("Statistics"), displayMode: .large)
            .toolbar {
                if selectedDataType == .days {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button {
                                let cal = Calendar.current
                                let date = Date()
                                startDate = cal.startOfDay(for: date).previous(.monday)
                                endDate = cal.date(bySettingHour: 23, minute: 59, second: 59, of: date)?.next(.sunday) ?? date
                            } label: { Text("This week") }

                            Button {
                                let cal = Calendar.current
                                let date = Date()
                                let lastWeek = cal.date(byAdding: .day, value: -7, to: date)!
                                startDate = cal.startOfDay(for: lastWeek).previous(.monday)
                                endDate = cal.date(bySettingHour: 23, minute: 59, second: 59, of: date)?.previous(.sunday) ?? date
                            } label: { Text("Last week") }
                        } label: {
                            Label("calendar", systemImage: "calendar").foregroundColor(.red)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Close").bold().foregroundColor(.red)
                    }
                }
            }
        }
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
            .modelContainer(for: [PomodoroTask.self, PomodoroSession.self], inMemory: true)
    }
}
