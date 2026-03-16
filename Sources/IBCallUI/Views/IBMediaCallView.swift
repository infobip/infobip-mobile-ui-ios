//
//  IBMediaCallView.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// Video call screen. Shown when at least one video track (local, remote, or
/// screenshare) is active. The primary stream fills the background; a draggable
/// floating window holds the secondary stream(s).
struct IBMediaCallView: View {
    @ObservedObject var state: IBCallUIState
    @Binding var buttons: [IBCallButtonModel]
    var configuration: IBCallUIConfiguration
    var rendererFactory: (AnyObject) -> UIView
    var onPIPToggle: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background: screenshare takes priority; else remote video; else black
            backgroundStream
                .ignoresSafeArea()

            // Header — transparent background so video shows through top safe area
            VStack(spacing: 0) {
                header
                    .background(Color.black.opacity(0.35))
                Spacer()
            }
            .ignoresSafeArea(edges: .top)

            // Floating video window (local cam, or local+remote when screenshare is bg)
            IBFloatingVideoWindow(
                localVideoTrack: state.localVideoTrack,
                secondaryVideoTrack: remoteFloatingTrack,
                rendererFactory: rendererFactory,
                isPIP: state.isPIP
            )

            // Bottom sheet — transparent background so video shows through
            if !state.isPIP {
                IBCallButtonsSheet(
                    buttons: $buttons,
                    configuration: configuration.withTransparentSheet
                )
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var backgroundStream: some View {
        switch state.screenshare {
        case .local(let track), .remote(let track):
            IBVideoStreamView(videoTrack: track, rendererFactory: rendererFactory)
        case .none:
            if let remoteTrack = state.remoteVideoTrack {
                IBVideoStreamView(videoTrack: remoteTrack, rendererFactory: rendererFactory)
            } else {
                configuration.backgroundColor
            }
        }
    }

    /// When screenshare fills the background, the remote camera should appear in the
    /// floating window alongside the local camera. Otherwise nil (remote is the bg).
    private var remoteFloatingTrack: AnyObject? {
        state.screenshare.isActive ? state.remoteVideoTrack : nil
    }

    private var header: some View {
        HStack(spacing: 8) {
            if state.isRemoteMuted {
                configuration.iconMutedParticipant
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(configuration.foregroundColor)
            }

            Text(state.remoteTitle)
                .foregroundColor(configuration.foregroundColor)
                .lineLimit(1)
                .layoutPriority(1)

            if !state.statusText.isEmpty {
                Rectangle()
                    .fill(configuration.foregroundColor)
                    .frame(width: 1, height: 14)

                Text(state.statusText)
                    .foregroundColor(configuration.foregroundColor)
            }

            Spacer()

            Button(action: onPIPToggle) {
                (state.isPIP ? configuration.iconExpand : configuration.iconCollapse)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(configuration.foregroundColor)
            }
            .padding(.trailing, 16)
        }
        .padding(.leading, 16)
        .padding(.vertical, 8)
        .frame(height: state.isPIP ? 90 : 45, alignment: .top)
    }
}
