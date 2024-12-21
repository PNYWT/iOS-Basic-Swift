//
//  DemoChatGPTStreamingApp.swift
//  DemoChatGPTStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import SwiftUI

@main
struct DemoChatGPTStreamingApp: App {
    
    private var manualKey: String = ""
    @AppStorage("apiKey") var apiKey: String = ""
    @State var isShowingAPIConfigModal: Bool = false
    
    let idProviderUUID: () -> String
    let dateProvider: () -> Date

    init() {
        self.idProviderUUID = {
            UUID().uuidString
        }
        self.dateProvider = Date.init
    }

    var body: some Scene {
        WindowGroup {
            Group {
                APIProvidedView(
                    apiKey: $apiKey,
                    idProvider: idProviderUUID
                )
            }
            
            .onAppear {
                if manualKey.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "apiKey")
                } else {
                    apiKey = manualKey
                }
                if apiKey.isEmpty {
                    isShowingAPIConfigModal.toggle()
                }
            }
#if os(iOS)
                .fullScreenCover(isPresented: $isShowingAPIConfigModal) {
                    APIKeyView(apiKey: $apiKey)
                }
#elseif os(macOS)
                .popover(isPresented: $isShowingAPIConfigModal) {
                    APIKeyView(apiKey: $apiKey)
                }
#endif
        }
    }
}
