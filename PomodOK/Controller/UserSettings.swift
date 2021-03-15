//
//  UserSettings.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 11.09.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//
// Source
// https://www.simpleswiftguide.com/how-to-use-userdefaults-in-swiftui/

import Foundation
import Combine

class UserSettings: ObservableObject {
    
    @Published var isNotificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isNotificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
        }
    }
    
    @Published var isVibrationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isVibrationEnabled, forKey: "vibrationEnabled")
        }
    }
    
    @Published var workSession: Int {
        didSet {
            UserDefaults.standard.set(workSession, forKey: "workSession")
        }
    }
    
    @Published var shortBreak: Int {
        didSet {
            UserDefaults.standard.set(shortBreak, forKey: "shortBreak")
        }
    }
    
    @Published var longBreak: Int {
        didSet {
            UserDefaults.standard.set(longBreak, forKey: "longBreak")
        }
    }
    
    @Published var isSetupApp: Int {
        didSet {
            UserDefaults.standard.set(isSetupApp, forKey: "setupApp")
        }
    }
    
    @Published var isSavedVersion: String {
        didSet {
            UserDefaults.standard.set(isSavedVersion, forKey: "savedVersion")
        }
    }

    init() {
        self.isNotificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        self.isVibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        
        self.workSession = UserDefaults.standard.object(forKey: "workSession") as? Int ?? 25
        self.shortBreak = UserDefaults.standard.object(forKey: "shortBreak") as? Int ?? 5
        self.longBreak = UserDefaults.standard.object(forKey: "longBreak") as? Int ?? 15
        
        self.isSetupApp = UserDefaults.standard.object(forKey: "setupApp") as? Int ?? 0
        self.isSavedVersion = UserDefaults.standard.string(forKey: "savedVersion") ?? "nil"
        
    }
}
