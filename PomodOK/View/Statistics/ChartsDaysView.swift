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

struct ChartData {
     var label: String
     var value: Int
 }

struct ChartsDaysView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
  
    
    var body: some View {
        
        let chartDataSet = [
             ChartData(label: "Mo", value: checkItemDaysOfTheWeek(days: "Monday")),
             ChartData(label: "Tu", value: checkItemDaysOfTheWeek(days: "Tuesday")),
             ChartData(label: "We", value: checkItemDaysOfTheWeek(days: "Wednesday")),
             ChartData(label: "Th", value: checkItemDaysOfTheWeek(days: "Thursday")),
             ChartData(label: "Fr", value: checkItemDaysOfTheWeek(days: "Friday")),
             ChartData(label: "Sa", value: checkItemDaysOfTheWeek(days: "Saturday")),
             ChartData(label: "Su", value: checkItemDaysOfTheWeek(days: "Sunday"))
        ]
        
        VStack(alignment: .center) {
            Text("Statistics for the day")
                .font(Font.system(size:24, design: .default))
                .padding()
            
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
                        Text("The Best Day: ")
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
        case "Sa": return "Sunday"
        default:
            return ""
        }
        
    }
    
    func checkItemDaysOfTheWeek(days: String) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "dayWeek BEGINSWITH %@", days)
        return ((try? viewContext.count(for: fetchRequest)) ?? 0)
    }
    
}

struct ChartsDaysView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsDaysView()
    }
}
