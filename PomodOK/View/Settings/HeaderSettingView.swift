//
//  HeaderSettingView.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 30.09.2021.
//  Copyright © 2021 Ярослав Шерстюк. All rights reserved.
//

import SwiftUI

struct HeaderSettingView: View {
    @State var imageIcon: String = ""
    @State var text: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: imageIcon)
            Text(text)
        }
    }
}

struct HeaderSettingView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderSettingView()
    }
}
