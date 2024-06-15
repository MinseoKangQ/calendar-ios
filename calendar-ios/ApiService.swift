//
//  ApiService.swift
//  calendar-ios
//
//  Created by 강민서 on 6/9/24.
//

import Foundation

class ApiService {
    
    static let BASE_URL = "http://localhost:8080"
    static let TMP_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJrbXMwMjE3MSIsInJvbGVzIjoiVVNFUiIsImlhdCI6MTcxODM4ODI3NCwiZXhwIjoxNzE4OTkzMDc0fQ.zE8DTKuwXfTE3MQg2MCkxmKkyL4t4b7AscLRYTnsMgg"
    static var authToken: String?
    
    // 토큰 없이 Reuqest 설정
    private static func setRequestWithoutToken(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    // 토큰과 함께 Reuqest 설정
    private static func setRequestWithToken(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Request Header에 토큰 넣기
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(TMP_TOKEN)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    // 이메일 중복 확인 API
    // [GET] http://localhost:8080/api/users/email/{email}
    static func checkEmailDuplicated(email: String, completion: @escaping (Int) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/users/email/\(email)")!
        let request = setRequestWithoutToken(url: url, method: "GET")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                completion(500)
                return
            }
            completion(httpResponse.statusCode)
        }
        task.resume()
    }
    
    // 아이디 중복 확인 API
    // [GET] http://localhost:8080/api/users/userId/{userId}
    static func checkUserIdDuplicated(userId: String, completion: @escaping (Int) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/users/userId/\(userId)")!
        let request = setRequestWithoutToken(url: url, method: "GET")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                completion(500)
                return
            }
            completion(httpResponse.statusCode)
        }
        task.resume()
    }
    
    // 회원가입 API
    // [POST] http://localhost:8080/api/users/signup
    static func signUp(userId: String, email: String, password: String, completion: @escaping (Int) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/users/signup")!
        var request = setRequestWithoutToken(url: url, method: "POST")
        
        let requestBody: [String: Any] = [
            "userId": userId,
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(500)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                completion(500)
                return
            }
            completion(httpResponse.statusCode)
        }
        task.resume()
    }
    
    // 로그인 API
    // [POST] http://localhost:8080/api/users/signin
    static func signIn(userId: String, password: String, completion: @escaping (Int) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/users/signin")!
        var request = setRequestWithoutToken(url: url, method: "POST")
        
        let requestBody: [String: Any] = [
            "userId": userId,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(500)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                completion(500)
                return
            }
            
            if let authHeader = httpResponse.allHeaderFields["Authorization"] as? String, authHeader.starts(with: "Bearer ") {
                authToken = String(authHeader.dropFirst("Bearer ".count))
            }
            completion(httpResponse.statusCode)
        }
        task.resume()
    }
    
    // 할 일 등록 API
    // [POST] http://localhost:8080/api/todo
    static func addTodo(date: String, title: String, category: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/todo")!
        var request = setRequestWithToken(url: url, method: "POST")
        
        let requestBody: [String: Any] = [
            "date": date,
            "title": title,
            "category": category
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("ReqeustBody 직렬화 실패: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }
    
    // 특정 날짜의 할 일 목록 가져오기 API
    // [GET] http://localhost:8080/api/todo/oneDay/{date}
    static func getTodoList(for date: String, completion: @escaping ([TodoItem]?) -> Void) {
        guard let url = URL(string: "\(BASE_URL)/api/todo/oneDay/\(date)") else {
            completion(nil)
            return
        }

        let request = setRequestWithToken(url: url, method: "GET")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else {
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(CustomApiResponse<[TodoItem]>.self, from: data)
                completion(response.data)
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    // 할 일 체크/체크 해제 API 호출
    // [PUT] http://localhost:8080/api/todo/category/{todoId}
    static func toggleTodoCheck(todoId: Int, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/todo/checking/\(todoId)")!
        let request = setRequestWithToken(url: url, method: "PUT")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }
    
    // 할 일 수정 API
    // [PUT] http://localhost:8080/api/todo/title/{todoId}
    static func updateTodoTitle(todoId: Int, title: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/todo/title/\(todoId)")!
        var request = setRequestWithToken(url: url, method: "PUT")
        
        let requestBody: [String: Any] = ["title": title]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("RequestBody 직렬화 실패: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }
    
    // 할 일 삭제 API
    // [DELETE] http://localhost:8080/api/todo/{todoId}
    static func deleteTodo(todoId: Int, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/todo/\(todoId)")!
        let request = setRequestWithToken(url: url, method: "DELETE")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }
    
    // 한 달 조회 API
    // [GET] http://localhost:8080/api/todo/oneMonth/{month}
    static func getOneMonthTodoList(for month: String, completion: @escaping (TodoResponse?) -> Void) {
        guard let url = URL(string: "\(BASE_URL)/api/todo/oneMonth/\(month)") else {
            completion(nil)
            return
        }

        let request = setRequestWithToken(url: url, method: "GET")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else {
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(TodoResponse.self, from: data)
                completion(response)
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    // 아직 못끝낸 할 일 개수 조회 API
    // [GET] http://localhost:8080/api/todo/notDoneCount
    static func getNotDoneCount(completion: @escaping (NotDoneCountReponse?) -> Void) {
        guard let url = URL(string: "\(BASE_URL)/api/todo/notDoneCount") else {
            completion(nil)
            return
        }

        let request = setRequestWithToken(url: url, method: "GET")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else {
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(NotDoneCountReponse.self, from: data)
                completion(response)
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    // 회원 탈퇴 API
    // [DELETE] http://localhost:8080/api/users
    static func deleteUser(completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(BASE_URL)/api/users")!
        let request = setRequestWithToken(url: url, method: "DELETE")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
    }
}

// API 응답의 일반적인 형식을 나타내는 구조체
struct CustomApiResponse<T: Codable>: Codable {
    let status: Int
    let data: T?
    let message: String
}

// 할 일 항목을 나타내는 구조체
struct TodoItem: Codable {
    let todoId: Int
    var title: String
    let category: String
    var isDone: Bool
}

// 한 달 조회 응답을 나타내는 구조체
struct TodoResponse: Codable {
    let status: Int
    let data: [String: TodoDayData]
    let message: String
}

// 한 달의 끝난 일, 끝나지 않은 일 개수 조회 응답을 나타내는 구조체
struct TodoDayData: Codable {
    let doneCount: Int
    let notDoneCount: Int
}

// 아직 못끝낸 할 일 개수 조회 응답을 나타내는 구조체
struct NotDoneCountReponse: Codable {
    let status: Int
    let data: Int
    let message: String
}
