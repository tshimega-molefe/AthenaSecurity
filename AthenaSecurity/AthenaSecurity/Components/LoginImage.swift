//
//  LoginImage.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI

struct AuthHeaderView: View {
    let authImage: UIImage
    let authLabel: String
    var body: some View {
        VStack(alignment: .center) {
            
            Image(uiImage: authImage)
                .padding(/*@START_MENU_TOKEN@*/.top, 10.0/*@END_MENU_TOKEN@*/)
                
            
            Text(authLabel)
                .font(.custom(FontsManager.Poppins.semiBold, size: 36))
                .foregroundColor(Color("SecondaryTextColor"))
                .padding(.top, -2.0)
                .multilineTextAlignment(.center)
        }
    }
}

struct AuthHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        AuthHeaderView(authImage: UIImage(imageLiteralResourceName: "register"), authLabel: "Create account with email")
    }
}
