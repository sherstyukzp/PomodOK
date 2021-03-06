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

@available(iOS 14.0, *)
struct ContentView : View {
    
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var userSettings = UserSettings()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Item>
    
    // MARK: - Variables
    @State var showingStatisticsView = false
    @State private var showingSettingsView = false
    
    @State var start = false
    @State var to : CGFloat = 0
    @State var count = 0
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var tomato1 = true
    @State var tomato2 = false
    @State var tomato3 = false
    @State var tomato4 = false
    
    //--- Settings
    @State var retrieved = 0
    @State var shortBreak = 0
    @State var sound = true
    @State var vibration = true
    @State var notifications = true
    
    @State var showAlert = false
    @State private var showShortBreak = false
    
    @State private var date = Date()
    @State private var day = ""
    @State private var textSession = "Work session"
    
    @State private var setupApp = UserDefaults.standard.integer(forKey: "setupApp")
    // Variable to trigger WhatsNew Screen
    @State private var savedVersion = UserDefaults.standard.string(forKey: "savedVersion")
    
    @State private var showWhatsNew = false
    
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
        ZStack {
            
            NavigationView {
                
                VStack {
                    // Панель с количеством завершенных томатов
                    PanelPomodoroView(tomato1: $tomato1, tomato2: $tomato2, tomato3: $tomato3, tomato4: $tomato4)
                    
                    Spacer()
                
                    ZStack {

                        GeometryReader { geometry in
                                        VStack {
                                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                            .fill(Color("redColor"))
                                            .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)
                                        }.foregroundColor(.white)
                                    }.padding()
                        VStack {
                            Text("Work session")
                            .foregroundColor(Color.white)
                            .font(.system(size: 30))
                            .fontWeight(.medium)
                            .padding()

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
                                    Text(secondsToMinutesAndSeconds(seconds: retrieved - count))

                                        .font(.system(size: 60))
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)

                                    Text("Of \(retrieved / 60) min")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .padding(.top)
                                }
                            }
                            .padding(.bottom, 30)
                        }

                    }
                    Spacer()
                    Spacer()

                    // MARK: - Tab bar
                    HStack {
                        // Кнопка Статистика
                            Button(action: {
                                self.showingStatisticsView.toggle()
                            }) {
                                VStack(spacing:0) {
                                    Image(systemName: "chart.bar")
                                        .resizable()
                                        .foregroundColor(Color.gray)
                                        .aspectRatio(contentMode: .fit)
                                        .padding(5)
                                        .frame(width: 40, height: 40, alignment: .center)
                                        .cornerRadius(6)
                                }
                                .frame(width: 100, height: 50)
                            }
                            .sheet(isPresented: $showingStatisticsView) {
                                StatisticView()
                            }
                            Spacer()
                        
                        // MARK: - Button Start Timer
                            Button(action: {
                                
                                if self.count == self.retrieved {
                                    
                                    self.count = 0
                                    withAnimation(.default){
                                        
                                        self.to = 0
                                    }
                                }
                                self.start.toggle()
                                
                            }) {
                                Image(systemName: self.start ? "pause.circle" : "arrowtriangle.right.circle")
                                    .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 90, height: 90)
                                
                            }
                            .frame(width: 70, height: 70, alignment: .center)
                            .background(Color("redColor"))
                            .cornerRadius(70/2)
                            .shadow(radius: 5)
                            
                            Spacer()
                        // MARK: - Button Settings
                            Button(action: {
                                self.showingSettingsView.toggle()
                            }) {
                                VStack(spacing:0) {
                                    Image(systemName: "gear")
                                        .resizable()
                                        .foregroundColor(Color.gray)
                                        .padding(5)
                                        .frame(width: 40, height: 40, alignment: .center)
                                        .cornerRadius(6)
                                }
                                .frame(width: 100, height: 50)
                                
                            }.sheet(isPresented: $showingSettingsView, onDismiss: {
                                
                                print("In DetailView onDismiss.")
                                self.loadData()
                            }) { SettingsView() }
                        
                        }
                        .frame(minHeight: 70)
            
                }
                .alert(isPresented:$showAlert) {
                            Alert(title: Text("Short break?"), message: Text("Will you take a short break?"), primaryButton: .destructive(Text("Yes")) {
                                self.showShortBreak.toggle()
                            }, secondaryButton: .cancel())}
                
                .onAppear(perform: loadData)
                .navigationBarTitle(Text("Cycle"), displayMode: .large)
                .navigationBarItems(trailing:
                        // Butoon Restart
                        Button(action: {
                            
                            self.count = 0
                            withAnimation(.default){
                                self.to = 0
                            }
                            
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset")
                            }
                            .foregroundColor(Color(.gray))
                        }
                )
            }
            // Экран Short Break
            ZStack {
                
                VStack {
                    Spacer()
                    Text ("Relax for another \(shortBreak / 60) minutes")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20.0)
                        
                    
                    Spacer()
                    
                    Image("relaxing")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaledToFit()
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            self.showShortBreak.toggle()
                        }
                    }) {
                        HStack {
                            Text("Сancel")
                        }
                        .font(.system(size: 30))
                        .padding(15.0)
                        .frame(width: 200, height: 60, alignment: .center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20.0)
                                .stroke(lineWidth: 2.0)
                                .shadow(color: .blue, radius: 20.0)
                        )
                    }
                    Spacer()
                    
                }
                .background(Color(#colorLiteral(red: 0.9685428739, green: 0.9686816335, blue: 0.9685124755, alpha: 1)))
                
            }.background(Color(#colorLiteral(red: 0.9685428739, green: 0.9686816335, blue: 0.9685124755, alpha: 1)))
                .edgesIgnoringSafeArea(.all)
                .offset(x: 0, y: self.showShortBreak ? 0 : UIApplication.shared.keyWindow?.frame.height ?? 0)
//---------
            
            .onAppear(perform: {
                print ("onAppear perform")
                UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert]) { (_, _) in
                }
            })
            .onReceive(self.time) { (_) in

                if self.start {
                    if self.count != self.retrieved {

                        self.count += 1

                        withAnimation(.default){

                            self.to = CGFloat(self.count) / CGFloat(self.retrieved)
                        }
                    }
                    else {
                    print ("Stop")
                        self.start.toggle()
                        //--- Уведомление когда приложение свёрнуто
                        notifications == true ? self.Notify(): nil

                        //----
                        withAnimation {
                            self.showAlert.toggle()
                            print ("Stop-2")
                            //--- Воспроизведение стандартного звука после завершения таймера
                            sound == true ? AudioServicesPlaySystemSound (systemSoundID): nil
                            //--- Вибро после завершения таймера
                            vibration == true ? AudioServicesPlaySystemSound(kSystemSoundID_Vibrate): nil

                            addItem()
                        }
                    }
                }
            }
        }
        
        .sheet(isPresented: $showWhatsNew, content: { WhatsNew() })
            .onAppear(perform: checkForUpdate) // Run checkForUpdate when View Appears
            .onAppear {
                AppReviewRequest.requestReviewIfNeeded()
            }
    }
    
    // MARK: - UserDefaults
    // Loading timer minutes, if the settings have not been changed, the default value is 25 minutes
    func loadData() {
        self.retrieved = (UserDefaults.standard.object(forKey: "workSession") as? Int ?? 25) * 60
        self.shortBreak = (UserDefaults.standard.object(forKey: "shortBreak") as? Int ?? 5) * 60
        self.notifications = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        self.sound = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        self.vibration = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        
        print ("👉 loadData")

    }
    
    // MARK: - Core Data
    // MARK: - Save Item
    private func addItem() {
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Delete Item
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
    
    // MARK: - Notification
    // Method for triggering notification when the application is minimized
    func Notify() {
        
        let content = UNMutableNotificationContent()
        content.title = "Timer Is Completed"
        content.body = "Timer Is Completed Successfully In Background !!!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let req = UNNotificationRequest(identifier: "MSG", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }
    
    
    /// Converts Int (time) to string.
    func timeString(time: TimeInterval) -> String {
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        
        return String(format: "%02i:%02i", minute, second)
    }
    
}


@available(iOS 14.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
                    .environment(\.colorScheme, .light)
    }
}


