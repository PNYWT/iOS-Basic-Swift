//
//  MockupAPI.swift

import Alamofire
import Combine

// Define the URLs for your services
let url1 = "https://example.com/service1"
let url2 = "https://example.com/service2"
let url3 = "https://example.com/service3"

// Create a function to perform the request and return a Future
func fetchData(from url: String) -> Future<Data, Error> {
    return Future { promise in
        AF.request(url).response { response in
            if let error = response.error {
                promise(.failure(error))
            } else if let data = response.data {
                promise(.success(data))
            }
        }
    }
}

// Create the publishers for each request
let publisher1 = fetchData(from: url1)
let publisher2 = fetchData(from: url2)
let publisher3 = fetchData(from: url3)

// Combine the publishers using `zip`
let combinedPublisher = Publishers.Zip3(publisher1, publisher2, publisher3)

// Subscribe to the combined publisher
let cancellable = combinedPublisher.sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
        print("All requests completed")
    case .failure(let error):
        print("An error occurred: \(error)")
    }
}, receiveValue: { data1, data2, data3 in
    // Handle the responses here
    // Update your view with data1, data2, and data3
    
    print("Service 1 response data: \(data1)")
    print("Service 2 response data: \(data2)")
    print("Service 3 response data: \(data3)")
})
