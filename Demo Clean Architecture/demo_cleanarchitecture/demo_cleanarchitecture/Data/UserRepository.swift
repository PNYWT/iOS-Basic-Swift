//
//  UserRepository.swift
//  demo_cleanarchitecture
//
//  Created by CallmeOni on 26/2/2568 BE.
//

import Foundation

protocol UserRepositoryProtocol {
    func getUsers() async throws -> [User]
}

final class UserRepository: UserRepositoryProtocol {
    func getUsers() async throws -> [User] {
        return try await APIClient.shared.fetchUsers()
    }
}

