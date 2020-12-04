//
//  StatisticChartView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 04.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI
import CoreData

struct StatisticChartView: View {

    let hours: [String] = ["6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22"]
    let days: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let months: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    let daysShort: [String] = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    let monthsShort: [String] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]

    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]
    )
    
    var items: FetchedResults<Item>
    
    // Метод отображения даты (формат: 1 October 2020, 13:04)
    let itemFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter

    }()
    
    var body: some View {
        
//        List {
//            ForEach(days, id: \.self) { day in
//
//                DynamicFetchView(predicate: NSPredicate(format: "dayWeek==%@", day as String),
//                                 sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]) { (events: FetchedResults<Item>) in
//
//                    ForEach(events, id: \.self) { event in
//                        //Text(event.dayWeek ?? "")
//                        Text("\(event.timestamp!, formatter: itemFormatter)")
//                    }
//
//                    Text("В \(day) \(String(events.count)) события")
//                        .font(.headline)
//                        .foregroundColor(Color(.red))
//                }
//            }
//        }
        
        //-----
        
        Text("Statistics for the hours")
            .padding()
        HStack(alignment: .bottom, spacing: 8) {
            
            ForEach(hours, id: \.self) { hour in
                
                DynamicFetchView(predicate: NSPredicate(format: "hour==%@", hour as String),
                                 sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]) { (events: FetchedResults<Item>) in
                    
                    BarHours(percent: CGFloat(events.count) , hourChart: hour).frame(alignment: .bottom)
                    
                }
                
            }
        }
        
        Text("Statistics for the week")
            .padding()
        
        HStack(alignment: .bottom, spacing: 8) {
            
            ForEach(daysShort, id: \.self) { day in
                
                DynamicFetchView(predicate: NSPredicate(format: "dayWeek BEGINSWITH %@", day as String),
                                 sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]) { (events: FetchedResults<Item>) in
                    
                    BarDays(percent: CGFloat(events.count) , dayChart: day).frame(alignment: .bottom)
                }
            }
        }
        
        Text("Statistics for the month")
            .padding()
        HStack(alignment: .bottom, spacing: 8) {
            
            ForEach(monthsShort, id: \.self) { month in
                
                DynamicFetchView(predicate: NSPredicate(format: "month BEGINSWITH %@", month as String),
                                 sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]) { (events: FetchedResults<Item>) in
                    
                    BarMonths(percent: CGFloat(events.count) , monthChart: month).frame(alignment: .bottom)
                    
                }
                
            }
        }
        
        Spacer()
    }
}

// График статистики по часам
struct BarHours : View {
    
    var percent : CGFloat = 0
    var hourChart = ""
    
    var body : some View {
        
        VStack {
            
            Text(String(format: "%.0f", Double(percent))).foregroundColor(Color.white.opacity(0.5))
            
            Rectangle().fill(Color.red).frame(width: UIScreen.main.bounds.width / 17 - 12, height: getHeight())
            
            Text(hourChart).foregroundColor(Color.yellow.opacity(0.5)).font(Font.system(size: 12, design: .default))
        }
    }
    
    func getHeight()->CGFloat{
        
        return 200 / 100 * percent
    }
}

// График статистики по дням
struct BarDays : View {
    
    var percent : CGFloat = 0
    var dayChart = ""
    
    var body : some View {
        
        VStack {
            
            Text(String(format: "%.0f", Double(percent))).foregroundColor(Color.white.opacity(0.5))
            
            Rectangle().fill(Color.red).frame(width: UIScreen.main.bounds.width / 7 - 12, height: getHeight())
            
            Text(dayChart).foregroundColor(Color.yellow.opacity(0.5))
        }
    }
    
    func getHeight()->CGFloat{
        
        return 200 / 100 * percent
    }
}

// График статистики по месяцам
struct BarMonths : View {
    
    var percent : CGFloat = 0
    var monthChart = ""
    
    var body : some View {
        
        VStack {
            
            Text(String(format: "%.0f", Double(percent))).foregroundColor(Color.white.opacity(0.5))
            
            Rectangle().fill(Color.red).frame(width: UIScreen.main.bounds.width / 12 - 12, height: getHeight())
            
            Text(monthChart).foregroundColor(Color.yellow.opacity(0.5))
        }
    }
    
    func getHeight()->CGFloat{
        
        return 200 / 100 * percent
    }
}


