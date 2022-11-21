//
//  WebService.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import Foundation

    // MARK: - Login

enum AuthenticationError: Error {
    case invalidCredentials
    case custom(errorMessage: String)
}

struct LoginRequestBody: Codable {
    let username: String
    let password: String
}

struct LoginResponseBody: Codable {
    let access: String?
    let refresh: String?
    
}

    // MARK: - Update

enum UpdateError: Error {
    case failedUpdate
    case custom(errorMessage: String)
}

struct UpdateRequestBody: Codable {
    let firstName: String
    let lastName: String
    let cellPhone: Int
    let company: String
}

struct UpdateResponseBody: Codable {
    let access: String?
    let refresh: String?
}


class Webservice: ObservableObject {
//    MARK: - LoginSecurity WebService
    
    func login(username: String, password: String, completion: @escaping (Result<String, AuthenticationError>) -> Void) {
        
        guard let url = URL(string: "http://localhost:8000/api/users/login/") else {
            completion(.failure(.custom(errorMessage: "DEBUG: URL is not correct...")))
            return
        }
        
        let body = LoginRequestBody(username: username, password: password)
        
        guard let finalBody = try? JSONEncoder().encode(body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = finalBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "DEBUG: There is no data...")))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    
                    let loginResponse = try? JSONDecoder().decode(LoginResponseBody.self, from: data)
                    
                    let access = loginResponse?.access
                    
                    
                    
                    completion(.success(access!))
                    
                } else {
                    completion(.failure(.invalidCredentials))
                }
            }
        }
        task.resume()
    }
    
//    MARK: - UpdateSecurity WebService
    
    func updateSecurity(firstName: String, lastName: String, cellPhone: Int, company: String, completion: @escaping (Result<String, UpdateError>) -> Void) {
        
        guard let url = URL(string: "http://localhost:8000/api/users/security/update/") else {
            completion(.failure(.custom(errorMessage: "DEBUG: URL is not correct...")))
            return
        }
        
        let body = UpdateRequestBody(firstName: firstName, lastName: lastName, cellPhone: cellPhone, company: company)
        
        guard let finalBody = try? JSONEncoder().encode(body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = finalBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
        guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "DEBUG: There is no data...")))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    
                    let updateResponse = try? JSONDecoder().decode(UpdateResponseBody.self, from: data)
                    
                    let access = updateResponse?.access
                    
                    completion(.success(access!))
                    
                } else {
                    completion(.failure(.failedUpdate))
                }
            }
        }
        task.resume()
    }
    
//    MARK: - FetchSecurity WebService
    
}
