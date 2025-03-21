//
//  ListModelsView.swift
//  DemoChatGPTStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import SwiftUI

public struct ListModelsView: View {
    @ObservedObject var store: MiscStore
    
    public var body: some View {
        NavigationStack {
            List($store.availableModels.wrappedValue, id: \.id) { row in
                Text(row.id)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Models")
        }
        .onAppear {
            Task {
                await store.getModels()
            }
        }
    }
}
