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
        VStack {
            Text("Statistics for the year")
                .font(Font.system(size:24, design: .default))
                .padding()
            Chart {
                BarMark(
                    x: .value("Year", "2021"),
                    y: .value("Value", checkItemDaysOfTheYear(year: "2021"))
                )
                BarMark(
                    x: .value("Year", "2022"),
                    y: .value("Value", checkItemDaysOfTheYear(year: "2022"))
                )
                BarMark(
                    x: .value("Year", "2023"),
                    y: .value("Value", checkItemDaysOfTheYear(year: "2023"))
                )
                
            }
            .foregroundColor(Color("redColor"))
            .frame(height: 250)
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
