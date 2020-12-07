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

    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]
    )
    
    //MARK: - Variables
    var items: FetchedResults<Item>
    
    @State private var date = Date()
        
//    func update(_ result : FetchedResults<Item>)-> [[Item]]{
//          return  Dictionary(grouping: result){ (element : Item)  in
//            dateFormatter.string(from: element.timestamp!)
//          }.values.sorted() { $0[0].timestamp! < $1[0].timestamp! }
//        }
    
    //MARK: - Body
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
