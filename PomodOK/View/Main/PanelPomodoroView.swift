//
//  PanelPomodoroView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 30.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct PanelPomodoroView: View {
    
    // MARK: - variables, constants
    @Binding var tomato1: Bool
    @Binding var tomato2: Bool
    @Binding var tomato3: Bool
    @Binding var tomato4: Bool
    
    init(tomato1: Binding<Bool>, tomato2: Binding<Bool>, tomato3: Binding<Bool>, tomato4: Binding<Bool>) {
        self._tomato1 = tomato1
        self._tomato2 = tomato2
        self._tomato3 = tomato3
        self._tomato4 = tomato4
        
    }
    
    var body: some View {
        ZStack {
            Rectangle()
            .fill(Color("redColor"))
            .frame(height: 6)
            .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)
            
            HStack {
                PomodoroCicleView(tomato: $tomato1)
                Spacer()
                PomodoroCicleView(tomato: $tomato2)
                Spacer()
                PomodoroCicleView(tomato: $tomato3)
                Spacer()
                PomodoroCicleView(tomato: $tomato4)
            }
        }
    }
}


struct PomodoroCicleView: View {
    
    @Binding var tomato: Bool
    
    var body: some View {
        Image(systemName: tomato ? "checkmark.circle.fill" : "circle")
            .resizable()
            .foregroundColor(Color("redColor"))
            .frame(width: 40, height: 40, alignment: .center)
            .background(Color(.white))
            .cornerRadius(40/2)
            .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)
    }
}


struct PanelPomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        PanelPomodoroView(tomato1: .constant(true), tomato2: .constant(true), tomato3: .constant(true), tomato4: .constant(true))
    }
}
