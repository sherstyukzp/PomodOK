//
//  ChartsDaysView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 24.09.2022.
//  Copyright © 2022 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI
import CoreData
import Charts


struct ChartsDaysView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.calendar) var calendar
    @Environment(\.timeZone) var timeZone

    @Binding var startDate: Date // This week
    @Binding var endDate: Date // Previous week
    
    var body: some View {
        
        let chartDataSet = [
            ChartDataModel(label: "Mo", value: checkItemDaysOfTheWeek(days: "Monday")),
            ChartDataModel(label: "Tu", value: checkItemDaysOfTheWeek(days: "Tuesday")),
            ChartDataModel(label: "We", value: checkItemDaysOfTheWeek(days: "Wednesday")),
            ChartDataModel(label: "Th", value: checkItemDaysOfTheWeek(days: "Thursday")),
            ChartDataModel(label: "Fr", value: checkItemDaysOfTheWeek(days: "Friday")),
            ChartDataModel(label: "Sa", value: checkItemDaysOfTheWeek(days: "Saturday")),
            ChartDataModel(label: "Su", value: checkItemDaysOfTheWeek(days: "Sunday"))
        ]
        
        VStack(alignment: .center) {
            Text("Statistics for the day")
                .font(Font.system(size:24, design: .default))
                .padding()
            Text("startDate: \(startDate.formatted(date: .abbreviated, time: .shortened))")
            Text("endDate: \(endDate.formatted(date: .abbreviated, time: .shortened))")
           
            Chart(chartDataSet, id: \.label) { item in
                BarMark(
                    x: .value("Day", item.label),
                    y: .value("Value", item.value)
                )
            }
            .foregroundColor(Color("redColor"))
            .frame(height: 250)
            .padding()
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    let maxDay = chartDataSet.max { a, b in a.value < b.value }
                    let minDay = chartDataSet.min { a, b in a.value < b.value }
                    Divider()
                    HStack {
                        Text("The best day: ")
                        Text("\(nameDayFull(day: maxDay?.label ?? ""))")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("The worst day: ")
                        Text("\(nameDayFull(day: minDay?.label ?? ""))")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
                Spacer()
            }.padding()
        }
        Spacer()
        
    }
    

    
    func nameDayFull(day: String) -> String {
        switch day {
        case "Mo": return "Monday"
        case "Tu": return "Tuesday"
        case "We": return "Wednesday"
        case "Th": return "Thursday"
        case "Fr": return "Friday"
        case "Sa": return "Saturday"
        case "Su": return "Sunday"
        default:
            return ""
        }
    }
    
//    func callThisDay(startDate: Date, endDate: Date) -> [Item] {
//        let fetchRequest : NSFetchRequest<Item> = Item.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
//        do {
//            return try viewContext.fetch(fetchRequest)
//        } catch {
//            print(error)
//            return []
//        }
//    }
//
//    func loadBreakfastItemsFromCoreData(at date: Date) -> [Item] {
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//
//        let startDate = Calendar.current.startOfDay(for: date)
//        var components = DateComponents()
//        components.day = 1
//        components.second = -1
//        let endDate = Calendar.current.date(byAdding: components, to: startDate)!
//
//        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
//        // Optional: You can sort by date
//        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//        do {
//            return try viewContext.fetch(request)
//        } catch {
//            print("Error fetching data from context: \(error)")
//        }
//        return []
//    }
    
    
    func checkItemDaysOfTheWeek(days: String) -> Int {
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        print(df.string(from: startDate)) // 2022-10-31 21:08:17 +0200
        
        print(df.string(from: endDate)) // 2022-11-06 21:08:17 +0200

        
        let filterDays = NSPredicate(format: "dayWeek BEGINSWITH %@", days)
        let filterPeriod = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate as NSDate, endDate as NSDate)
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [filterDays, filterPeriod])
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = andPredicate
        
        return ((try? viewContext.count(for: fetchRequest)) ?? 0)
    }
    
}

struct ChartsDaysView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsDaysView(startDate: .constant(Date()), endDate: .constant(Date()))
    }
}
