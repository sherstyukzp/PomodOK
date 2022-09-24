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
  
    
    var body: some View {
        
        VStack {
            Text("Statistics for the day")
                .font(Font.system(size:24, design: .default))
                .padding()
            Chart {
                BarMark(
                    x: .value("Days", "Mo"),
                    y: .value("Value", checkItemDaysOfTheWeek(days: "Monday"))
                )
                BarMark(
                    x: .value("Days", "Tu"),
                    y: .value("Value", checkItemDaysOfTheWeek(days: "Tuesday"))
                )
                BarMark(
                    x: .value("Days", "We"),
                    y: .value("Value", checkItemDaysOfTheWeek(days: "Wednesday"))
                )
                BarMark(
                    x: .value("Days", "Th"),
                    y: .value("Value", checkItemDaysOfTheWeek(days: "Thursday"))
                )
                BarMark(
                    x: .value("Days", "Fr"),
                    y: .value("Value", checkItemDaysOfTheWeek(days: "Friday"))
                )
                BarMark(
                    x: .value("Days", "Sa"),
                    y: .value("Value", checkItemDaysOfTheWeek(days: "Saturday"))
                )
                BarMark(
                    x: .value("Days", "Su"),
                    y: .value("Value", checkItemDaysOfTheWeek(days: "Sunday"))
                )
            }.foregroundColor(Color("redColor"))
            .frame(height: 250)
            .padding()
        }
        Spacer()
        
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
