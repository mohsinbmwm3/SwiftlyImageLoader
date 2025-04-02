//
//  SwiftlyAsyncImage.swift.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import SwiftUI
import SwiftlyImageLoader

public struct SwiftlyAsyncImage: View {
    @State private var image: CrossPlatformImage?
    private let url: URL?
    private let placeholder: () -> AnyView

    public init(url: URL?, placeholder: @escaping () -> AnyView = {
        AnyView(Color.gray.opacity(0.2))
    }) {
        self.url = url
        self.placeholder = placeholder
    }

    public var body: some View {
        ZStack {
            if let img = image {
                #if os(iOS)
                Image(uiImage: img)
                #elseif os(macOS)
                Image(nsImage: img)
                #endif
            } else {
                placeholder()
                    .onAppear {
                        guard let url else { return }
                        ImageLoader.shared.loadImage(from: url) { loadedImage in
                            self.image = loadedImage
                        }
                    }
            }
        }
    }
}
