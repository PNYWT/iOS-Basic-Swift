//
//  Observable.swift
//  PlayPlayPlus
//
//  Created by Dev on 9/4/2567 BE.
//

import Foundation

class Observable<T> {
    
    var value: T? {
        didSet {
            DispatchQueue.main.async {
                self.listener?(self.value)
            }
        }
    }
    
    init(value: T? = nil) {
        self.value = value
    }
    
    private var listener: ((T?) -> Void)?
    
    //Creating Binding function
    func bind( _ listener: @escaping ((T?) -> Void)) {
        listener(value)
        self.listener = listener
    }
}
