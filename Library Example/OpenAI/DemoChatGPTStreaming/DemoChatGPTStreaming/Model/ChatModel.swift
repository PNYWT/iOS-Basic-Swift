//
//  ChatModel.swift
//  OpenAIChatStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import Foundation
import OpenAI

struct Conversation {
    init(id: String, messages: [Message] = []) {
        self.id = id
        self.messages = messages
    }
    
    typealias ID = String
    
    let id: String
    var messages: [Message]
}

extension Conversation: Equatable, Identifiable {}

struct Message {
    var id: String
    var role: ChatQuery.ChatCompletionMessageParam.Role
    var content: String
    var createdAt: Date
}

extension Message: Equatable, Codable, Hashable, Identifiable {}

