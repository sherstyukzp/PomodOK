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
    @AppStorage("longBreak") var longBreak: Int = 15
    @AppStorage("countPomodoro") var countPomodoro: Int = 0 // Кількість виконаних таймерів
    
    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = true
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isVibrationEnabled") var isVibrationEnabled: Bool = true
    
    @State private var showingStatisticsView = false // Button Statistics
    @State private var showingSettingsView = false // Button Settings
    
    @State private var showAlert = false // Alert
    @State private var showShortBreak = false // show Short Break
    @State private var showLongBreak = false // show Short Break
    
    @State var start = false // Старт таймеру
    @State var to : CGFloat = 0 // Повзунок часу
    @State var count = 0 // Скільки залишилося часу
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                switch countPomodoro {
                case 0:
                    PanelPomodoroView(tomato1: .constant(false), tomato2: .constant(false), tomato3: .constant(false), tomato4: .constant(false))
                        .padding()
                case 1:
                    PanelPomodoroView(tomato1: .constant(true), tomato2: .constant(false), tomato3: .constant(false), tomato4: .constant(false))
                        .padding()
                case 2:
                    PanelPomodoroView(tomato1: .constant(true), tomato2: .constant(true), tomato3: .constant(false), tomato4: .constant(false))
                        .padding()
                case 3:
                    PanelPomodoroView(tomato1: .constant(true), tomato2: .constant(true), tomato3: .constant(true), tomato4: .constant(false))
                        .padding()
                case 4:
                    PanelPomodoroView(tomato1: .constant(true), tomato2: .constant(true), tomato3: .constant(true), tomato4: .constant(true))
                        .padding()
                default:
                    PanelPomodoroView(tomato1: .constant(false), tomato2: .constant(false), tomato3: .constant(false), tomato4: .constant(false))
                        .padding()
                }
                
                
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color("redColor"))
                        .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)
                    
                    VStack {
                        Text("Work Session")
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
                CustomTabBarView(showingStatisticsView: $showingStatisticsView, showingSettingsView: $showingSettingsView, start: $start, retrieved: $workSession, count: $count, to: $to, notifications: $isNotificationsEnabled).padding(.bottom)
                
            }
            
            .navigationBarTitle(Text("PomodOK"), displayMode: .large)
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
                    print ("👉 Stop")
                    self.start.toggle()
                    
                    //--- Воспроизведение стандартного звука после завершения таймера
                    isSoundEnabled == true ? AudioServicesPlaySystemSound (systemSoundID): nil
                    //--- Вибро после завершения таймера
                    isVibrationEnabled == true ? AudioServicesPlaySystemSound(kSystemSoundID_Vibrate): nil
                    
                    addItem()
                    print ("👉 Save Item")
                    
                    notificationPublisher.deleteNotification(identifier: "timerPomodOK")
                    
                    // Додавання виконаного таймера
                    if countPomodoro < 4 {
                        countPomodoro += 1
                    } else {
                        countPomodoro = 1
                    }
                    self.showAlert.toggle()
                    print ("👉 showAlert")
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
                    if countPomodoro < 4 {
                        if isNotificationsEnabled {
                            notificationPublisher.addNotification(identifier: "ShortBreakPomodOK", titleNotification: "PomodOK", subtitleNotification: "The end of rest", bodyNotification: "Time to get to work!!!", timeInterval: TimeInterval(shortBreak * 60))
                        }
                        self.showShortBreak.toggle()
                    } else {
                        if isNotificationsEnabled {
                            notificationPublisher.addNotification(identifier: "LongBreakPomodOK", titleNotification: "PomodOK", subtitleNotification: "All timers are completed", bodyNotification: "You worked well, it's time to relax well!!!", timeInterval: TimeInterval(longBreak * 60))
                        }
                        self.showLongBreak.toggle()
                    }
                    
                })
            )
        }
        
        .fullScreenCover(isPresented: $showShortBreak) {
            ShortBreakView(shortBreak: $shortBreak)
        }
        .fullScreenCover(isPresented: $showLongBreak) {
            ShortBreakView(shortBreak: $longBreak)
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







