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

    public final class Coordinator {
        var currentTrackID: ObjectIdentifier?
    }

    public func makeCoordinator() -> Coordinator { Coordinator() }

    public func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .black
        attachRenderer(to: container, context: context)
        return container
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        let newID = videoTrack.map { ObjectIdentifier($0) }
        guard newID != context.coordinator.currentTrackID else { return }
        attachRenderer(to: uiView, context: context)
    }

    private func attachRenderer(to container: UIView, context: Context) {
        container.subviews.forEach { $0.removeFromSuperview() }
        context.coordinator.currentTrackID = videoTrack.map { ObjectIdentifier($0) }
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
    }
}
