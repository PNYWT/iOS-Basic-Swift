//
//  DogViewModel.swift
//  SkeletonViewDemo
//
//  Created by Dev on 8/1/2568 BE.
//

import Foundation
import Alamofire
import Combine

class DogViewModel {
    
    @Published var dogData: DogModel?

    func fetchData() {
        AF.request("https://dog.ceo/api/breed/hound/images").response { response in
            switch response.result {
            case .success(let data):
                guard let haveData = data else {
                    return
                }
                
                do {
                    let dogObject = try JSONDecoder().decode(DogModel.self, from: haveData)
                    self.dogData = dogObject
                    #if DEBUG
                    print("self.dogData -> \(self.dogData)")
                    #endif
                } catch {
                    print("Fail decode JSON")
                }
                
            case .failure(let error):
                print("API fail -> \(error.localizedDescription)")
            }
        }
    }
}
