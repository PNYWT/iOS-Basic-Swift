//
//  APIProvidedView.swift
//  OpenAIChatStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import SwiftUI
import OpenAI

// MARK: หน้าแรก กรณี apiKey empty จะแสดงหน้า APIKeyView
/*
 สิ่งที่ต้นฉบับไม่มี
 - Chat แบบจดจำ Message ได้
 - Chat แบบจดจำการสนทนาแต่ละชิ้นได้
 */

struct APIProvidedView: View {
    @Binding var apiKey: String
    
    // Feature
    @StateObject var chatStore: ChatStore
    @StateObject var imageStore: ImageStore
    @StateObject var miscStore: MiscStore
    
    @State var isShowingAPIConfigModal: Bool = true
    @Environment(\.idProviderValue) var idProvider
    @Environment(\.dateProviderValue) var dateProvider

    init(apiKey: Binding<String>, idProvider: @escaping () -> String) {
        self._apiKey = apiKey
        // Chat
        self._chatStore = StateObject(
            wrappedValue: ChatStore(
                openAIClient: OpenAI(apiToken: apiKey.wrappedValue),
                idProvider: idProvider
            )
        )
        
        // Gen Image
        self._imageStore = StateObject(
            wrappedValue: ImageStore(
                openAIClient: OpenAI(apiToken: apiKey.wrappedValue)
            )
        )
        
        
        self._miscStore = StateObject(
            wrappedValue: MiscStore(
                openAIClient: OpenAI(apiToken: apiKey.wrappedValue)
            )
        )
    }

    var body: some View {
        TabbarContentView(
            chatStore: chatStore,
            imageStore: imageStore,
            miscStore: miscStore,
            apiKey: _apiKey
        )
        .onChange(of: apiKey) { newApiKey in
            let client = OpenAI(apiToken: newApiKey)
            chatStore.openAIClient = client
            imageStore.openAIClient = client
        }
    }
}
