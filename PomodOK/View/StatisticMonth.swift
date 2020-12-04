//
//  StatisticMonth.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 04.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI
import CoreData

let months: [String] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]



struct StatisticMonth: View {
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]
    )

    var items: FetchedResults<Item>
    
    var body: some View {
        
        DynamicFetchView(predicate: NSPredicate(format: "month==%@", "10" as String),
                         sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]) { (months: FetchedResults<Item>) in

            ForEach(months, id: \.self) { month in
                //Text(event.dayWeek ?? "")
                //Text("\(event.timestamp!, formatter: itemFormatter)")
            }

            Text("В October \(String(months.count)) события")
                .font(.headline)
                .foregroundColor(Color(.red))
        }
        
    }
}


