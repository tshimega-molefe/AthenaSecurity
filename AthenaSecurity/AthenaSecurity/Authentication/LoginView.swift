//
//  LoginView.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userAuth: AuthViewModel
    @State private var isEmptyField = false
    
    //  MARK: - Properties
    
    var body: some View {
        ZStack {
            
            Color.theme.background.edgesIgnoringSafeArea(.all)
            
            //            Parent VStack
            
            VStack {
                
                //            AuthHeaderView
                
                AuthHeaderView(authImage: UIImage(imageLiteralResourceName: "login"), authLabel: "Log In")
                
                //                Authentication TextField VStack
                
                VStack (spacing: 10) {
                    CustomInputField(inputType: .text, placeholderText: "Username", text: $userAuth.username)
                    CustomInputField(inputType: .secure, placeholderText: "Password", text: $userAuth.password)
                    
                }
                .padding(.horizontal, 30)
                .padding(.top, 64)
                
                //                "Forgot Password?" HStack
                
                HStack (alignment: .center){
                    
                    Spacer()
                    
                    NavigationLink {
                        Text("Reset Password")
                    } label: {
                        Text("Forgot Password?")
                            .font(.custom(FontsManager.Poppins.regular, size: 15))
                            .foregroundColor(Color.theme.accent)
                        
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top)
                
                
                // Incomplete Log In Button
                
                if(self.userAuth.username.isEmpty || self.userAuth.password.isEmpty){
                    Button(action: {
                        print("DEBUG: There is missing information in either of the log in fields..")
                    }, label: {
                        Text("Log In")
                            .font(.custom(FontsManager.Poppins.semiBold, size: 16))
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 67)
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                    })
                    .padding(.top, 40)
                    .padding(.horizontal, 30)
                } else {
                    AuthButtonView(buttonLabel: "Log In") {
                        userAuth.loginSecurity()
                    }
                    
//                    .alert("Failed to log in", isPresented: $userAuth.invalid, actions: {
//                        Button("Dismiss") {
//                            print("DEBUG: You've entered incorrect details..")
//                        }
//                    })
                    .padding(.top, 40)
                }
                
                
                Spacer()
            }
        }
        .navigationTitle("Log In")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onTapGesture {
            dismissKeyboard()
        }
    }
}
