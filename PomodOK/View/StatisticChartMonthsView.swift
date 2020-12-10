//
//  StatisticChartMonthsView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 10.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct StatisticChartMonthsView: View {
    
    //MARK: - Variables
    //let months: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let monthsShort: [String] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    
    var body: some View {
        
        Text("Statistics for the month")
            .padding()
        HStack(alignment: .bottom, spacing: 8) {
            
            ForEach(monthsShort, id: \.self) { month in
                
                DynamicFetchView(predicate: NSPredicate(format: "month BEGINSWITH %@", month as String),
                                 sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]) { (events: FetchedResults<Item>) in
                    
                    BarMonthsView(percent: CGFloat(events.count) , monthChart: month).frame(alignment: .bottom)
                    
                }
                
            }
        }
        Spacer()
    }
}

