//
//  LinkPreview.swift
//  DemoChatGPTStreaming
//
//  Created by Dev on 19/12/2567 BE.
//

import SwiftUI
import LinkPresentation

struct LinkPreview: UIViewRepresentable {
    typealias UIViewType = LPLinkView
    
    var previewURL: URL
    
    func makeUIView(context: Context) -> LPLinkView {
        LPLinkView(url: previewURL)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        LPMetadataProvider().startFetchingMetadata(for: previewURL) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let metadata = metadata else {
                print("Metadata missing for \(previewURL.absoluteString)")
                return
            }
            uiView.metadata = metadata
        }
    }
}
