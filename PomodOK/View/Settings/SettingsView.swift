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
import StoreKit

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userSettings = UserSettings()
    
    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = true
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isVibrationEnabled") var isVibrationEnabled: Bool = true
    
    @AppStorage("workSession") var workSession: Int = 25
    @AppStorage("shortBreak") var shortBreak: Int = 5
    @AppStorage("longBreak") var longBreak: Int = 15
    
    
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
        }
    }
    
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
    
}
