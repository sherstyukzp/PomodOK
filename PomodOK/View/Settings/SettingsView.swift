//
//  SettingsView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 06.09.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//
// Source
// https://www.simpleswiftguide.com/how-to-use-userdefaults-in-swiftui/

import SwiftUI
import CoreData
import StoreKit

struct SettingsView: View {

    @Environment(\.presentationMode) var presentationMode
    // MARK: - Core Data
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var userSettings = UserSettings()
    
    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = true
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isVibrationEnabled") var isVibrationEnabled: Bool = true
    
    @AppStorage("workSession") var workSession: Int = 25
    @AppStorage("shortBreak") var shortBreak: Int = 5
    @AppStorage("longBreak") var longBreak: Int = 15
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\Item.timestamp, order: .reverse)])
    var fetchedItems: FetchedResults<Item>
    // MARK: - @State
    @State private var showingDeleteAlert = false
    @State private var isExportCSVSheetShowing = false
    
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
                Section(header: HeaderSettingView(imageIcon: "bell", text: "NOTIFICATIONS")) {
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
                
                Section(header: HeaderSettingView(imageIcon: "deskclock", text: "TIMER")) {
                    
                    Stepper(value: $workSession, in: 1...60) {
                        Text("Work Session \(workSession) min")
                    }
                    Stepper(value: $shortBreak, in: 1...60) {
                        Text("Short Break \(shortBreak) min")
                    }
                    Stepper(value: $longBreak, in: 1...60) {
                        Text("Long Break \(longBreak) min")
                    }
                }
                
                if !fetchedItems.isEmpty {
                    Section(header: HeaderSettingView(imageIcon: "tray.2", text: "Data")) {
                        // Экспорт
                        Button {
                            exportOverlayCSV()
                        } label: {
                            Label("Export in CSV", systemImage: "square.and.arrow.up")
                        }
                        // ивдалення всіх даних
                        Button {
                            self.showingDeleteAlert = true
                        } label: {
                            Label("Delete All", systemImage: "trash")
                        }
                    }
                }
                
                Section(header: HeaderSettingView(imageIcon: "info.circle", text: "About")) {
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
                        if let windowScene = UIApplication.shared.windows.first?.windowScene { SKStoreReviewController.requestReview(in: windowScene) }
                    }) {
                        Text("Rate the application")
                    }
                }
                
                Section(header: HeaderSettingView(imageIcon: "bubble.left", text: "Contact Us")) {
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
    // MARK: - Export object CSV
    func exportOverlayCSV() {
        let fileName = "PomodOK.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Date\n"
        
        for object in fetchedItems {
            csvText += "\(object.timestamp?.formatted() ?? "Not Item")\n"
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        print(path ?? "not found")
        
        var filesToShare = [Any]()
        filesToShare.append(path!)
        
        let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        
        if let vc = UIApplication.shared.windows.first?.rootViewController{
            av.popoverPresentationController?.sourceView = vc.view
            //Setup share activity position on screen on bottom center
            av.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 0, height: 0)
            av.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            vc.present(av, animated: true, completion: nil)
        }
        
        isExportCSVSheetShowing.toggle()
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
