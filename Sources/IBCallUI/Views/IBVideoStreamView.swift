//
//  IBVideoStreamView.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI
import UIKit

/// The renderer resolves the screen space against the frame's *display* size — WebRTC applies
/// `RTCVideoRotation` before reporting dimensions — so both modes stay correct for
/// landscape and portrait sources, and when either party rotates mid-call.
public enum IBVideoContentMode {
    case fit, // Letterbox — the whole frame stays visible, black bars fill the remainder. Applied to screen sharing
         fill // Crop — the frame covers the container and the overflow is clipped.
}

/// Creates a renderer `UIView` for a track, scaled according to the given mode.
public typealias IBVideoRendererFactory = (AnyObject, IBVideoContentMode) -> UIView

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
///     contentMode: .fit,
///     rendererFactory: { track, mode in
///         let view = InfobipRTCFactory.videoView(
///             frame: .zero,
///             contentMode: mode == .fit ? .scaleAspectFit : .scaleAspectFill
///         )
///         (track as? VideoTrack)?.addRenderer(view)
///         return view
///     }
/// )
/// ```
public struct IBVideoStreamView: UIViewRepresentable {
    /// The video track (InfobipRTC.VideoTrack, passed as AnyObject).
    public var videoTrack: AnyObject?
    /// How the stream should be scaled into the view's bounds.
    public var contentMode: IBVideoContentMode
    /// Factory that creates a renderer UIView and attaches the track to it.
    public var rendererFactory: IBVideoRendererFactory

    public init(
        videoTrack: AnyObject?,
        contentMode: IBVideoContentMode = .fill,
        rendererFactory: @escaping IBVideoRendererFactory
    ) {
        self.videoTrack = videoTrack
        self.contentMode = contentMode
        self.rendererFactory = rendererFactory
    }

    public final class Coordinator {
        var currentTrackID: ObjectIdentifier?
        var currentMode: IBVideoContentMode?
    }

    public func makeCoordinator() -> Coordinator { Coordinator() }

    public func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .black
        attachRenderer(to: container, context: context)
        return container
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        // The renderer is torn down and rebuilt, so only do it when the track or
        // the scaling mode actually changed — not on every body evaluation.
        let newID = videoTrack.map { ObjectIdentifier($0) }
        guard newID != context.coordinator.currentTrackID
                || contentMode != context.coordinator.currentMode else { return }
        attachRenderer(to: uiView, context: context)
    }

    private func attachRenderer(to container: UIView, context: Context) {
        container.subviews.forEach { $0.removeFromSuperview() }
        context.coordinator.currentTrackID = videoTrack.map { ObjectIdentifier($0) }
        context.coordinator.currentMode = contentMode
        if let track = videoTrack {
            let rendererView = rendererFactory(track, contentMode)
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
