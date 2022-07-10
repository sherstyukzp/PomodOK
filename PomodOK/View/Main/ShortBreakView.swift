//
//  ShortBreakView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 06.05.2021.
//  Copyright © 2021 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct ShortBreakView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var shortBreak: Int
    @State private var timeBraak: Int = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text ("Relax for another \(shortBreak) minutes")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20.0)
                Spacer()
                Image("relaxing")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaledToFit()
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text("Сancel")
                    }
                    .font(.system(size: 30))
                    .padding(15.0)
                    .frame(width: 200, height: 60, alignment: .center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20.0)
                            .stroke(lineWidth: 2.0)
                            .shadow(color: .blue, radius: 20.0)
                    )
                }
                Spacer()
                
            }
            .background(Color(#colorLiteral(red: 0.9685428739, green: 0.9686816335, blue: 0.9685124755, alpha: 1)))
            
        }.background(Color(#colorLiteral(red: 0.9685428739, green: 0.9686816335, blue: 0.9685124755, alpha: 1)))
            .edgesIgnoringSafeArea(.all)
            .onReceive(timer) { _ in
                
                if timeBraak != shortBreak {
                    timeBraak += 1
                    print("timeBraak \(timeBraak)")
                }
                if timeBraak == shortBreak {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}

struct ShortBreakView_Previews: PreviewProvider {
    static var previews: some View {
        ShortBreakView(shortBreak: .constant(5))
    }
}
