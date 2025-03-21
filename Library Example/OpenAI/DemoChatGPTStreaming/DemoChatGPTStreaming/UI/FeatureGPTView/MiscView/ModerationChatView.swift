//
//  SwiftUIView.swift
//  DemoChatGPTStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import SwiftUI

public struct ModerationChatView: View {
    @ObservedObject var store: MiscStore
    
    @Environment(\.dateProviderValue) var dateProvider
    @Environment(\.idProviderValue) var idProvider

    public init(store: MiscStore) {
        self.store = store
    }
    
    public var body: some View {
        DetailView(
            conversation: store.moderationConversation,
            error: store.moderationConversationError,
            sendMessage: { message, _ in
                Task {
                    await store.sendModerationMessage(
                        Message(
                            id: idProvider(),
                            role: .user,
                            content: message,
                            createdAt: dateProvider()
                        )
                    )
                }
            }
        )
    }
}
