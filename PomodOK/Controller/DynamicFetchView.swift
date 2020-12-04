//
//  DynamicFetchView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 04.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import CoreData
import SwiftUI

struct DynamicFetchView<T: NSManagedObject, Content: View>: View {
    let fetchRequest: FetchRequest<T>
    let content: (FetchedResults<T>) -> Content

    var body: some View {
        self.content(fetchRequest.wrappedValue)
    }

    init(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor], @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {
        fetchRequest = FetchRequest<T>(entity: T.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
        self.content = content
    }

    init(fetchRequest: NSFetchRequest<T>, @ViewBuilder content: @escaping (FetchedResults<T>) -> Content) {
        self.fetchRequest = FetchRequest<T>(fetchRequest: fetchRequest)
        self.content = content
    }
}
