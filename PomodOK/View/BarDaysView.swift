//
//  BarDaysView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 10.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

// График статистики по дням
struct BarDaysView : View {
    
    // MARK: - Variables
    var percent : CGFloat = 0
    var dayChart = ""
    
    // MARK: - Body
    var body : some View {
        
        VStack {
            Text(String(format: "%.0f", Double(percent))).foregroundColor(Color.black.opacity(0.5))
            Rectangle().fill(Color.red).frame(width: UIScreen.main.bounds.width / 7 - 12, height: getHeight())
            Text(dayChart).foregroundColor(Color.black.opacity(0.5))
        }
    }
    
    func getHeight()->CGFloat{
        
        return 200 / 100 * percent
    }
}
