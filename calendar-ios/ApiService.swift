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
    
    // 할 일 등록
    static func addTodo(date: String, title: String, category: String, completion: @escaping (Bool) -> Void) {
            let url = URL(string: "\(BASE_URL)/api/todo")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
            if let token = authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let requestBody: [String: Any] = [
                "date": date,
                "title": title,
                "category": category
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
                request.httpBody = jsonData
            } catch {
                print("ReqeustBody 직렬화 실패: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("요청 실패: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                    completion(true)
                } else {
                    print("예상치 못한 코드를 받음: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                    completion(false)
                }
            }
            
            task.resume()
        }
    
    
    // 특정 날짜의 할 일 목록 가져오기
    static func getTodoList(for date: String, completion: @escaping ([TodoItem]?) -> Void) {
        print("할 일 목록 가져오기")
        print("\(date)")
        
        // 날짜 포맷 확인 및 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let formattedDate = dateFormatter.date(from: date) else {
            print("Invalid date format: \(date)")
            completion(nil)
            return
        }
        
        let formattedDateString = dateFormatter.string(from: formattedDate)
        print("Formatted Date: \(formattedDateString)")
        
        
        guard let url = URL(string: "\(BASE_URL)/api/todo/oneDay/\(date)") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to make request: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CustomApiResponse<[TodoItem]>.self, from: data)
                completion(response.data)
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
}

struct TodoItem: Codable {
    let title: String
    let category: String
    let isDone: Bool
}

struct CustomApiResponse<T: Codable>: Codable {
    let status: Int
    let data: T?
    let message: String
}

