//
//  WhatsNew.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 15.03.2021.
//  Copyright © 2021 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct WhatsNew: View {

    // Variable to Dismiss Modal
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

    @ObservedObject var model = Model()
    
    var body: some View {

        return VStack {
            Text("Version: \(appVersion)")
                .font(.largeTitle).bold()
                .padding()
            Text("What's new in this version?").fixedSize(horizontal: false, vertical: true)
            
            ScrollView {
                VStack {
                    Text(model.data).frame(maxWidth: .infinity)
                }
            }.padding()

            Spacer()
            // Dismiss Button
            Button(action: { self.presentationMode.wrappedValue.dismiss() }, label: {
                Text("👍").font(Font.system(size:80, design: .default))
                    .padding()
            })
        }

    }
}


class Model: ObservableObject {
    @Published var data: String = ""
    init() { self.load(file: "WhatsNew") }
    func load(file: String) {
        if let filepath = Bundle.main.path(forResource: file, ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                DispatchQueue.main.async {
                    self.data = contents
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
    }
}

struct WhatsNew_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNew()
    }
}

