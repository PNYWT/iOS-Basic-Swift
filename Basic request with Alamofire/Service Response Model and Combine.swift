//
//  MockupAPI.swift

import Alamofire
import Combine

// Define your model
struct MyModel: Decodable {
    let id: Int
    let name: String
    let description: String
}

// Define the URL for your service
let url = "https://example.com/service"

// Create a function to perform the request and return a Future
func fetchData(from url: String) -> Future<MyModel, Error> {
    return Future { promise in
        AF.request(url).responseDecodable(of: MyModel.self) { response in
            switch response.result {
            case .success(let model):
                promise(.success(model))
            case .failure(let error):
                promise(.failure(error))
            }
        }
    }
}

// Create the publisher for the request
let publisher = fetchData(from: url)

// Subscribe to the publisher
let cancellable = publisher.sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
        print("Request completed")
    case .failure(let error):
        print("An error occurred: \(error)")
    }
}, receiveValue: { model in
    // Handle the response here
    // Update your view with the model
    
    print("Received model: \(model)")
    // For example:
    // self.updateView(with: model)
})
