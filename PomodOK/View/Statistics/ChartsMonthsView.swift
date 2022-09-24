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
        VStack {
            Text("Statistics for the month")
                .font(Font.system(size:24, design: .default))
                .padding()
            Chart {
                BarMark(
                    x: .value("Month", "Jan"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "01"))
                )
                BarMark(
                    x: .value("Month", "Feb"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "02"))
                )
                BarMark(
                    x: .value("Month", "Mar"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "03"))
                )
                BarMark(
                    x: .value("Month", "Apr"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "04"))
                )
                BarMark(
                    x: .value("Month", "May"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "05"))
                )
                BarMark(
                    x: .value("Month", "Jun"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "06"))
                )
                BarMark(
                    x: .value("Month", "Jul"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "07"))
                )
                BarMark(
                    x: .value("Month", "Aug"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "08"))
                )
                BarMark(
                    x: .value("Month", "Sep"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "09"))
                )
                BarMark(
                    x: .value("Month", "Oct"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "10"))
                )
                BarMark(
                    x: .value("Month", "Nov"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "11"))
                )
                BarMark(
                    x: .value("Month", "Dec"),
                    y: .value("Value", checkItemDaysOfTheMonth(month: "12"))
                )
                
                
            }
            .frame(height: 250)
            .padding()
        }
        Spacer()
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
