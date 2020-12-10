//
//  StatisticChartDaysView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 10.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct StatisticChartHoursView: View {
    
    //MARK: - Variables
    let hours: [String] = ["06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22"]
    
    var body: some View {
        Text("Statistics for the hours")
            .padding()
        HStack(alignment: .bottom, spacing: 8) {
            
            ForEach(hours, id: \.self) { hour in
                
                DynamicFetchView(predicate: NSPredicate(format: "hour==%@", hour as String),
                                 sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]) { (events: FetchedResults<Item>) in
                    
                    BarHoursView(percent: CGFloat(events.count) , hourChart: hour).frame(alignment: .bottom)
                    
                }
                
            }
        }
    }
}

