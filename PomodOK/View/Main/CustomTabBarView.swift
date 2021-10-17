//
//  CustomTabBarView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 30.09.2021.
//  Copyright © 2021 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct CustomTabBarView: View {
    
    @Binding var showingStatisticsView: Bool
    @Binding var showingSettingsView: Bool
    @Binding var start: Bool
    @Binding var retrieved: Int
    @Binding var count: Int
    @Binding var to : CGFloat
    @Binding var showShortBreak: Bool
    //@Binding var shortBreak: Int
    @Binding var notifications: Bool
    @Binding var sound: Bool
    @Binding var vibration: Bool
    
    var body: some View {
        HStack {
            // Кнопка Статистика
            Button(action: {
                self.showingStatisticsView.toggle()
            }) {
                VStack(spacing:0) {
                    Image(systemName: "chart.bar")
                        .resizable()
                        .foregroundColor(Color.gray)
                        .aspectRatio(contentMode: .fit)
                        .padding(5)
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(6)
                }
                .frame(width: 100, height: 50)
            }
            .sheet(isPresented: $showingStatisticsView) {
                StatisticView()
            }
            Spacer()
            
            // MARK: - Button Start Timer
            Button(action: {
                if self.count == self.retrieved * 60 {
                    self.count = 0
                    withAnimation(.default){
                        self.to = 0
                    }
                }
                self.start.toggle()
                
            }) {
                Image(systemName: self.start ? "pause.circle" : "arrowtriangle.right.circle")
                    .resizable()
                    .foregroundColor(Color.white)
                    .frame(width: 90, height: 90)
                
            }
            .frame(width: 70, height: 70, alignment: .center)
            .background(Color("redColor"))
            .cornerRadius(70/2)
            .shadow(radius: 5)
            
            Spacer()
            // MARK: - Button Settings
            Button(action: {
                self.showingSettingsView.toggle()
                
            }) {
                VStack(spacing:0) {
                    Image(systemName: "gear")
                        .resizable()
                        .foregroundColor(Color.gray)
                        .padding(5)
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(6)
                }
                .frame(width: 100, height: 50)
            }
            .sheet(isPresented: $showingSettingsView) {
                
                SettingsView()
            }
            
        }
        .frame(minHeight: 70)
    }
    
    
}

