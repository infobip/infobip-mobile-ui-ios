//
//  IBVideoStreamView.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI
import UIKit

/// A `UIViewRepresentable` that hosts an InfobipRTC `VideoTrack` renderer.
///
/// The `videoTrack` parameter is typed as `AnyObject?` to avoid a compile-time
/// dependency on InfobipRTC inside the shared library. Consumers must also
/// provide a `rendererFactory` closure (injected at the `IBCallViewController`
/// level) that creates the appropriate `UIView` and calls `addRenderer`.
///
/// Example (from a consumer that imports InfobipRTC):
/// ```swift
/// IBVideoStreamView(
///     videoTrack: someVideoTrack,
///     rendererFactory: { track in
///         let view = InfobipRTCFactory.videoView(frame: .zero, contentMode: .scaleAspectFill)
///         (track as? VideoTrack)?.addRenderer(view)
///         return view
///     }
/// )
/// ```
public struct IBVideoStreamView: UIViewRepresentable {
    /// The video track (InfobipRTC.VideoTrack, passed as AnyObject).
    public var videoTrack: AnyObject?
    /// Factory that creates a renderer UIView and attaches the track to it.
    public var rendererFactory: (AnyObject) -> UIView

    public init(videoTrack: AnyObject?, rendererFactory: @escaping (AnyObject) -> UIView) {
        self.videoTrack = videoTrack
        self.rendererFactory = rendererFactory
    }

    public func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .black
        if let track = videoTrack {
            let rendererView = rendererFactory(track)
            rendererView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(rendererView)
            NSLayoutConstraint.activate([
                rendererView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                rendererView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                rendererView.topAnchor.constraint(equalTo: container.topAnchor),
                rendererView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }
        return container
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        // Remove old renderer and add new one if track changed
        uiView.subviews.forEach { $0.removeFromSuperview() }
        if let track = videoTrack {
            let rendererView = rendererFactory(track)
            rendererView.translatesAutoresizingMaskIntoConstraints = false
            uiView.addSubview(rendererView)
            NSLayoutConstraint.activate([
                rendererView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
                rendererView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
                rendererView.topAnchor.constraint(equalTo: uiView.topAnchor),
                rendererView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor)
            ])
        }
    }
}
