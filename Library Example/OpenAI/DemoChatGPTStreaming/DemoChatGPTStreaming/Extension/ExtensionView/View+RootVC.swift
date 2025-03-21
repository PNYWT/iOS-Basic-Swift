//
//  View+RootVC.swift
//  OpenAIChatStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import SwiftUI

extension View {
    
    @inlinable public func navigationTitle(_ titleKey: LocalizedStringKey, selectedModel: Binding<String>) -> some View {
        self
            .navigationTitle(titleKey)
            .safeAreaInset(edge: .top) {
                HStack {
                    Text(
                        "Model: \(selectedModel.wrappedValue)"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
    }
    
    @inlinable public func modelSelect(selectedModel: Binding<String>, models: [String], showsModelSelectionSheet: Binding<Bool>, help: String) -> some View {
        self
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showsModelSelectionSheet.wrappedValue.toggle()
                    }) {
                        Image(systemName: "cpu")
                    }
                }
            }
            .confirmationDialog(
                "Select model",
                isPresented: showsModelSelectionSheet,
                titleVisibility: .visible,
                actions: {
                    ForEach(models, id: \.self) { (model: String) in
                        Button {
                            selectedModel.wrappedValue = model
                        } label: {
                            Text(model)
                        }
                    }
                    
                    Button("Cancel", role: .cancel) {
                        showsModelSelectionSheet.wrappedValue = false
                    }
                },
                message: {
                    Text(
                        "View \(help) for details"
                    )
                    .font(.caption)
                }
            )
    }
    
    func getCurrentViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return nil }
        return rootViewController
    }
}

