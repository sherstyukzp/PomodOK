//
//  StatisticChartDaysView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 10.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI
import CoreData

struct StatisticChartHoursView: View {
    
    // MARK: - Variables
    let hours: [String] = ["06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22"]
    let today = Date()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var dateFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.dateStyle = .short
      return formatter
    }

      func update(_ result : FetchedResults<Item>)-> [[Item]] {
        return  Dictionary(grouping: result){ (element : Item)  in
            dateFormatter.string(from: element.timestamp!)
        }.values.map{$0}
      }
    
    
    // MARK: - Body
    var body: some View {
        Text("Statistics for the hours")
            .font(Font.system(size:24, design: .default))
            .padding()
        VStack {
            HStack(alignment: .bottom, spacing: 8) {
                
                ForEach(hours, id: \.self) { hour in
                    
                    DynamicFetchView(predicate: NSPredicate(format: "hour==%@", hour as String),
                                     sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]) { (events: FetchedResults<Item>) in
                        
                        BarHoursView(percent: CGFloat(events.count) , hourChart: hour).frame(alignment: .bottom)
                    }
                }
            }
            
            //
            
            //
            
            Text("Total today: \(items.count)")
            
        }
    
        Spacer()
    }
}


