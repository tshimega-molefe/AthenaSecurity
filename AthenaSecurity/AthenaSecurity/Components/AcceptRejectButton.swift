//
//  AcceptRejectButton.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI

struct AcceptRejectButtonView: View {
    
    enum ButtonType {
        case accept
        case reject
    }
    
    let buttonType: ButtonType
    let buttonLabel: String
    let clicked: (() -> Void)
    
    var body: some View {
        
        switch(buttonType) {
        case .accept:
            
            Button(action: clicked) {
                Text(buttonLabel)
                    .font(.custom(FontsManager.Poppins.semiBold, size: 16))
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60)
                    .background(Color.theme.green)
                    .cornerRadius(15)
            }
            .shadow(color: .gray.opacity(0.15), radius: 2.5, x: 0, y: 0)
            
        case .reject:
            
            Button(action: clicked) {
                Text(buttonLabel)
                    .font(.custom(FontsManager.Poppins.semiBold, size: 16))
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60)
                    .background(Color.theme.red)
                    .cornerRadius(15)
            }
            .shadow(color: .gray.opacity(0.15), radius: 2.5, x: 0, y: 0)
        }
    }
}

struct AcceptRejectButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AcceptRejectButtonView(buttonType: .accept, buttonLabel: "Accept") {
            print("DEBUG: Handle Accept Button Input")
        }
    }
}
