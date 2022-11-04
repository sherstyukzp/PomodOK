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
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)]
    )
    
    // MARK: - Variables
    var items: FetchedResults<Item>
    
    @State private var date = Date()
    @State private var showingTimer = true
    @State private var time = 1500
    @State var selectedDataType = DateType.days
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    enum DateType: String, Equatable, CaseIterable {
        //case hours = "Hours"
        case days = "Days"
        case months = "Months"
        case years = "Years"
        case all = "All"
        
        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    }
    
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                Picker("Period", selection: $selectedDataType) {
                    ForEach(DateType.allCases, id:\.self) { value in
                        Text(value.localizedName).tag(value)
                    }
                }.pickerStyle(SegmentedPickerStyle()).padding()
                
                switch selectedDataType {
                    
                    //case .hours: StatisticChartHoursView()
                case .days: ChartsDaysView(startDate: $startDate, endDate: $endDate)
                case .months: ChartsMonthsView()
                case .years: ChartsYearsView()
                case .all: AllEntriesView()
                    
                }
            }
            
            .navigationBarTitle(Text("Statistics"), displayMode: .large)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    Menu {
                        Button {
                            
                            let date = Date()
                            let calendar = Calendar.current
                            
                            let startOfDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: date),
                                                                                 month: calendar.component(.month, from: date),
                                                                                 day: calendar.component(.day, from: date),
                                                                          hour: 0,
                                                                          minute: 0,
                                                                          second: 0
                                                                         ))!
 
                            let endOfDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: date),
                                                                                 month: calendar.component(.month, from: date),
                                                                                 day: calendar.component(.day, from: date),
                                                                          hour: 23,
                                                                          minute: 59,
                                                                          second: 59
                                                                         ))!
                            
                            startDate = startOfDate.previous(.monday)
                            endDate = endOfDate.next(.sunday)
                        } label: {
                            Text("This week")
                        }
                        
                        Button {
                            let date = Date()
                            let calendar = Calendar.current
                            
                            // Add 7 days
                            let dateLast = Calendar.current.date(byAdding: .day, value: -7, to: date)
                            
                            let startOfDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: dateLast!),
                                                                                 month: calendar.component(.month, from: dateLast!),
                                                                                 day: calendar.component(.day, from: dateLast!),
                                                                          hour: 0,
                                                                          minute: 0,
                                                                          second: 0
                                                                         ))!
 
                            let endOfDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: date),
                                                                                 month: calendar.component(.month, from: date),
                                                                                 day: calendar.component(.day, from: date),
                                                                          hour: 23,
                                                                          minute: 59,
                                                                          second: 59
                                                                         ))!
                            
                            
                            startDate = startOfDate.previous(.monday)
                            endDate = endOfDate.previous(.sunday)
                        } label: {
                            Text("Last week")
                        }
                    } label: {
                        Label("calendar", systemImage: "calendar")
                    }
                    
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                            .bold()
                            .foregroundColor(Color(.red))
                    }
                }
            }
        }
        
    }
    
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}
