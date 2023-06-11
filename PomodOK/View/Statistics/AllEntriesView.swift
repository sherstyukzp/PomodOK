//
//  AllEntriesView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 10.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI
import CoreData

struct AllEntriesView: View {
    
    // MARK: - Variables
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var date = Date()
    
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
        VStack {
            List {
                ForEach(update(items), id: \.self) { (section: [Item]) in
                    Section(header: Text( self.dateFormatter.string(from: section[0].timestamp!))) {
                        ForEach(section, id: \.self) { item in
                            HStack {
                                Text("Item at")
                                Text("\(item.timestamp!, formatter: ItemFormatter.init().itemFormatter)")
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }.id(items.count)
            }
            
            HStack {
                
                DatePicker(selection: $date, in: ...Date(), displayedComponents: [.hourAndMinute, .date]) {
//                    Text("Total records: \(items.count)")
                }
                
                Button("Add Item", action: addItem)
            }
            .padding()
        }
        
    }
    
    //MARK: - Core Data
    //MARK: - Save Item
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = self.date
            newItem.hour = ItemFormatter.init().itemFormatterHour.string(from: date)
            newItem.dayWeek = ItemFormatter.init().itemFormatterNameDayOfTheWeek.string(from: date)
            newItem.month = ItemFormatter.init().itemFormatterNameMonthNumber.string(from: date)
            newItem.year = ItemFormatter.init().itemFormatterNameYear.string(from: date)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    //MARK: - Delete Item
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}


