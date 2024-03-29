//
//  SettingsView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 06.09.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//


import SwiftUI
import CoreData
import StoreKit

struct SettingsView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.requestReview) var requestReview
    // MARK: - Core Data
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var userSettings = UserSettings()
    
    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = true
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isVibrationEnabled") var isVibrationEnabled: Bool = true
    
    @AppStorage("workSession") var workSession: Int = 25
    @AppStorage("shortBreak") var shortBreak: Int = 5
    @AppStorage("longBreak") var longBreak: Int = 15
    
    @FetchRequest(entity: Item.entity(), sortDescriptors: []) var items: FetchedResults<Item>
    @State private var isShareSheetShowing = false
    // MARK: - @State
    @State private var showingDeleteAlert = false
    //@State private var isExportCSVSheetShowing = false
    
    var notificationPublisher = NotificationManager()
    
    // MARK: - Variables
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    init()
    {
        UISwitch.appearance().onTintColor = .red
    }
    
    // MARK: - Body
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
                        HStack{
                            Text("Long Break")
                            Spacer()
                            Text("\(longBreak)")
                            Text("min")
                        }
                        
                    }
                }
                
                if !items.isEmpty {
                    Section(header: Label("Data", systemImage: "tray.2")) {
                        // Экспорт
//                        Button {
//                            shareButton()
//                        } label: {
//                            Label("Export in CSV", systemImage: "square.and.arrow.up")
//                        }
                        // ивдалення всіх даних
                        Button {
                            self.showingDeleteAlert = true
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
                    
                    HStack {
                        NavigationLink(destination: WhatsNew()) {
                            Text("What's new?")
                        }
                    }
                    
                    Button(action: {
                        requestReview()
                    }) {
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
            
            .onChange(of: isNotificationsEnabled) { newValue in
                toggleAction()
            }
            
            .navigationBarTitle(Text("Settings"), displayMode: .large)
            .navigationBarItems(trailing:
                                    // Butoon Close
                                Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
                    .bold()
                    .foregroundColor(Color(.red))
            }
            )
            .alert(isPresented: $showingDeleteAlert) {
                Alert(title: Text("WARNING!"),
                      message: Text("Do you really want to delete all log data?"),
                      primaryButton: .destructive(Text("Yes")) {
                    self.deleteAllRecords()},
                      secondaryButton: .cancel()
                )
            }
            
        }
    }
    
    // MARK: - Удаление всех записей журнала
    func deleteAllRecords() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try moc.execute(deleteRequest)
            try moc.save()
            moc.reset()
        } catch {
            print ("There was an error")
        }
        
    }

    
    // MARK: - Toggle Notification
    func toggleAction(){
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
    }
    
}
