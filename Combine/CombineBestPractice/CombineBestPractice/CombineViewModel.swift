//
//  CurrentValueSubjectExample.swift
//  CombineBestPractice
//
//  Created by Dev on 2/1/2568 BE.
//

import UIKit
import Combine
import Alamofire

// MARK: - CurrentValueSubject
// อัปเดต UI ด้วยข้อมูลสถานะปัจจุบัน เช่น ชื่อผู้ใช้ (state-based updates)
class CurrentValueSubjectViewModelExample {
    // ใช้ CurrentValueSubject เพื่อเก็บสถานะปัจจุบัน
    let userName = CurrentValueSubject<String, Never>("")
    
    // Fetch user name (mock API call)
    func fetchUserName() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            self.userName.send("John Doe")
        }
    }
}


// MARK: - PassthroughSubject
// ส่ง event เช่น การกดปุ่ม (event-driven updates)
class EventViewModelExample {
    // ใช้ PassthroughSubject เพื่อส่ง event
    let buttonTapped = PassthroughSubject<Void, Never>()
    
    func buttonWasTapped() {
        buttonTapped.send()
    }
}


// MARK: - Future
struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}

class FutureViewModelExample {
    @Published var users: [User] = [] // users เป็น Array ของ User
    @Published var isRefreshing: Bool = false // isRefreshing เป็น Boolean
    private var cancellables: Set<AnyCancellable> = []

    let refreshSubject = PassthroughSubject<Void, Never>() // เป็น Toggle สำหรับ Call Service
    
    func toggleRefresh() {
        refreshSubject.send()
    }

    init() {
        bindRefreshAction()
    }

    func bindRefreshAction() {
        refreshSubject
            .flatMap { [weak self] _ -> AnyPublisher<[User], Error> in
                guard let self = self else { return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher() }
                self.isRefreshing = true
                return self.fetchUserData(from: "https://jsonplaceholder.typicode.com/users")
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isRefreshing = false
                    if case let .failure(error) = completion {
                        print("Error refreshing data: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] users in
                    self?.users = users
                }
            )
            .store(in: &cancellables)
    }

    private func fetchUserData(from url: String) -> AnyPublisher<[User], Error> {
        return Future { promise in
            AF.request(url).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let users = try JSONDecoder().decode([User].self, from: data)
                        promise(.success(users))
                    } catch {
                        promise(.failure(error))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

