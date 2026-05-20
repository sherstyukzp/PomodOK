import SwiftUI
import SwiftData

@main
struct PomodOKApp: App {

    let modelContainer: ModelContainer

    init() {
        let schema = Schema([PomodoroTask.self, PomodoroSession.self])
        let storeURL = URL.applicationSupportDirectory
            .appending(path: "PomodOK_SwiftData.sqlite")
        let config = ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
