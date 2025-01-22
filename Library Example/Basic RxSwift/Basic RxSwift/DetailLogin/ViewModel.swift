//
//  ViewModel.swift
//  Basic RxSwift
//
//  Created by Dev on 27/3/2567 BE.
//

import Foundation
import RxSwift
import RxCocoa

enum MyError: Error {
    
    case dataError
    
    var message: String {
        switch self {
        case .dataError:
            return "No data available."
        }
    }
}

class ProductViewModel {
    
    var items = PublishSubject<[Product]>()
    
    func fetchItems() {
        let products = [
            Product(imageName: "apple.logo", title: "Apple Logo"),
            Product(imageName: "lightbulb", title: "Lightbulb Logo"),
            Product(imageName: "figure.run", title: "Figure Run Logo"),
            Product(imageName: "globe.americas", title: "Globe Logo"),
            Product(imageName: "signature", title: "Signature Logo")
        ]
        
        items.onNext(products)
        items.onCompleted()
    }
    
    func fetchItemsByService() {
        guard let url = URL(string: "You Service") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.items.onError(error)
                return
            }
            
            guard let data = data else {
                self.items.onError(MyError.dataError)
                return
            }
            
            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                self.items.onNext(products)
                self.items.onCompleted()
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                self.items.onError(error)
            }
        }.resume()
    }
}
