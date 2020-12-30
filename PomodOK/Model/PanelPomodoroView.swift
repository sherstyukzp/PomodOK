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
                Image(systemName: self.tomato1 ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .foregroundColor(Color("redColor"))
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(Color(.white))
                    .cornerRadius(40/2)
                    .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)
                Spacer()
                Image(systemName: self.tomato2 ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .foregroundColor(Color("redColor"))
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(Color(.white))
                    .cornerRadius(40/2)
                    .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)
                Spacer()
                Image(systemName: self.tomato3 ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .foregroundColor(Color("redColor"))
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(Color(.white))
                    .cornerRadius(40/2)
                    .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)
                Spacer()
                Image(systemName: self.tomato4 ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .foregroundColor(Color("redColor"))
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(Color(.white))
                    .cornerRadius(40/2)
                    .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)
            }
        }.padding()
    }
}

struct PanelPomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        PanelPomodoroView(tomato1: .constant(true), tomato2: .constant(true), tomato3: .constant(true), tomato4: .constant(true))
    }
}
