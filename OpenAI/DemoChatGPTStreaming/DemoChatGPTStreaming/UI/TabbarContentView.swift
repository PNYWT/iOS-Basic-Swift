//
//  TabbarContentView.swift
//  DemoChatGPTStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import SwiftUI

struct TabbarContentView: View {
    
    // Feature
    @ObservedObject var chatStore: ChatStore
    @StateObject var imageStore: ImageStore
    @StateObject var miscStore: MiscStore
    
    @State private var selectedTab = 0
    @Environment(\.idProviderValue) var idProvider

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Chat
            ChatView(
                store: chatStore
            )
            .tabItem {
                Label("Chats", systemImage: "message")
            }
            .tag(0)

            // Create Image
            ImageView(
                store: imageStore
            )
            .tabItem {
                Label("Image", systemImage: "photo")
            }
            .tag(1)
            
            // ไม่แน่ใจกำลังแกะ
            MiscView(
                store: miscStore
            )
            .tabItem {
                Label("Misc", systemImage: "ellipsis")
            }
            .tag(2)
        }
    }
}

// MARK: Down here is Item Tabbar to select
struct ChatsView: View {
    var body: some View {
        Text("Chats")
            .font(.largeTitle)
    }
}
