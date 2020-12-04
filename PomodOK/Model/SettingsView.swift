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
    
    
    init()
    {
        UISwitch.appearance().onTintColor = .red
    }

    
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

                    Stepper(value: $userSettings.workSession, in: 0...60) {
                        Text("Work Session \(userSettings.workSession) min")
                    }
                    
                    Stepper(value: $userSettings.shortBreak, in: 0...60) {
                        Text("Short Break \(userSettings.shortBreak) min")
                    }

                    Stepper(value: $userSettings.longBreak, in: 0...60) {
                        Text("Long Break \(userSettings.longBreak) min")
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
    
    
    ///
//    @State var isPresented = false
//
//    var body: some View {
//        
//        ZStack {
//            
//            NavigationView {
//                VStack {
//                    
//                    Button(action: {
//                        // trigger modal presentation
//                        withAnimation {
//                            self.isPresented.toggle()
//                        }
//                        
//                    }, label: {
//                        Text("Show standard modal")
//                    })
//                    
//                }.navigationBarTitle("Standard")
//            }
//            
//            ZStack {
//                HStack {
//                    Spacer()
//                    VStack {
//                        
//                        HStack {
//                            Button(action: {
//                                // trigger modal presentation
//                                withAnimation {
//                                    self.isPresented.toggle()
//                                }
//                                
//                            }, label: {
//                                Text("Dismiss")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                            })
//                            Spacer()
//                            
//                            Image(systemName: "xmark.circle.fill")
//                                .foregroundColor(.white)
//                                .onTapGesture {
//                                    withAnimation {
//                                        self.isPresented.toggle()
//                                    }
//                            }
//                        }
//                        
//                        
//                            .padding(.top, UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.safeAreaInsets.top)
//                        Spacer()
//                    }
//                    Spacer()
//                }
//                
//                
//                
//            }.background(Color.yellow)
//                .edgesIgnoringSafeArea(.all)
//                .offset(x: 0, y: self.isPresented ? 0 : UIApplication.shared.keyWindow?.frame.height ?? 0)
//             
//            
//        }
//        
//    }
    
    
    ////
    
    
}
