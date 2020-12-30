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
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]
    )
    
    // MARK: - Variables
    var items: FetchedResults<Item>
    
    @State private var date = Date()
    @State private var MaterialType = 0
    @State private var showingTimer = true
    @State private var time = 1500
        
//    func update(_ result : FetchedResults<Item>)-> [[Item]]{
//          return  Dictionary(grouping: result){ (element : Item)  in
//            dateFormatter.string(from: element.timestamp!)
//          }.values.sorted() { $0[0].timestamp! < $1[0].timestamp! }
//        }
    
    // MARK: - Body
    var body: some View {
            NavigationView {
                VStack {
                    
                    Picker("Numbers", selection: $MaterialType) {
                                        Text("Hours").tag(0)
                                        Text("Days").tag(1)
                                        Text("Months").tag(2)
                                        Text("Years").tag(3)
                                        Text("All").tag(4)
                    }.pickerStyle(SegmentedPickerStyle()).padding()
                    
                    if MaterialType == 0 {
                                        StatisticChartHoursView()
                                    } else if MaterialType == 1 {
                                        StatisticChartDaysView()
                                    }
                                    else if MaterialType == 2 {
                                        StatisticChartMonthsView()
                                    }
                                    else if MaterialType == 3 {
                                        StatisticChartYearsView()
                                    }
                                    else {
                                        AllEntriesView()
                                    }
                    
                    if showingTimer {
                        TimerView(showTimer: $showingTimer, timerValue: $time, backgroundColor: Color(UIColor.red), vibrationAtTheEnd: true)
                         }
                    
                }
                .navigationBarTitle(Text("Statistics"), displayMode: .large)
                .navigationBarItems(trailing:
                        // Butoon Save
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Close")
                                .bold()
                                .foregroundColor(Color(.red))
                        }
                )
            }
        }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}
