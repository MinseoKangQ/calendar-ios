//
//  ApiService.swift
//  calendar-ios
//
//  Created by 강민서 on 6/9/24.
//

import Foundation

class ApiService {
    
    static let BASE_URL = "http://localhost:8080"
    static var authToken: String?
    
    // 이메일 중복 확인
    static func checkEmailDuplicated(email: String, completion: @escaping (Int) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/users/email/\(email)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(500)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                // 로그인 시 Authorization Token이 Response Header에 담겨옴
                // 이후 모든 요청은 Request Header에 해당 Token 값을 넣어 특정 사용자를 인식할 것임
                if let authHeader = httpResponse.allHeaderFields["Authorization"] as? String, authHeader.starts(with: "Bearer ") {
                    authToken = String(authHeader.dropFirst("Bearer ".count))
                }
                completion(httpResponse.statusCode)
            }
        }
        task.resume()
    }
    
    // 아이디 중복 확인
    static func checkUserIdDuplicated(userId: String, completion: @escaping (Int) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/users/userId/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(500)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode)
            }
        }
        task.resume()
    }
    
    // 회원가입
    static func signUp(userId: String, email: String, password: String, completion: @escaping (Int) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/users/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "userId": userId,
            "email": email,
            "password": password
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            completion(500)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(500)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode)
            }
        }
        task.resume()
    }
    
    // 로그인
    static func signIn(userId: String, password: String, completion: @escaping (Int) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/users/signin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "userId": userId,
            "password": password
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            completion(500)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(500)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode)
            }
        }
        task.resume()
    }
}
