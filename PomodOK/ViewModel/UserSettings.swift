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
        self.isSetupApp = UserDefaults.standard.object(forKey: "setupApp") as? Int ?? 0
        self.isSavedVersion = UserDefaults.standard.string(forKey: "savedVersion") ?? "nil"
        
    }
}
