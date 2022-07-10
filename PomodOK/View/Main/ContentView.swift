//
//  ContentView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 04.09.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//
// Source
// https://www.youtube.com/watch?v=sBJ7rv4nhuk
// https://kavsoft.tech/Swift/Timer/

import SwiftUI
import Combine
import CoreData
import AVFoundation
import AudioToolbox

struct ContentView : View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.scenePhase) var scenePhase
    
    var notificationPublisher = NotificationManager()
    
    // MARK: - Variables
    //--- Settings
    @AppStorage("workSession") var workSession: Int = 25
    @AppStorage("shortBreak") var shortBreak: Int = 5
    @AppStorage("shortBreak") var longBreak: Int = 15
    
    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = true
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isVibrationEnabled") var isVibrationEnabled: Bool = true
    
    @State private var showingStatisticsView = false // Button Statistics
    @State private var showingSettingsView = false // Button Settings
    
    @State private var showAlert = false // Alert
    @State private var showShortBreak = false // show Short Break
    
    @State var start = false // Старт таймеру
    @State var to : CGFloat = 0 // Повзунок часу
    @State var count = 0 // Скільки залишилося часу
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var tomato1 = true
    @State var tomato2 = false
    @State var tomato3 = false
    @State var tomato4 = false
    
    @State private var date = Date()
    
    @State private var showWhatsNew = false // Programatic show Whats New version
    @State private var setupApp = UserDefaults.standard.integer(forKey: "setupApp")
    // Variable to trigger WhatsNew Screen
    @State private var savedVersion = UserDefaults.standard.string(forKey: "savedVersion")
    
    //--- Sound ID
    let systemSoundID: SystemSoundID = 1313
    
    // Получить текущую версию приложения
    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)
        
        return version
    }
    
    // Проверьте, было ли приложение запущено после обновления
    func checkForUpdate() {
        let version = getCurrentAppVersion()
        
        if savedVersion == version {
            print("App is up to date!")
        } else {
            // Переключите, чтобы отображать экран "Что нового" как модальный
            self.showWhatsNew.toggle()
            UserDefaults.standard.set(version, forKey: "savedVersion")
        }
    }
    
    // MARK: - Body
    var body: some View {
        
        NavigationView {
            VStack {
                // Панель с количеством завершенных томатов
                PanelPomodoroView(tomato1: $tomato1, tomato2: $tomato2, tomato3: $tomato3, tomato4: $tomato4)
                    .padding()
                
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color("redColor"))
                        .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)
                    
                    VStack {
                        Text("Work session")
                            .foregroundColor(Color.white)
                            .font(.system(size: 32))
                            .fontWeight(.medium)
                            .padding(.bottom)
                        // Прогресс таймера
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
                            
                            // Секунды
                            VStack {
                                Text(secondsToMinutesAndSeconds(seconds: (workSession * 60) - count))
                                    .font(.system(size: 54))
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                
                                Text("Of \(workSession) min")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }.padding()
                
                // MARK: - Tab bar
                CustomTabBarView(showingStatisticsView: $showingStatisticsView, showingSettingsView: $showingSettingsView, start: $start, retrieved: $workSession, count: $count, to: $to, showShortBreak: $showShortBreak, notifications: $isNotificationsEnabled, sound: $isSoundEnabled, vibration: $isVibrationEnabled).padding(.bottom)
                
            }
            
            .navigationBarTitle(Text("Cycle"), displayMode: .large)
            .navigationBarItems(trailing:
                                    // Butoon Restart
                                Button(action: {
                self.count = 0
                withAnimation(.default) {
                    self.to = 0
                }
                
                notificationPublisher.deleteNotification(identifier: "timerPomodOK")
                
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Reset")
                }
                .foregroundColor(Color(.gray))
            }
            )
        }
        
        
        .onReceive(self.time) { (_) in
            if self.start {
                if self.count != self.workSession * 60 {
                    self.count += 1
                    withAnimation(.default) {
                        self.to = CGFloat(self.count) / CGFloat(self.workSession * 60)
                    }
                } else {
                    print ("👉  Stop")
                    self.start.toggle()
                    self.showAlert.toggle()
                    print ("👉 showAlert")
                    //--- Воспроизведение стандартного звука после завершения таймера
                    isSoundEnabled == true ? AudioServicesPlaySystemSound (systemSoundID): nil
                    //--- Вибро после завершения таймера
                    isVibrationEnabled == true ? AudioServicesPlaySystemSound(kSystemSoundID_Vibrate): nil
                    
                    addItem()
                    print ("👉 Save Item")
                    
                    
                    notificationPublisher.deleteNotification(identifier: "timerPomodOK")
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Timer Is Completed"),
                message: Text("Timer Is Completed Successfully!!!"),
                primaryButton: .default(Text("Continue"), action: {
                    print("👉 Continue")
                    self.count = 0
                    withAnimation(.default) {
                        self.to = 0
                    }
                    self.start.toggle()
                }),
                secondaryButton: .default(Text("Break"), action: {
                    print("👉 Break")
                    self.showShortBreak.toggle()
                })
            )
            
        }
        .fullScreenCover(isPresented: $showShortBreak) {
            ShortBreakView(shortBreak: $shortBreak)
        }
        .sheet(isPresented: $showWhatsNew, content: { WhatsNew() })
        
        .onAppear(perform: checkForUpdate) // Run checkForUpdate when View Appears
        .onAppear {
            AppReviewRequest.requestReviewIfNeeded()
        }
    }
    
    
    // MARK: - Save Item
    func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = self.date
            newItem.hour = ItemFormatter.init().itemFormatterHour.string(from: date)
            newItem.dayWeek = ItemFormatter.init().itemFormatterNameDayOfTheWeek.string(from: date)
            newItem.month = ItemFormatter.init().itemFormatterNameMonthNumber.string(from: date)
            newItem.year = ItemFormatter.init().itemFormatterNameYear.string(from: date)
            
            print ("👉 SaveData")
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Метод для отображения минут и секунд
    func secondsToMinutesAndSeconds(seconds: Int) -> String {
        let minutes = "\((seconds % 3600) / 60)"
        let seconds = "\((seconds % 3600) % 60)"
        let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
        let secondStamp = seconds.count > 1 ? seconds : "0" + seconds
        
        return "\(minuteStamp):\(secondStamp)"
    }
    
    /// Converts Int (time) to string.
    func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        
        return String(format: "%02i:%02i", minute, second)
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.colorScheme, .light)
    }
}







