//
//  PillButton.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI

struct PillButton: View {
    let text: String
    let cancel: (() -> Void)
    
    var body: some View {
        Button(action: cancel,
               label: {
                    Text(text)
                    .font(.custom(FontsManager.Poppins.semiBold, size: 16))
                    .foregroundColor(Color.theme.accent)
                    .frame(width: 100, height: 40)
                    .background(Color.theme.background)
                    .cornerRadius(40)
                    .shadow(color: Color.theme.shadow, radius: 8)
        })
    }
}

struct PillButton_Previews: PreviewProvider {
    static var previews: some View {
        PillButton(text: "Accept") {
            print("DEBUG: Handle cancel...")
        }
    }
}
