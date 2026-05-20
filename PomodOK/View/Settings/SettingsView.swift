import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.requestReview) var requestReview
    @Environment(\.modelContext) private var modelContext

    @Query private var sessions: [PomodoroSession]
    @Query private var tasks: [PomodoroTask]

    @ObservedObject var userSettings = UserSettings()

    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = true
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isVibrationEnabled") var isVibrationEnabled: Bool = true

    @AppStorage("workSession") var workSession: Int = 25
    @AppStorage("shortBreak") var shortBreak: Int = 5
    @AppStorage("longBreak") var longBreak: Int = 15

    @State private var showingDeleteAlert = false

    var notificationPublisher = NotificationManager()

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String

    init() {
        UISwitch.appearance().onTintColor = .red
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Label("NOTIFICATIONS", systemImage: "bell")) {
                    Toggle(isOn: $isNotificationsEnabled) {
                        Text("Push notifications")
                    }
                    Toggle(isOn: $isSoundEnabled) {
                        Text("Sound")
                    }
                    Toggle(isOn: $isVibrationEnabled) {
                        Text("Vibration")
                    }
                }

                Section(header: Label("TIMER", systemImage: "deskclock")) {
                    Stepper(value: $workSession, in: 1...60) {
                        HStack {
                            Text("Work Session")
                            Spacer()
                            Text("\(workSession)")
                            Text("min")
                        }
                    }
                    Stepper(value: $shortBreak, in: 1...60) {
                        HStack {
                            Text("Short Break")
                            Spacer()
                            Text("\(shortBreak)")
                            Text("min")
                        }
                    }
                    Stepper(value: $longBreak, in: 1...60) {
                        HStack {
                            Text("Long Break")
                            Spacer()
                            Text("\(longBreak)")
                            Text("min")
                        }
                    }
                }

                if !sessions.isEmpty || !tasks.isEmpty {
                    Section(header: Label("Data", systemImage: "tray.2")) {
                        Button {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete All", systemImage: "trash")
                        }
                    }
                }

                Section(header: Label("About", systemImage: "info.circle")) {
                    HStack {
                        Text("Software Version")
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                    }

                    NavigationLink(destination: WhatsNew()) {
                        Text("What's new?")
                    }

                    Button(action: { requestReview() }) {
                        HStack {
                            Text("Rate the application")
                            Spacer()
                            Text("⭐️⭐️⭐️⭐️⭐️")
                        }
                    }
                }

                Section(header: Label("Contact Us", systemImage: "bubble.left")) {
                    Link("Twitter", destination: URL(string: "https://twitter.com/PomodOk")!)
                }
            }
            .onChange(of: isNotificationsEnabled) { _, _ in toggleAction() }
            .navigationBarTitle(Text("Settings"), displayMode: .large)
            .navigationBarItems(trailing:
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Close").bold().foregroundColor(.red)
                }
            )
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("WARNING!"),
                    message: Text("Do you really want to delete all log data?"),
                    primaryButton: .destructive(Text("Yes")) { deleteAllRecords() },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func deleteAllRecords() {
        sessions.forEach { modelContext.delete($0) }
        tasks.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }

    private func toggleAction() {
        if isNotificationsEnabled {
            notificationPublisher.registerLocal()
        } else {
            notificationPublisher.deleteNotification(identifier: "timerPomodOK")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .modelContainer(for: [PomodoroTask.self, PomodoroSession.self], inMemory: true)
    }
}
