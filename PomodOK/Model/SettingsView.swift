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

struct SettingsView: View {
   
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var userSettings = UserSettings()
    
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
                Section(header: Text("NOTIFICATIONS")) {
                    Toggle(isOn: $userSettings.isNotificationsEnabled) {
                        Text("Push notifications")
                    }
                    Toggle(isOn: $userSettings.isSoundEnabled) {
                        Text("Sound")
                    }
                    Toggle(isOn: $userSettings.isVibrationEnabled) {
                        Text("Vibration")
                    }
                }
                
                Section(header: Text("TIMER")) {

                    Stepper(value: $userSettings.workSession, in: 1...60) {
                        Text("Work Session \(userSettings.workSession) min")
                    }
                    Stepper(value: $userSettings.shortBreak, in: 1...60) {
                        Text("Short Break \(userSettings.shortBreak) min")
                    }
                    Stepper(value: $userSettings.longBreak, in: 1...60) {
                        Text("Long Break \(userSettings.longBreak) min")
                    }
                }
                
                Section(header: Text("About")) {
                                    HStack {
                                        Text("Software Version")
                                        Spacer()
                                        Text("\(appVersion) (\(buildNumber))")
                                    }
                                }
            }
            .navigationBarTitle(Text("Settings"), displayMode: .large)
            .navigationBarItems(trailing:
                    // Butoon Save
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                            .bold()
                            .foregroundColor(Color(.red))
                    }
            )
        }
        .onDisappear() {
            //print ("onDisappear")
            //UserDefaults.standard.set(self.retrieved, forKey: "workSession")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }

}
