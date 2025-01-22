//
//  MockupAPI.swift

import Foundation
import Alamofire
import Combine

// Define your model
struct Post: Decodable {
    let id: Int
    let title: String
    let body: String
}

// Define a service class for fetching data
class ApiService {
    private var cancellables = Set<AnyCancellable>()

    // Create a function to perform the request and return a Future
    func fetchPosts() -> Future<[Post], Error> {
        return Future { promise in
            let url = "https://jsonplaceholder.typicode.com/posts"
            AF.request(url).responseDecodable(of: [Post].self) { response in
                switch response.result {
                case .success(let posts):
                    promise(.success(posts))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }

    // Function to handle the response
    func getPosts() {
        fetchPosts().sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                // This block is executed when the publisher has finished sending values
                print("Successfully fetched posts")
                // Example: You can stop a loading indicator here
                self.stopLoadingIndicator()
            case .failure(let error):
                // This block is executed when an error occurs
                print("An error occurred: \(error)")
                // Example: Show an error message to the user
                self.showErrorMessage(error.localizedDescription)
            }
        }, receiveValue: { posts in
            // This block is executed for each value received from the publisher
            print("Received posts: \(posts)")
            // Example: Update your UI with the fetched posts
            self.updateUI(with: posts)
        }).store(in: &cancellables)
    }

    // Dummy functions for demonstration purposes
    func stopLoadingIndicator() {
        print("Loading indicator stopped")
    }

    func showErrorMessage(_ message: String) {
        print("Error: \(message)")
    }

    func updateUI(with posts: [Post]) {
        // Example code to update the UI
        for post in posts {
            print("Post ID: \(post.id), Title: \(post.title)")
        }
    }
}

// Create an instance of the service and call getPosts
let apiService = ApiService()
apiService.getPosts()
