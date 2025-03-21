//
//  MockupAPI.swift

import Foundation
import Alamofire

class MultiService {

    let dispatchGroup = DispatchGroup()

    // Placeholder for your responses
    var response1: DataResponse<Any, AFError>?
    var response2: DataResponse<Any, AFError>?
    var response3: DataResponse<Any, AFError>?

    // First request
    dispatchGroup.enter()
    AF.request("https://example.com/service1").responseJSON { response in
        response1 = response
        dispatchGroup.leave()
    }

    // Second request
    dispatchGroup.enter()
    AF.request("https://example.com/service2").responseJSON { response in
        response2 = response
        dispatchGroup.leave()
    }

    // Third request
    dispatchGroup.enter()
    AF.request("https://example.com/service3").responseJSON { response in
        response3 = response
        dispatchGroup.leave()
    }

    // Notify when all requests are done
    dispatchGroup.notify(queue: .main) {
        if let response1 = response1, let response2 = response2, let response3 = response3 {
            // Handle the responses
            // For example, you can update your view here
            
            // Example:
            // if response1.result.isSuccess && response2.result.isSuccess && response3.result.isSuccess {
            //     self.updateView(with: response1, response2, response3)
            // } else {
            //     self.showError()
            // }
            
            print("Service 1 response: \(response1)")
            print("Service 2 response: \(response2)")
            print("Service 3 response: \(response3)")
        }
    }

}
