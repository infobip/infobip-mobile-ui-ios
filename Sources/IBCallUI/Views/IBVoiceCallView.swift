//
//  IBVoiceCallView.swift
//  MobileMessaging
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import SwiftUI

/// Audio-only call screen. Shown when `callType == .audio` or during the
/// `.calling` phase before video is established.
struct IBVoiceCallView: View {
    @ObservedObject var state: IBCallUIState
    @Binding var buttons: [IBCallButtonModel]
    var configuration: IBCallUIConfiguration
    var rendererFactory: ((AnyObject) -> UIView)?
    var onPIPToggle: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            configuration.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if !state.isPIP {
                    Spacer()

                    // Remote muted indicator
                    if state.isRemoteMuted {
                        configuration.iconMutedParticipant
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(configuration.foregroundColor)
                    }

                    // Avatar placeholder
                    configuration.iconAvatar
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.45)
                        .padding(.top, state.isRemoteMuted ? 4 : 0)

                    Spacer()
                }

                // Name + status
                Text(state.remoteTitle)
                    .font(.system(size: 24))
                    .foregroundColor(configuration.foregroundColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(state.statusText)
                    .font(.subheadline)
                    .foregroundColor(configuration.textSecondaryColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                if state.isPIP {
                    Spacer(minLength: 8)
                } else {
                    Spacer()
                }
            }

            // Bottom sheet
            if !state.isPIP {
                IBCallButtonsSheet(
                    buttons: $buttons,
                    configuration: configuration
                )
            } else {
                // PIP: compact inline row — buttons are interactive, empty areas pass through
                IBCallButtonsRow(buttons: $buttons)
                    .padding(.bottom, 8)
                    .background(configuration.sheetBackgroundColor.opacity(0.85))
            }

            // Local video floating window — only instantiated when a track exists
            // so the UIKit renderer view is fully torn down when camera stops
            if let factory = rendererFactory, state.localVideoTrack != nil {
                IBFloatingVideoWindow(
                    localVideoTrack: state.localVideoTrack,
                    secondaryVideoTrack: nil,
                    rendererFactory: factory,
                    isPIP: state.isPIP
                )
            }
        }
        // In PIP mode, any tap not consumed by a button expands back to full screen
        .contentShape(Rectangle())
        .onTapGesture {
            if state.isPIP { onPIPToggle() }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onPIPToggle) {
                (state.isPIP ? configuration.iconExpand : configuration.iconCollapse)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 33, height: 33)
                    .foregroundColor(configuration.foregroundColor)
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .padding(.trailing, 8)
            .padding(.top, 8)
        }
    }
}
