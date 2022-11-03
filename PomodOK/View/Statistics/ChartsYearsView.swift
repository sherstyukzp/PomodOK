//
//  ChartsYearsView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 24.09.2022.
//  Copyright © 2022 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI
import CoreData
import Charts

struct ChartsYearsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        
        let chartDataSet = [
            ChartDataModel(label: "2021", value: checkItemDaysOfTheYear(year: "2021")),
            ChartDataModel(label: "2022", value: checkItemDaysOfTheYear(year: "2022")),
            ChartDataModel(label: "2023", value: checkItemDaysOfTheYear(year: "2023"))
        ]
        
        VStack {
            Text("Statistics for the year")
                .font(Font.system(size:24, design: .default))
                .padding()
            Chart(chartDataSet, id: \.label) { item in
                BarMark(
                    x: .value("Year", item.label),
                    y: .value("Value", item.value)
                )
            }
            .foregroundColor(Color("redColor"))
            .frame(height: 250)
            .padding()
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    let maxYear = chartDataSet.max { a, b in a.value < b.value }
                    let minYear = chartDataSet.min { a, b in a.value < b.value }
                    Divider()
                    HStack {
                        Text("The best year: ")
                        Text("\(maxYear?.label ?? "")")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("The worst year: ")
                        Text("\(minYear?.label ?? "")")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
                Spacer()
            }
            .padding()
        }
        Spacer()
    }
    
    func checkItemDaysOfTheYear(year: String) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "year BEGINSWITH %@", year)
        return ((try? viewContext.count(for: fetchRequest)) ?? 0)
    }
    
}

struct ChartsYearsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsYearsView()
    }
}
