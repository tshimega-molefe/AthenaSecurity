//
//  CheckBox.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI

struct CheckBox: View {
    
    @Binding var checked: Bool
    
    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? Color.theme.red : Color.theme.accent)
            .onTapGesture {
                self.checked.toggle()
            }
    }
}

struct CheckBoxView_Previews: PreviewProvider {
    struct CheckBoxHolder: View {
        @State var checked = false
        
        var body: some View {
            CheckBox(checked: $checked)
        }
    }
    
    static var previews: some View {
        CheckBoxHolder()
    }
}
