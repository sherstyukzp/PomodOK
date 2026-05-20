//
//  PanelPomodoroView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 30.12.2020.
//  Copyright © 2020 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct PanelPomodoroView: View {

    let totalPomodoros: Int
    let completedPomodoros: Int

    var body: some View {
        let safeTotal = max(totalPomodoros, 1)

        ZStack {
            Rectangle()
                .fill(Color("redColor"))
                .frame(height: 6)
                .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)

            HStack(spacing: 0) {
                ForEach(0..<safeTotal, id: \.self) { index in
                    PomodoroCircleView(isCompleted: index < completedPomodoros)

                    if index < safeTotal - 1 {
                        Spacer()
                    }
                }
            }
        }
    }
}

struct PomodoroCircleView: View {

    let isCompleted: Bool

    var body: some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .resizable()
            .foregroundColor(Color("redColor"))
            .frame(width: 40, height: 40, alignment: .center)
            .background(Color(.white))
            .cornerRadius(20)
            .shadow(color: Color("redColor").opacity(0.4), radius: 5, x: 0, y: 5)
    }
}

struct PanelPomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        PanelPomodoroView(totalPomodoros: 4, completedPomodoros: 2)
    }
}
