//
//  ImageStore.swift
//  DemoChatGPTStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import Foundation
import OpenAI

public final class ImageStore: ObservableObject {
    public var openAIClient: OpenAIProtocol
    
    @Published var images: [ImagesResult.Image] = []
    
    public init(
        openAIClient: OpenAIProtocol
    ) {
        self.openAIClient = openAIClient
    }
    
    @MainActor
    func images(query: ImagesQuery) async {
        images.removeAll()
        do {
            let response = try await openAIClient.images(query: query)
            images = response.data
        } catch {
            // TODO: Better error handling
            print(error.localizedDescription)
        }
    }
}
