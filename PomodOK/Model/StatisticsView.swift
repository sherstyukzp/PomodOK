//
//  StatisticsView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 06.09.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI
import CoreData

struct StatisticView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @State private var date = Date()
    @State var date2 = Date()
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]
    )
    
    var items: FetchedResults<Item>
 
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
      }
    
    // Метод получения название месяца (формат: October)
    private let itemFormatterNameMonth: DateFormatter = {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let monthString = dateFormatter.string(from: date)
        
        return dateFormatter
    }()
    
//    func update(_ result : FetchedResults<Item>)-> [[Item]]{
//          return  Dictionary(grouping: result){ (element : Item)  in
//            dateFormatter.string(from: element.timestamp!)
//          }.values.sorted() { $0[0].timestamp! < $1[0].timestamp! }
//        }
    
    var body: some View {
            NavigationView {
                VStack {
                    
                    StatisticMonth()
                    StatisticChartView()
                    
                }
                .navigationBarTitle(Text("Statistic"), displayMode: .inline)
                
            }
        }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}
