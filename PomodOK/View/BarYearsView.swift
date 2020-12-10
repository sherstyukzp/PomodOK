//
//  BarYearsView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 10.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct BarYearsView: View {
    var percent : CGFloat = 0
    var yearChart = ""
    
    var body : some View {
        
        VStack {
            
            Text(String(format: "%.0f", Double(percent))).foregroundColor(Color.white.opacity(0.5))
            
            Rectangle().fill(Color.red).frame(width: UIScreen.main.bounds.width / 12 - 12, height: getHeight())
            
            Text(yearChart).foregroundColor(Color.yellow.opacity(0.5))
        }
    }
    
    func getHeight()->CGFloat{
        
        return 200 / 100 * percent
    }
}


