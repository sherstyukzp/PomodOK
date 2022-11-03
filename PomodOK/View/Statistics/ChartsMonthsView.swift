//
//  ChartsMonthsView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 24.09.2022.
//  Copyright © 2022 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI
import CoreData
import Charts

struct ChartsMonthsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        
        let chartDataSet = [
            ChartDataModel(label: "Jan", value: checkItemDaysOfTheMonth(month: "01")),
            ChartDataModel(label: "Feb", value: checkItemDaysOfTheMonth(month: "02")),
            ChartDataModel(label: "Mar", value: checkItemDaysOfTheMonth(month: "03")),
            ChartDataModel(label: "Apr", value: checkItemDaysOfTheMonth(month: "04")),
            ChartDataModel(label: "May", value: checkItemDaysOfTheMonth(month: "05")),
            ChartDataModel(label: "Jun", value: checkItemDaysOfTheMonth(month: "06")),
            ChartDataModel(label: "Jul", value: checkItemDaysOfTheMonth(month: "07")),
            ChartDataModel(label: "Aug", value: checkItemDaysOfTheMonth(month: "08")),
            ChartDataModel(label: "Sep", value: checkItemDaysOfTheMonth(month: "09")),
            ChartDataModel(label: "Oct", value: checkItemDaysOfTheMonth(month: "10")),
            ChartDataModel(label: "Nov", value: checkItemDaysOfTheMonth(month: "11")),
            ChartDataModel(label: "Dec", value: checkItemDaysOfTheMonth(month: "12"))
        ]
        
        VStack {
            Text("Statistics for the month")
                .font(Font.system(size:24, design: .default))
                .padding()
            
            Chart(chartDataSet, id: \.label) { item in
                BarMark(
                    x: .value("Month", item.label),
                    y: .value("Value", item.value)
                )
            }
            .foregroundColor(Color("redColor"))
            .frame(height: 250)
            .padding()
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    let maxMonth = chartDataSet.max { a, b in a.value < b.value }
                    let minMonth = chartDataSet.min { a, b in a.value < b.value }
                    Divider()
                    HStack {
                        Text("The best month: ")
                        Text("\(nameMonthFull(month: maxMonth?.label ?? ""))")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("The worst month: ")
                        Text("\(nameMonthFull(month: minMonth?.label ?? ""))")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
                Spacer()
            }
            .padding()
        }
        Spacer()
    }
    
    func nameMonthFull(month: String) -> String {
        
        switch month {
        case "Jan": return "January"
        case "Feb": return "February"
        case "Mar": return "March"
        case "Apr": return "April"
        case "May": return "May"
        case "Jun": return "June"
        case "Jul": return "July"
        case "Aug": return "August"
        case "Sep": return "September"
        case "Oct": return "October"
        case "Nov": return "November"
        case "Dec": return "December"
        default:
            return ""
        }
    }
    
    func checkItemDaysOfTheMonth(month: String) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "month BEGINSWITH %@", month)
        return ((try? viewContext.count(for: fetchRequest)) ?? 0)
    }
    
}

struct ChartsMonthsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsMonthsView()
    }
}
