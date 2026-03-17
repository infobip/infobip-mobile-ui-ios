//
//  IBFloatingVideoWindow.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// A draggable floating window that overlays the call screen and shows either the
/// local video feed, the remote video feed (when screenshare is active), or both
/// side-by-side. Respects screen bounds so it cannot be dragged off-screen.
struct IBFloatingVideoWindow: View {
    /// Local video track (camera), rendered when non-nil.
    var localVideoTrack: AnyObject?
    /// Secondary video track (remote camera when screenshare fills the background).
    var secondaryVideoTrack: AnyObject?
    /// Factory that creates a UIView renderer and attaches the given track to it.
    var rendererFactory: (AnyObject) -> UIView
    /// Whether the parent is in PIP mode (hides the floating window in PIP).
    var isPIP: Bool

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    // TODO: UIScreen.main is deprecated in iOS 16. Refactor once iOS 15 support is dropped.
    private let windowHeight: CGFloat = UIScreen.main.bounds.height / 5
    private var windowWidth: CGFloat { (windowHeight / 16) * 9 }

    var body: some View {
        GeometryReader { geometry in
            if !isPIP, localVideoTrack != nil || secondaryVideoTrack != nil {
                floatingContent
                    .frame(
                        width: contentWidth,
                        height: windowHeight
                    )
                    .cornerRadius(8)
                    .clipped()
                    .offset(clampedOffset(in: geometry.size))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = clampedOffset(in: geometry.size)
                                offset = lastOffset
                            }
                    )
                    .position(
                        x: geometry.size.width - contentWidth / 2 - 16,
                        y: geometry.size.height - windowHeight / 2 - 16
                    )
                    .onAppear {
                        // Start in bottom-right corner
                        lastOffset = .zero
                        offset = .zero
                    }
            }
        }
        .allowsHitTesting(!isPIP)
    }

    private var contentWidth: CGFloat {
        (localVideoTrack != nil && secondaryVideoTrack != nil)
            ? (windowWidth + 2) * 2
            : windowWidth
    }

    @ViewBuilder
    private var floatingContent: some View {
        if let local = localVideoTrack, let secondary = secondaryVideoTrack {
            HStack(spacing: 2) {
                IBVideoStreamView(videoTrack: local, rendererFactory: rendererFactory)
                IBVideoStreamView(videoTrack: secondary, rendererFactory: rendererFactory)
            }
        } else if let local = localVideoTrack {
            IBVideoStreamView(videoTrack: local, rendererFactory: rendererFactory)
        } else if let secondary = secondaryVideoTrack {
            IBVideoStreamView(videoTrack: secondary, rendererFactory: rendererFactory)
        }
    }

    private func clampedOffset(in size: CGSize) -> CGSize {
        let halfW = contentWidth / 2
        let halfH = windowHeight / 2

        let maxX = size.width / 2 - halfW
        let minX = -(size.width / 2 - halfW)
        let maxY = size.height / 2 - halfH
        let minY = -(size.height / 2 - halfH)

        return CGSize(
            width: min(maxX, max(minX, offset.width)),
            height: min(maxY, max(minY, offset.height))
        )
    }
}
