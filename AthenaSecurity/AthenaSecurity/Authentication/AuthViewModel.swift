//
//  AuthViewModel.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import Foundation
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    var didChange = PassthroughSubject<AuthViewModel, Never>()
    
    //@AppStorage("Authentication_Status") var isAuthenticated = (!username.isEmpty() || !username.isExpired() ) ? true : false - where accessToken is from the keychain
    
    @AppStorage("Access_Token") var isAuthenticated = false {
        willSet { objectWillChange.send() }
    }
    
    @AppStorage("USER_KEY") var username = ""
    @Published var password = ""
    @Published var email = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var cellPhone = ""
    
    
    @Published var invalid: Bool = false
    @Published var alreadyExists: Bool = false
    @Published var selectedIndex = 2
    
    init() {
        
        if let data = KeychainHelper.standard.read(service: "access-token"){
            let accessToken = String(data: data, encoding: .utf8)
            print("DEBUG: Current username is \(username)")
            print("DEBUG: Current access token is \(String(describing: accessToken))")
            self.isAuthenticated = true
        }
        else {
            print("DEBUG: No access token found in keychain")
            self.isAuthenticated = false
        }
    }
    
    
    func loginSecurity() {
        Webservice().login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let accessToken):
                    print("DEBUG: Access token is \(accessToken)")
                    let data = Data(accessToken.utf8)
                    KeychainHelper.standard.save(data, service: "access-token")
                    
                    self.isAuthenticated = true
                    self.password = ""
                    
                case .failure(let error):
                    self.invalid = true
                    print("DEBUG: \(error.localizedDescription)")
                }
            }
        }
    }
        
    func updateSecurity(withFirstName firstname: String, lastName: String, cellNumber: String) {
        print("DEBUG: User Firstname is \(firstname), Lastname is \(lastName), and Phone number is \(cellNumber).")
    }
    
    func logoutSecurity() {
        print("DEBUG: Logged out the current user...")
        KeychainHelper.standard.delete(service: "access-token")
        
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.selectedIndex = 2
        }
        
    }
    
    func fetchCitizen() {
        print("DEBUG: Handle fetch the logged in user's data...")
    }
    
}
