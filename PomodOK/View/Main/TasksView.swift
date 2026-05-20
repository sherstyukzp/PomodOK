import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PomodoroTask.createdAt) private var tasks: [PomodoroTask]

    @Binding var start: Bool
    @Binding var retrieved: Int
    @Binding var count: Int
    @Binding var to: CGFloat
    @Binding var notifications: Bool
    @Binding var activeTaskID: String
    @Binding var activeTaskName: String

    @State private var newTaskTitle = ""
    @State private var newTaskPomodoros = 1
    @State private var newTaskPriority: TaskPriority = .medium
    @State private var selectedFilter: TaskFilter = .all
    @State private var pendingCompletionTaskID: UUID?
    @State private var isAddTaskSheetPresented = false

    var notificationPublisher = NotificationManager()

    private var filteredTasks: [PomodoroTask] {
        switch selectedFilter {
        case .all:
            return sortedTasks(from: tasks)
        case .high:
            return sortedTasks(from: tasks.filter { $0.priority == .high })
        case .medium:
            return sortedTasks(from: tasks.filter { $0.priority == .medium })
        case .low:
            return sortedTasks(from: tasks.filter { $0.priority == .low })
        case .completed:
            return tasks.filter { $0.isCompleted }
        }
    }

    private var priorityFromSelectedFilter: TaskPriority {
        switch selectedFilter {
        case .high: return .high
        case .medium: return .medium
        case .low: return .low
        case .all, .completed: return .medium
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Form {
                    Section("All and Priorities") {
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(TaskFilter.allCases) { filter in
                                Text(filter.titleKey).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Tasks") {
                        if filteredTasks.isEmpty {
                            Text("No tasks yet")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(filteredTasks) { task in
                                taskRow(task)
                            }
                            .onDelete(perform: deleteTask)
                        }
                    }
                }

                Button {
                    newTaskPriority = priorityFromSelectedFilter
                    isAddTaskSheetPresented = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color("redColor"))
                        .clipShape(Circle())
                        .shadow(color: Color("redColor").opacity(0.35), radius: 8, x: 0, y: 4)
                }
                .accessibilityLabel("Add Task")
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitle(Text("Tasks"), displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $isAddTaskSheetPresented) {
                addTaskSheet
            }
        }
    }

    private var addTaskSheet: some View {
        NavigationView {
            Form {
                Section("New Task") {
                    TextField("Task name", text: $newTaskTitle)
                        .textInputAutocapitalization(.sentences)

                    HStack {
                        Text("Pomodoros")
                        Spacer()
                        tomatoSelector
                    }

                    Picker("Priority", selection: $newTaskPriority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Label(priority.titleKey, systemImage: priority.symbol)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationBarTitle(Text("New Task"), displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    resetNewTaskForm()
                    isAddTaskSheetPresented = false
                },
                trailing: Button("Add") {
                    addTask()
                }
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }

    private var tomatoSelector: some View {
        HStack(spacing: 8) {
            ForEach(1...4, id: \.self) { value in
                let isSelected = value <= newTaskPomodoros
                Button {
                    newTaskPomodoros = value
                } label: {
                    Text("🍅")
                        .font(.title3)
                        .opacity(isSelected ? 1.0 : 0.3)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func taskRow(_ task: PomodoroTask) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                completionButton(for: task)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)

                    Text("\(task.completedPomodoros)/\(task.plannedPomodoros) pomodoros")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: task.priority.symbol)
                    .font(.caption)
                    .foregroundStyle(task.priority.tint)
            }

            HStack {
                Button("Select") {
                    setActiveTask(task)
                }
                .buttonStyle(.bordered)
                .disabled(task.isCompleted)

                Spacer()

                Button("Start Timer") {
                    setActiveTask(task)
                    startTimerFromTask()
                }
                .buttonStyle(.borderedProminent)
                .disabled(task.isCompleted)
            }
        }
        .padding(.vertical, 4)
    }

    private func completionButton(for task: PomodoroTask) -> some View {
        Button {
            toggleCompletionWithDelay(for: task)
        } label: {
            Image(systemName: pendingCompletionTaskID == task.uuid
                  ? "clock"
                  : (task.isCompleted ? "checkmark.circle.fill" : "circle"))
                .font(.title3)
                .foregroundStyle(task.isCompleted ? .green : .secondary)
        }
        .buttonStyle(.plain)
        .disabled(pendingCompletionTaskID == task.uuid)
    }

    private func addTask() {
        let trimmedTitle = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let task = PomodoroTask(title: trimmedTitle, plannedPomodoros: newTaskPomodoros, priority: newTaskPriority)
        modelContext.insert(task)
        try? modelContext.save()
        resetNewTaskForm()
        isAddTaskSheetPresented = false
    }

    private func resetNewTaskForm() {
        newTaskTitle = ""
        newTaskPomodoros = 1
        newTaskPriority = priorityFromSelectedFilter
    }

    private func deleteTask(at offsets: IndexSet) {
        for offset in offsets {
            let task = filteredTasks[offset]
            if task.uuid.uuidString == activeTaskID {
                activeTaskID = ""
                activeTaskName = ""
            }
            modelContext.delete(task)
        }
        try? modelContext.save()
    }

    private func toggleCompletionWithDelay(for task: PomodoroTask) {
        pendingCompletionTaskID = task.uuid

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if task.isCompleted {
                task.completedPomodoros = 0
            } else {
                task.completedPomodoros = task.plannedPomodoros
            }

            if task.uuid.uuidString == activeTaskID, task.isCompleted {
                activeTaskID = ""
                activeTaskName = ""
            }

            try? modelContext.save()
            pendingCompletionTaskID = nil
        }
    }

    private func sortedTasks(from source: [PomodoroTask]) -> [PomodoroTask] {
        source.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted {
                return !lhs.isCompleted
            }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }

    private func setActiveTask(_ task: PomodoroTask) {
        activeTaskID = task.uuid.uuidString
        activeTaskName = task.title
    }

    private func startTimerFromTask() {
        if count == retrieved * 60 {
            count = 0
            withAnimation(.default) { to = 0 }
        }

        if notifications {
            notificationPublisher.addNotification(
                identifier: "timerPomodOK",
                titleNotification: "PomodOK",
                subtitleNotification: "Timer Is Completed",
                bodyNotification: "Timer Is Completed Successfully!!!",
                timeInterval: TimeInterval(retrieved * 60 - count)
            )
        }

        if !start { start.toggle() }
        presentationMode.wrappedValue.dismiss()
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
