//
//  BarHoursView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 10.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

// График статистики по часам
struct BarHoursView : View {
    
    // MARK: - Variables
    var percent : CGFloat = 0
    var hourChart = ""
    
    // MARK: - Body
    var body : some View {
        
        VStack {
            Text(String(format: "%.0f", Double(percent))).foregroundColor(Color.yellow.opacity(0.5))
            Rectangle().fill(Color.red).frame(width: UIScreen.main.bounds.width / 17 - 12, height: getHeight())
            Text(hourChart).foregroundColor(Color.yellow.opacity(0.5)).font(Font.system(size: 12, design: .default))
        }
    }
    
    func getHeight()->CGFloat{
        
        return 200 / 100 * percent
    }
}
