//
//  ChatView.swift
//  OpenAIChatStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import SwiftUI

struct ChatView: View {
    
    @ObservedObject var store: ChatStore
    
    @Environment(\.dateProviderValue) var dateProvider
    @Environment(\.idProviderValue) var idProvider

    public init(store: ChatStore) {
        self.store = store
    }
    
    public var body: some View {
        NavigationSplitView {
            // TableView, Sidebar
            ListView(
                conversations: $store.conversations,
                selectedConversationId: Binding<Conversation.ID?>(
                    get: {
                    store.selectedConversationID
                }, set: { newId in
                    store.selectConversation(newId)
                })
            )
            .toolbar {
                ToolbarItem(
                    placement: .primaryAction
                ) {
                    Button(action: {
                        store.createConversation() // สร้าง Room Chat
                    }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        } detail: {
            // Did Select item
            if let conversation = store.selectedConversation {
                DetailView(
                    conversation: conversation,
                    error: store.conversationErrors[conversation.id],
                    sendMessage: { message, selectedModel in
                        Task {
                            // Send Message ทำงาน
                            await store.sendMessage(
                                Message(
                                    id: idProvider(),
                                    role: .user,
                                    content: message,
                                    createdAt: dateProvider()
                                ),
                                conversationId: conversation.id,
                                model: selectedModel
                            )
                        }
                    }
                )
            }
        }
    }
}
