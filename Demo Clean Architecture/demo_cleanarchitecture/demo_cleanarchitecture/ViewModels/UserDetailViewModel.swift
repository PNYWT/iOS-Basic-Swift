//
//  UserDetailViewModel.swift
//  demo_cleanarchitecture
//
//  Created by CallmeOni on 26/2/2568 BE.
//

import Foundation

final class UserDetailViewModel: ObservableObject {
    @Published var user: User

    init(user: User) {
        self.user = user
    }
}

