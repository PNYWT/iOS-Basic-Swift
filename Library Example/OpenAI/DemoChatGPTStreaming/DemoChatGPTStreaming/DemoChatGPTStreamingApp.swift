//
//  DemoChatGPTStreamingApp.swift
//  DemoChatGPTStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import SwiftUI

@main
struct DemoChatGPTStreamingApp: App {
    
    @AppStorage("deviceUUID") var deviceUUID: String = ""
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
                checkDevice()
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
    
    private func checkDevice() {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            if uuid != deviceUUID {
                deviceUUID = uuid
                UserDefaults.standard.removeObject(forKey: "apiKey")
                isShowingAPIConfigModal.toggle()
            } else {
                if apiKey.isEmpty {
                    isShowingAPIConfigModal.toggle()
                }
            }
            #if DEBUG
            print("uuid -> \(uuid)")
            #endif
        } else {
            UserDefaults.standard.removeObject(forKey: "apiKey")
            isShowingAPIConfigModal.toggle()
        }
    }
}
