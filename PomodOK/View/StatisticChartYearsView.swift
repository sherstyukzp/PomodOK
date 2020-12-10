//
//  StatisticChartYearsView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 10.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct StatisticChartYearsView: View {
    //MARK: - Variables
    let yearsShort: [String] = ["2020", "2021", "2022", "2023", "2024", "2025"]
    
    var body: some View {
        
        Text("Statistics for the year")
            .padding()
        HStack(alignment: .bottom, spacing: 8) {
            
            ForEach(yearsShort, id: \.self) { year in
                
                DynamicFetchView(predicate: NSPredicate(format: "year BEGINSWITH %@", year as String),
                                 sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]) { (events: FetchedResults<Item>) in
                    
                    BarYearsView(percent: CGFloat(events.count) , yearChart: year).frame(alignment: .bottom)
                    
                }
                
            }
        }
    }
}


