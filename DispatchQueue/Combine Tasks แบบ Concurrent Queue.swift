/*
 Use Case
 - มี Tasks 3 งานที่สามารถทำงานพร้อมกัน เช่น การโหลดข้อมูลจาก API
 รอผลลัพธ์ของทุก Task และรวมผลลัพธ์
 */

import Combine
import Foundation

// Model สำหรับ URL ต่างๆ
struct User: Decodable {
    let id: Int
    let name: String
}

struct Post: Decodable {
    let id: Int
    let title: String
}

struct Comment: Decodable {
    let id: Int
    let content: String
}

func fetchData<T: Decodable>(url: String, type: T.Type) -> AnyPublisher<T, Error> {
    guard let url = URL(string: url) else {
        return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }
    
    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: T.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}

// MARK: Simple
// URLs จำลอง
let usersURL = "https://example.com/users" // ส่งคืน [User]
let postsURL = "https://example.com/posts" // ส่งคืน [Post]
let commentsURL = "https://example.com/comments" // ส่งคืน [Comment]

// สร้าง Combine Publishers
let usersPublisher = fetchData(url: usersURL, type: [User].self)
    .catch { _ in Just([]) } // หากล้มเหลว จะส่งคืน array ว่างแทน
let postsPublisher = fetchData(url: postsURL, type: [Post].self)
    .catch { _ in Just([]) }
let commentsPublisher = fetchData(url: commentsURL, type: [Comment].self)
    .catch { _ in Just([]) }

let cancellable = Publishers.MergeMany(
    usersPublisher.map { users in "Fetched Users: \(users.map { $0.name })"
    },
    postsPublisher.map { posts in "Fetched Posts: \(posts.map { $0.title })"
    },
    commentsPublisher.map { comments in "Fetched Comments: \(comments.map { $0.content })"
    }
)
    .collect() // รวบรวมผลลัพธ์ทั้งหมดใน Array
    .receive(on: DispatchQueue.main) // กลับมาอัปเดตใน Main Thread
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("All tasks completed successfully")
        case .failure(let error):
            print("Error occurred: \(error.localizedDescription)")
        }
    }, receiveValue: { results in
        print("Results:")
        results.forEach { print($0) }
    })

/*
 Start fetching data...
 Fetched Users: ["Alice", "Bob"]
 Fetched Posts: ["Post 1", "Post 2"]
 Fetched Comments: ["Comment 1", "Comment 2"]
 All tasks completed successfully
 */


// MARK: Handle Fail
// Combine Publishers
let usersPublisher = fetchData(url: usersURL, type: [User].self)
    .catch { _ in Just([]) } // Return empty array on failure
    .map { users -> (status: Bool, data: [User]) in
        (users.isEmpty ? false : true, users)
    }
    .eraseToAnyPublisher()

let postsPublisher = fetchData(url: postsURL, type: [Post].self)
    .catch { _ in Just([]) } // Return empty array on failure
    .map { posts -> (status: Bool, data: [Post]) in
        (posts.isEmpty ? false : true, posts)
    }
    .eraseToAnyPublisher()

let commentsPublisher = fetchData(url: commentsURL, type: [Comment].self)
    .catch { _ in Just([]) } // Return empty array on failure
    .map { comments -> (status: Bool, data: [Comment]) in
        (comments.isEmpty ? false : true, comments)
    }
    .eraseToAnyPublisher()

// Combine all publishers
let cancellable = Publishers.CombineLatest3(usersPublisher, postsPublisher, commentsPublisher)
    .receive(on: DispatchQueue.main) // Update UI on Main Queue
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("All services fetched")
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }, receiveValue: { usersResult, postsResult, commentsResult in
        // Update UI based on results
        print("Users:", usersResult.data)
        print("Posts:", postsResult.data)
        print("Comments:", commentsResult.data)
        
        // Check which services failed
        if !usersResult.status {
            print("Service 1 (Users) failed or has no data")
        }
        if !postsResult.status {
            print("Service 2 (Posts) failed or has no data")
        }
        if !commentsResult.status {
            print("Service 3 (Comments) failed or has no data")
        }
    })

/*
 All services fetched
 Users: [User(id: 1, name: "Alice")]
 Posts: []
 Comments: [Comment(id: 1, content: "Nice post!")]
 Service 2 (Posts) failed or has no data
 */
