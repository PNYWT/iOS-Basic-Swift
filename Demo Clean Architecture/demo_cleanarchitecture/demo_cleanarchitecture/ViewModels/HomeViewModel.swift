//
//  HomeViewModel.swift
//  demo_cleanarchitecture
//
//  Created by CallmeOni on 26/2/2568 BE.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol = UserRepository()) {
        self.repository = repository
    }

    func fetchUsers() {
        Task {
            isLoading = true
            do {
                let haveUsers = try await repository.getUsers()
                users = haveUsers
                isLoading = false
            } catch {
                errorMessage = "Failed to fetch users"
                isLoading = false
            }
        }
    }
}

