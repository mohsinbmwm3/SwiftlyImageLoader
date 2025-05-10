//
//  SwiftlyAsyncImage.swift.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import SwiftUI
import SwiftlyImageLoader

public enum SwiftlyAsyncImagePhase: Equatable {
    case empty
    case success(CrossPlatformImage)
    case failure
}

public struct SwiftlyAsyncImage<Content: View>: View {
    @State private var phase: SwiftlyAsyncImagePhase = .empty

    private let url: URL?
    private let transform: (@Sendable (CrossPlatformImage) -> CrossPlatformImage)?
    private let content: (SwiftlyAsyncImagePhase) -> Content

    public init(
        url: URL?,
        transform: (@Sendable (CrossPlatformImage) -> CrossPlatformImage)? = nil,
        @ViewBuilder content: @escaping (SwiftlyAsyncImagePhase) -> Content
    ) {
        self.url = url
        self.transform = transform
        self.content = content
    }

    public var body: some View {
        content(phase)
            .onAppear {
                guard phase == .empty, let url else { return }

                ImageLoader.shared.loadImage(from: url, transform: transform) { loadedImage in
                    DispatchQueue.main.async {
                        if let img = loadedImage {
                            self.phase = .success(img)
                        } else {
                            self.phase = .failure
                        }
                    }
                }
            }
    }
}

