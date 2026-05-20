import SwiftUI
import SwiftData
import AVFoundation
import AudioToolbox

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [PomodoroTask]

    @Environment(\.scenePhase) var scenePhase

    var notificationPublisher = NotificationManager()

    // MARK: - Settings
    @AppStorage("workSession") var workSession: Int = 25
    @AppStorage("shortBreak") var shortBreak: Int = 5
    @AppStorage("longBreak") var longBreak: Int = 15
    @AppStorage("countPomodoro") var countPomodoro: Int = 0

    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = true
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isVibrationEnabled") var isVibrationEnabled: Bool = true

    @AppStorage("activeTaskID") var activeTaskID: String = ""
    @AppStorage("activeTaskName") var activeTaskName: String = ""

    @State private var showingStatisticsView = false
    @State private var showingSettingsView = false
    @State private var showingTasksView = false

    @State private var showAlert = false
    @State private var showShortBreak = false
    @State private var showLongBreak = false

    @State var start = false
    @State var to: CGFloat = 0
    @State var count = 0
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var showWhatsNew = false
    @State private var setupApp = UserDefaults.standard.integer(forKey: "setupApp")
    @State private var savedVersion = UserDefaults.standard.string(forKey: "savedVersion")

    let systemSoundID: SystemSoundID = 1313

    private var activeTask: PomodoroTask? {
        guard let uuid = UUID(uuidString: activeTaskID) else { return nil }
        return tasks.first { $0.uuid == uuid }
    }

    private var panelPomodoroState: (total: Int, completed: Int) {
        if let task = activeTask {
            let total = max(task.plannedPomodoros, 1)
            let completed = min(max(task.completedPomodoros, 0), total)
            return (total, completed)
        }
        return (4, min(max(countPomodoro, 0), 4))
    }

    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        return appVersion as! String
    }

    func checkForUpdate() {
        let version = getCurrentAppVersion()
        if savedVersion == version {
            print("App is up to date!")
        } else {
            showWhatsNew.toggle()
            UserDefaults.standard.set(version, forKey: "savedVersion")
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                PanelPomodoroView(totalPomodoros: panelPomodoroState.total, completedPomodoros: panelPomodoroState.completed)
                    .padding()

                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color("redColor"))
                        .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)

                    VStack {
                        Text("Work Session")
                            .foregroundColor(Color.white)
                            .font(.system(size: 32))
                            .fontWeight(.medium)
                            .padding(.bottom)

                        if !activeTaskName.isEmpty {
                            Text(activeTaskName)
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding(.bottom, 8)
                        }

                        ZStack {
                            Circle()
                                .trim(from: 0, to: 1)
                                .stroke(Color.black.opacity(0.09), style: StrokeStyle(lineWidth: 30, lineCap: .round))
                                .frame(width: 240, height: 240)

                            Circle()
                                .trim(from: 0, to: self.to)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                                .frame(width: 240, height: 240)
                                .rotationEffect(.init(degrees: -90))

                            VStack {
                                Text(secondsToMinutesAndSeconds(seconds: (workSession * 60) - count))
                                    .font(.system(size: 54))
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)

                                HStack {
                                    Text("Of")
                                    Text("\(workSession)")
                                    Text("min")
                                }
                                .font(.title)
                                .foregroundColor(.white)
                            }
                        }
                    }
                }.padding()

                CustomTabBarView(
                    showingStatisticsView: $showingStatisticsView,
                    showingTasksView: $showingTasksView,
                    start: $start,
                    retrieved: $workSession,
                    count: $count,
                    to: $to,
                    notifications: $isNotificationsEnabled
                )
                .padding(.bottom)
            }

            .navigationBarTitle(Text("PomodOK"), displayMode: .large)
            .navigationBarItems(trailing:
                HStack(spacing: 16) {
                    Button(action: {
                        self.count = 0
                        withAnimation(.default) { self.to = 0 }
                        notificationPublisher.deleteNotification(identifier: "timerPomodOK")
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset")
                        }
                        .foregroundColor(Color(.gray))
                    }

                    Button(action: { self.showingSettingsView.toggle() }) {
                        Image(systemName: "gear")
                            .foregroundColor(Color(.gray))
                    }
                }
            )
        }

        .onReceive(self.time) { _ in
            if self.start {
                if self.count != self.workSession * 60 {
                    self.count += 1
                    withAnimation(.default) {
                        self.to = CGFloat(self.count) / CGFloat(self.workSession * 60)
                    }
                } else {
                    self.start.toggle()

                    isSoundEnabled == true ? AudioServicesPlaySystemSound(systemSoundID) : nil
                    isVibrationEnabled == true ? AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) : nil

                    addSession()
                    incrementActiveTaskProgress()

                    notificationPublisher.deleteNotification(identifier: "timerPomodOK")

                    if countPomodoro < 4 {
                        countPomodoro += 1
                    } else {
                        countPomodoro = 1
                    }
                    self.showAlert.toggle()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Timer Is Completed"),
                message: Text("Timer Is Completed Successfully!!!"),
                primaryButton: .default(Text("Continue"), action: {
                    self.count = 0
                    withAnimation(.default) { self.to = 0 }
                    self.start.toggle()
                }),
                secondaryButton: .default(Text("Break"), action: {
                    if countPomodoro < 4 {
                        if isNotificationsEnabled {
                            notificationPublisher.addNotification(
                                identifier: "ShortBreakPomodOK",
                                titleNotification: "PomodOK",
                                subtitleNotification: "The end of rest",
                                bodyNotification: "Time to get to work!!!",
                                timeInterval: TimeInterval(shortBreak * 60)
                            )
                        }
                        self.showShortBreak.toggle()
                    } else {
                        if isNotificationsEnabled {
                            notificationPublisher.addNotification(
                                identifier: "LongBreakPomodOK",
                                titleNotification: "PomodOK",
                                subtitleNotification: "All timers are completed",
                                bodyNotification: "You worked well, it's time to relax well!!!",
                                timeInterval: TimeInterval(longBreak * 60)
                            )
                        }
                        self.showLongBreak.toggle()
                    }
                })
            )
        }
        .fullScreenCover(isPresented: $showShortBreak) { ShortBreakView(shortBreak: $shortBreak) }
        .fullScreenCover(isPresented: $showLongBreak) { ShortBreakView(shortBreak: $longBreak) }
        .sheet(isPresented: $showWhatsNew, content: { WhatsNew() })
        .sheet(isPresented: $showingSettingsView) { SettingsView() }
        .sheet(isPresented: $showingTasksView) {
            TasksView(
                start: $start,
                retrieved: $workSession,
                count: $count,
                to: $to,
                notifications: $isNotificationsEnabled,
                activeTaskID: $activeTaskID,
                activeTaskName: $activeTaskName
            )
        }
        .onAppear(perform: checkForUpdate)
        .onAppear { AppReviewRequest.requestReviewIfNeeded() }
    }

    // MARK: - Save completed session

    func addSession() {
        let session = PomodoroSession(timestamp: Date(), durationMinutes: workSession, task: activeTask)
        modelContext.insert(session)
        try? modelContext.save()
    }

    private func incrementActiveTaskProgress() {
        guard let task = activeTask else {
            if !activeTaskID.isEmpty {
                activeTaskID = ""
                activeTaskName = ""
            }
            return
        }
        task.completedPomodoros += 1
        if task.isCompleted {
            activeTaskID = ""
            activeTaskName = ""
        }
        try? modelContext.save()
    }

    func secondsToMinutesAndSeconds(seconds: Int) -> String {
        let minutes = "\((seconds % 3600) / 60)"
        let secs = "\((seconds % 3600) % 60)"
        let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
        let secondStamp = secs.count > 1 ? secs : "0" + secs
        return "\(minuteStamp):\(secondStamp)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.colorScheme, .light)
            .modelContainer(for: [PomodoroTask.self, PomodoroSession.self], inMemory: true)
    }
}
