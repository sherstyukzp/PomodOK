//
//  StatisticChartDaysView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 10.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct StatisticChartDaysView: View {
    
    //MARK: - Variables
    let days: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let daysShort: [String] = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    
    var body: some View {
        
        Text("Statistics for the week")
            .padding()
        
        HStack(alignment: .bottom, spacing: 8) {
            
            ForEach(daysShort, id: \.self) { day in
                
                DynamicFetchView(predicate: NSPredicate(format: "dayWeek BEGINSWITH %@", day as String),
                                 sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]) { (events: FetchedResults<Item>) in
                    
                    BarDaysView(percent: CGFloat(events.count) , dayChart: day).frame(alignment: .bottom)
                }
            }
        }
        Spacer()
    }
}


